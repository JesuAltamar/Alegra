import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/api_service.dart';
import '../services/recordatorio_scheduler.dart';
import 'package:pro9/services/email_service.dart';
import '../main.dart';

class ListaTareasPage extends StatefulWidget {
  const ListaTareasPage({super.key});

  @override
  State<ListaTareasPage> createState() => _ListaTareasPageState();
}

class _ListaTareasPageState extends State<ListaTareasPage>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late DateTime _focusedDay;
  List<dynamic> tareas = [];
  List<dynamic> todasLasTareas = [];
  Map<String, dynamic> estadisticas = {};
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedDay = DateTime.now();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadData();
    _loadAllTasks();
    _cargarRecordatoriosPendientes();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    RecordatorioScheduler.cancelarTodosLosRecordatorios();
    super.dispose();
  }

  Future<void> _cargarRecordatoriosPendientes() async {
    try {
      final tareasConRecordatorio =
          await ApiService.getTareasConRecordatorios();

      final messenger = ScaffoldMessenger.of(context);
      for (final tarea in tareasConRecordatorio) {
        try {
          await RecordatorioScheduler.programarRecordatorio(
            tarea: tarea,
            onEnviado: () {
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Recordatorio enviado: ${tarea['titulo']}',
                    ),
                    backgroundColor: Colors.green[400],
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            onError: (error) {
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Error en recordatorio: $error'),
                    backgroundColor: Colors.red[400],
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          );
        } catch (e) {
          debugPrint(
            'Error programando recordatorio para tarea ${tarea['id']}: $e',
          );
        }
      }
    } catch (e) {
      debugPrint('Error cargando recordatorios pendientes: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final fecha = DateFormat("yyyy-MM-dd").format(_selectedDate);
      final data = await ApiService.getTareas(fecha: fecha);
      final stats = await ApiService.getEstadisticas();
      setState(() {
        tareas = data;
        estadisticas = stats;
      });
    } catch (e) {
      if (e.toString().contains("401")) {
        if (!mounted) return;
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error cargando tareas: $e"),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }

  Future<void> _loadAllTasks() async {
    try {
      final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      List<dynamic> allTasks = [];
      for (int i = 0; i <= endOfMonth.day; i++) {
        try {
          final fecha = DateFormat(
            "yyyy-MM-dd",
          ).format(startOfMonth.add(Duration(days: i)));
          final dayTasks = await ApiService.getTareas(fecha: fecha);
          allTasks.addAll(dayTasks);
        } catch (e) {
          // Ignorar errores de dÃ­as individuales
        }
      }

      if (mounted) {
        setState(() {
          todasLasTareas = allTasks;
        });
      }
    } catch (e) {
      debugPrint("Error cargando todas las tareas: $e");
    }
  }

  Future<void> _toggleCompletar(int? id, bool completada) async {
    if (id == null) return;

    try {
      await ApiService.completarTarea(id, completada);
      _loadData();
      _loadAllTasks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al actualizar tarea: $e"),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  Future<void> _deleteTarea(int? id) async {
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Eliminar Tarea"),
            content: const Text(
              "Estas seguro? Esto tambienn cancelara el recordatorio si existe.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Eliminar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        RecordatorioScheduler.cancelarRecordatorio(id.toString());
        await ApiService.deleteTarea(id);
        _loadData();
        _loadAllTasks();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al eliminar tarea: $e"),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }

  // MÃ©todos auxiliares para UI
  Color _getEventColor(List events) {
    if (events.isEmpty) return Colors.grey;
    bool hasCompleted = events.any(
      (e) => e != null && (e["estado"]?.toString() ?? "") == "completada",
    );
    bool hasPending = events.any(
      (e) => e != null && (e["estado"]?.toString() ?? "") != "completada",
    );
    if (hasCompleted && hasPending) return Colors.orange;
    if (hasCompleted) return Colors.green;
    return Colors.red;
  }

  Color _getCategoryColor(String? categoria) {
    switch (categoria?.toLowerCase() ?? "") {
      case "trabajo":
        return Colors.blue;
      case "personal":
        return Colors.purple;
      case "salud":
        return Colors.red;
      case "hogar":
        return Colors.green;
      case "estudio":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String? categoria) {
    switch (categoria?.toLowerCase() ?? "") {
      case "trabajo":
        return Icons.work;
      case "personal":
        return Icons.person;
      case "salud":
        return Icons.local_hospital;
      case "hogar":
        return Icons.home;
      case "estudio":
        return Icons.school;
      default:
        return Icons.label;
    }
  }

  Color _getPriorityColor(String? prioridad) {
    switch (prioridad?.toLowerCase() ?? "") {
      case "alta":
        return Colors.red;
      case "media":
        return Colors.orange;
      case "baja":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String? prioridad) {
    switch (prioridad?.toLowerCase() ?? "") {
      case "alta":
        return Icons.priority_high;
      case "media":
        return Icons.remove;
      case "baja":
        return Icons.keyboard_arrow_down;
      default:
        return Icons.label;
    }
  }

  Widget _statBox(String label, int value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          "$value",
          style: TextStyle(
            fontSize: 24,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _chip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text.isEmpty ? "Sin definir" : text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  int _getStatValue(String key) {
    try {
      final value = estadisticas[key];
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    } catch (e) {
      return 0;
    }
  }

  List _getEventsForDay(DateTime day) {
    try {
      return todasLasTareas.where((t) {
        if (t == null) return false;
        final fechaStr = t["fecha"];
        if (fechaStr == null || fechaStr.toString().isEmpty) return false;
        try {
          final fecha = DateTime.parse(fechaStr.toString());
          return isSameDay(fecha, day);
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaTexto = DateFormat("d 'de' MMMM", "es_ES").format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              "Lista de Tareas",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 16,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${RecordatorioScheduler.recordatoriosActivos}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Row(
        children: [
          // Calendario + estadÃ­sticas
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue[50] ?? Colors.blue.shade50,
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statBox(
                        "Completadas",
                        _getStatValue("completadas"),
                        Colors.green,
                        Icons.check_circle,
                      ),
                      _statBox(
                        "Total",
                        _getStatValue("total"),
                        Colors.blue,
                        Icons.list_alt,
                      ),
                      _statBox(
                        "Recordatorios",
                        _getStatValue("recordatorios"),
                        Colors.amber,
                        Icons.notifications,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      locale: 'es_ES',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate:
                          (day) => isSameDay(_selectedDate, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDate = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _loadData();
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                        _loadAllTasks();
                      },
                      eventLoader: (day) => _getEventsForDay(day),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.isNotEmpty) {
                            return Positioned(
                              right: 1,
                              bottom: 1,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getEventColor(events),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue[400] ?? Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.orange[400] ?? Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        weekendTextStyle: TextStyle(
                          color: Colors.red[400] ?? Colors.red,
                        ),
                        outsideDaysVisible: false,
                        markersMaxCount: 1,
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: Colors.blue[400] ?? Colors.blue,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: Colors.blue[400] ?? Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Lista de tareas
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_note,
                        color: Colors.blue[600] ?? Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Tareas para $fechaTexto",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildTasksList()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildTasksList() {
    if (tareas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[300] ?? Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              "No hay tareas para esta fecha",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500] ?? Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Â¡Agrega una nueva tarea!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400] ?? Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tareas.length,
      itemBuilder: (context, i) => _buildTaskItem(i),
    );
  }

  Widget _buildTaskItem(int index) {
    try {
      if (index >= tareas.length) return const SizedBox.shrink();

      final t = tareas[index];
      if (t == null) return const SizedBox.shrink();

      final completada =
          (t["estado"]?.toString() ?? "").toLowerCase() == "completada";
      final titulo = t["titulo"]?.toString() ?? "(Sin titulo)";
      final descripcion = t["descripcion"]?.toString() ?? "";
      final categoria = t["categoria"]?.toString() ?? "personal";
      final prioridad = t["prioridad"]?.toString() ?? "media";
      final id = t["id"];
      final recordatorioActivo = t["recordatorio_activo"] == true;
      final emailRecordatorio = t["email_recordatorio"]?.toString();

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors:
                completada
                    ? [
                      Colors.green[50] ?? Colors.green.shade50,
                      Colors.green[25] ?? Colors.green.shade100,
                    ]
                    : [
                      Colors.red[50] ?? Colors.red.shade50,
                      Colors.red[25] ?? Colors.red.shade100,
                    ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                completada
                    ? Colors.green[200] ?? Colors.green.shade200
                    : Colors.red[200] ?? Colors.red.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (completada ? Colors.green : Colors.red).withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: completada,
                  activeColor: Colors.green[400] ?? Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (val) => _toggleCompletar(id, val ?? false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titulo,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color:
                                  completada
                                      ? Colors.grey[600] ?? Colors.grey
                                      : Colors.black87,
                              decoration:
                                  completada
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                        ),
                        if (recordatorioActivo) ...[
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.notifications_active,
                              size: 16,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (descripcion.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        descripcion,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              completada
                                  ? Colors.grey[500] ?? Colors.grey
                                  : Colors.grey[700] ?? Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _chip(
                          categoria,
                          _getCategoryColor(categoria),
                          _getCategoryIcon(categoria),
                        ),
                        const SizedBox(width: 8),
                        _chip(
                          prioridad,
                          _getPriorityColor(prioridad),
                          _getPriorityIcon(prioridad),
                        ),
                        if (recordatorioActivo &&
                            emailRecordatorio != null) ...[
                          const SizedBox(width: 8),
                          _chip(
                            emailRecordatorio.contains('@')
                                ? emailRecordatorio
                                        .split('@')[0]
                                        .substring(
                                          0,
                                          emailRecordatorio
                                                      .split('@')[0]
                                                      .length >
                                                  4
                                              ? 4
                                              : emailRecordatorio
                                                  .split('@')[0]
                                                  .length,
                                        ) +
                                    '...'
                                : emailRecordatorio.substring(
                                  0,
                                  emailRecordatorio.length > 4
                                      ? 4
                                      : emailRecordatorio.length,
                                ),
                            Colors.amber,
                            Icons.email,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // BotÃ³n de editar
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50] ?? Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.blue[400] ?? Colors.blue,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  if (id != null) {
                    _mostrarFormularioEditarTarea(t);
                  }
                },
              ),
              // BotÃ³n de eliminar
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50] ?? Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red[400] ?? Colors.red,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  if (id != null) {
                    _deleteTarea(id);
                  }
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error construyendo item de tarea: $e");
      return const SizedBox.shrink();
    }
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.8).animate(
        CurvedAnimation(
          parent: _fabAnimationController,
          curve: Curves.easeInOut,
        ),
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.blue[600] ?? Colors.blue,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _mostrarFormularioNuevaTarea,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nueva Tarea",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // FORMULARIO PARA CREAR NUEVA TAREA
  Future<void> _mostrarFormularioNuevaTarea() async {
    _fabAnimationController.forward();
    final formKey = GlobalKey<FormState>();
    String titulo = "";
    String descripcion = "";
    DateTime fecha = _selectedDate;
    String prioridad = "media";
    String categoria = "personal";

    bool recordatorioActivo = false;
    DateTime? fechaRecordatorio;
    String? horaRecordatorio;
    String? emailRecordatorio;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 24,
                  right: 24,
                  top: 20,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.add_task,
                              color: Colors.blue[600],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Text(
                            "Nueva Tarea",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TÃ­tulo
                              _buildFormField(
                                label: "Titulo",
                                icon: Icons.title,
                                child: TextFormField(
                                  style: const TextStyle(fontSize: 16),
                                  decoration: _inputDecoration(
                                    "Ingresa el titulo de la tarea",
                                  ),
                                  validator:
                                      (v) =>
                                          v == null || v.isEmpty
                                              ? "Campo requerido"
                                              : null,
                                  onChanged: (v) => titulo = v,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // DescripciÃ³n
                              _buildFormField(
                                label: "Descripcion",
                                icon: Icons.description,
                                child: TextFormField(
                                  style: const TextStyle(fontSize: 16),
                                  maxLines: 3,
                                  decoration: _inputDecoration(
                                    "Describe los detalles (opcional)",
                                  ),
                                  onChanged: (v) => descripcion = v,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Fecha
                              // Reemplaza la secciÃ³n problemÃ¡tica en tu archivo (lÃ­neas aproximadamente 785-801)
                              // Elimina estas lÃ­neas duplicadas y reemplaza con:

                              // Fecha
                              _buildFormField(
                                label: "Fecha",
                                icon: Icons.calendar_today,
                                child: InkWell(
                                  onTap: () async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: fecha,
                                      firstDate: DateTime.now().subtract(
                                        const Duration(days: 365),
                                      ),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary:
                                                  Colors.blue[600] ??
                                                  Colors.blue,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (pickedDate != null) {
                                      setModalState(() => fecha = pickedDate);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300] ?? Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.date_range,
                                          color: Colors.grey[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          DateFormat(
                                            "d 'de' MMMM, yyyy",
                                            "es_ES",
                                          ).format(fecha),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Prioridad y CategorÃ­a
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormField(
                                      label: "Prioridad",
                                      icon: Icons.priority_high,
                                      child: DropdownButtonFormField<String>(
                                        value: prioridad,
                                        decoration: _inputDecoration(""),
                                        items: const [
                                          DropdownMenuItem(
                                            value: "baja",
                                            child: Text("Baja"),
                                          ),
                                          DropdownMenuItem(
                                            value: "media",
                                            child: Text("Media"),
                                          ),
                                          DropdownMenuItem(
                                            value: "alta",
                                            child: Text("Alta"),
                                          ),
                                        ],
                                        onChanged:
                                            (v) => setModalState(
                                              () => prioridad = v ?? "media",
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _buildFormField(
                                      label: "Categoria",
                                      icon: Icons.category,
                                      child: DropdownButtonFormField<String>(
                                        value: categoria,
                                        decoration: _inputDecoration(""),
                                        items: const [
                                          DropdownMenuItem(
                                            value: "personal",
                                            child: Text("Personal"),
                                          ),
                                          DropdownMenuItem(
                                            value: "trabajo",
                                            child: Text("Trabajo"),
                                          ),
                                          DropdownMenuItem(
                                            value: "salud",
                                            child: Text("Salud"),
                                          ),
                                          DropdownMenuItem(
                                            value: "hogar",
                                            child: Text("Hogar"),
                                          ),
                                          DropdownMenuItem(
                                            value: "estudio",
                                            child: Text("Estudio"),
                                          ),
                                          DropdownMenuItem(
                                            value: "otro",
                                            child: Text("Otro"),
                                          ),
                                        ],
                                        onChanged:
                                            (v) => setModalState(
                                              () => categoria = v ?? "personal",
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              // SecciÃ³n de recordatorio por email
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.email,
                                          color: Colors.blue[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Recordatorio por Email",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Switch(
                                          value: recordatorioActivo,
                                          activeColor: Colors.blue[600],
                                          onChanged:
                                              (value) => setModalState(
                                                () =>
                                                    recordatorioActivo = value,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Recibe un email recordatorio completamente gratis",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),

                                    if (recordatorioActivo) ...[
                                      const SizedBox(height: 20),

                                      // Campo de email
                                      _buildFormField(
                                        label: "Correo electrÃ³nico",
                                        icon: Icons.email_outlined,
                                        child: TextFormField(
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: const TextStyle(fontSize: 16),
                                          decoration: _inputDecoration(
                                            "ejemplo@gmail.com",
                                          ),
                                          validator:
                                              recordatorioActivo
                                                  ? (v) {
                                                    if (v == null || v.isEmpty)
                                                      return "Campo requerido";
                                                    if (!RegExp(
                                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                    ).hasMatch(v)) {
                                                      return "Email invÃ¡lido";
                                                    }
                                                    return null;
                                                  }
                                                  : null,
                                          onChanged:
                                              (v) => emailRecordatorio = v,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Fecha del recordatorio
                                      _buildFormField(
                                        label: "Fecha del recordatorio",
                                        icon: Icons.calendar_today,
                                        child: InkWell(
                                          onTap: () async {
                                            final pickedDate =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      fechaRecordatorio ??
                                                      fecha,
                                                  firstDate: DateTime.now(),
                                                  lastDate: DateTime.now().add(
                                                    const Duration(days: 365),
                                                  ),
                                                );
                                            if (pickedDate != null) {
                                              setModalState(
                                                () =>
                                                    fechaRecordatorio =
                                                        pickedDate,
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.blue[300]!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.date_range,
                                                  color: Colors.blue[600],
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  fechaRecordatorio != null
                                                      ? DateFormat(
                                                        "d 'de' MMMM, yyyy",
                                                        "es_ES",
                                                      ).format(
                                                        fechaRecordatorio!,
                                                      )
                                                      : "Seleccionar fecha",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.blue[400],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Hora del recordatorio
                                      _buildFormField(
                                        label: "Hora del recordatorio",
                                        icon: Icons.access_time,
                                        child: InkWell(
                                          onTap: () async {
                                            final pickedTime =
                                                await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                );
                                            if (pickedTime != null) {
                                              setModalState(() {
                                                horaRecordatorio =
                                                    "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.blue[300]!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.schedule,
                                                  color: Colors.blue[600],
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  horaRecordatorio ??
                                                      "Seleccionar hora",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.blue[400],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.grey[300] ?? Colors.grey,
                                  ),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancelar",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.blue[600] ?? Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed:
                                  () => _procesarFormularioTarea(
                                    formKey: formKey,
                                    esEdicion: false,
                                    titulo: titulo,
                                    descripcion: descripcion,
                                    fecha: fecha,
                                    prioridad: prioridad,
                                    categoria: categoria,
                                    recordatorioActivo: recordatorioActivo,
                                    emailRecordatorio: emailRecordatorio,
                                    fechaRecordatorio: fechaRecordatorio,
                                    horaRecordatorio: horaRecordatorio,
                                  ),
                              child: const Text(
                                "Crear Tarea",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() => _fabAnimationController.reverse());
  }

  // FORMULARIO PARA EDITAR TAREA EXISTENTE
  Future<void> _mostrarFormularioEditarTarea(
    Map<String, dynamic> tareaExistente,
  ) async {
    final formKey = GlobalKey<FormState>();
    String titulo = tareaExistente['titulo']?.toString() ?? "";
    String descripcion = tareaExistente['descripcion']?.toString() ?? "";
    DateTime fecha = DateTime.parse(
      tareaExistente['fecha'] ?? DateTime.now().toIso8601String(),
    );
    String prioridad = tareaExistente['prioridad']?.toString() ?? "media";
    String categoria = tareaExistente['categoria']?.toString() ?? "personal";

    bool recordatorioActivo = tareaExistente['recordatorio_activo'] == true;
    DateTime? fechaRecordatorio;
    String? horaRecordatorio = tareaExistente['hora_recordatorio']?.toString();
    String? emailRecordatorio =
        tareaExistente['email_recordatorio']?.toString();

    // Parsear fecha de recordatorio si existe
    if (tareaExistente['fecha_recordatorio'] != null) {
      try {
        fechaRecordatorio = DateTime.parse(
          tareaExistente['fecha_recordatorio'].toString(),
        );
      } catch (e) {
        fechaRecordatorio = null;
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 24,
                  right: 24,
                  top: 20,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.orange[600],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Text(
                            "Editar Tarea",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TÃ­tulo
                              _buildFormField(
                                label: "Titulo",
                                icon: Icons.title,
                                child: TextFormField(
                                  initialValue: titulo,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: _inputDecoration(
                                    "Ingresa el titulo de la tarea",
                                  ),
                                  validator:
                                      (v) =>
                                          v == null || v.isEmpty
                                              ? "Campo requerido"
                                              : null,
                                  onChanged: (v) => titulo = v,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // DescripciÃ³n
                              _buildFormField(
                                label: "Descripcion",
                                icon: Icons.description,
                                child: TextFormField(
                                  initialValue: descripcion,
                                  style: const TextStyle(fontSize: 16),
                                  maxLines: 3,
                                  decoration: _inputDecoration(
                                    "Describe los detalles (opcional)",
                                  ),
                                  onChanged: (v) => descripcion = v ?? "",
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Fecha
                              _buildFormField(
                                label: "Fecha",
                                icon: Icons.calendar_today,
                                child: InkWell(
                                  onTap: () async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: fecha,
                                      firstDate: DateTime.now().subtract(
                                        const Duration(days: 365),
                                      ),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                    );
                                    if (pickedDate != null) {
                                      setModalState(() => fecha = pickedDate);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300] ?? Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.date_range,
                                          color: Colors.grey[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          DateFormat(
                                            "d 'de' MMMM, yyyy",
                                            "es_ES",
                                          ).format(fecha),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Prioridad y CategorÃ­a
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormField(
                                      label: "Prioridad",
                                      icon: Icons.priority_high,
                                      child: DropdownButtonFormField<String>(
                                        value: prioridad,
                                        decoration: _inputDecoration(""),
                                        items: const [
                                          DropdownMenuItem(
                                            value: "baja",
                                            child: Text("Baja"),
                                          ),
                                          DropdownMenuItem(
                                            value: "media",
                                            child: Text("Media"),
                                          ),
                                          DropdownMenuItem(
                                            value: "alta",
                                            child: Text("Alta"),
                                          ),
                                        ],
                                        onChanged:
                                            (v) => setModalState(
                                              () => prioridad = v ?? "media",
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: _buildFormField(
                                      label: "Categoria",
                                      icon: Icons.category,
                                      child: DropdownButtonFormField<String>(
                                        value: categoria,
                                        decoration: _inputDecoration(""),
                                        items: const [
                                          DropdownMenuItem(
                                            value: "personal",
                                            child: Text("Personal"),
                                          ),
                                          DropdownMenuItem(
                                            value: "trabajo",
                                            child: Text("Trabajo"),
                                          ),
                                          DropdownMenuItem(
                                            value: "salud",
                                            child: Text("Salud"),
                                          ),
                                          DropdownMenuItem(
                                            value: "hogar",
                                            child: Text("Hogar"),
                                          ),
                                          DropdownMenuItem(
                                            value: "estudio",
                                            child: Text("Estudio"),
                                          ),
                                          DropdownMenuItem(
                                            value: "otro",
                                            child: Text("Otro"),
                                          ),
                                        ],
                                        onChanged:
                                            (v) => setModalState(
                                              () => categoria = v ?? "personal",
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              // SecciÃ³n de recordatorio
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.email,
                                          color: Colors.blue[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Recordatorio por Email",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Switch(
                                          value: recordatorioActivo,
                                          activeColor: Colors.blue[600],
                                          onChanged:
                                              (value) => setModalState(
                                                () =>
                                                    recordatorioActivo = value,
                                              ),
                                        ),
                                      ],
                                    ),

                                    if (recordatorioActivo) ...[
                                      const SizedBox(height: 20),

                                      // Campo de email
                                      _buildFormField(
                                        label: "Correo electronico",
                                        icon: Icons.email_outlined,
                                        child: TextFormField(
                                          initialValue: emailRecordatorio,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: const TextStyle(fontSize: 16),
                                          decoration: _inputDecoration(
                                            "ejemplo@gmail.com",
                                          ),
                                          validator:
                                              recordatorioActivo
                                                  ? (v) {
                                                    if (v == null || v.isEmpty)
                                                      return "Campo requerido";
                                                    if (!RegExp(
                                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                    ).hasMatch(v)) {
                                                      return "Email invÃ¡lido";
                                                    }
                                                    return null;
                                                  }
                                                  : null,
                                          onChanged:
                                              (v) => emailRecordatorio = v,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Fecha del recordatorio
                                      _buildFormField(
                                        label: "Fecha del recordatorio",
                                        icon: Icons.calendar_today,
                                        child: InkWell(
                                          onTap: () async {
                                            final pickedDate =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      fechaRecordatorio ??
                                                      fecha,
                                                  firstDate: DateTime.now(),
                                                  lastDate: DateTime.now().add(
                                                    const Duration(days: 365),
                                                  ),
                                                );
                                            if (pickedDate != null) {
                                              setModalState(
                                                () =>
                                                    fechaRecordatorio =
                                                        pickedDate,
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.blue[300]!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.date_range,
                                                  color: Colors.blue[600],
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  fechaRecordatorio != null
                                                      ? DateFormat(
                                                        "d 'de' MMMM, yyyy",
                                                        "es_ES",
                                                      ).format(
                                                        fechaRecordatorio!,
                                                      )
                                                      : "Seleccionar fecha",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.blue[400],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      _buildFormField(
                                        label: "Hora del recordatorio",
                                        icon: Icons.access_time,
                                        child: InkWell(
                                          onTap: () async {
                                            TimeOfDay? initialTime;
                                            if (horaRecordatorio != null) {
                                              final parts = horaRecordatorio!
                                                  .split(':');
                                              initialTime = TimeOfDay(
                                                hour: int.parse(parts[0]),
                                                minute: int.parse(parts[1]),
                                              );
                                            }
                                            final pickedTime =
                                                await showTimePicker(
                                                  context: context,
                                                  initialTime:
                                                      initialTime ??
                                                      TimeOfDay.now(),
                                                );
                                            if (pickedTime != null) {
                                              setModalState(() {
                                                horaRecordatorio =
                                                    "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.blue[300]!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.schedule,
                                                  color: Colors.blue[600],
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  horaRecordatorio ??
                                                      "Seleccionar hora",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.blue[400],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancelar",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed:
                                  () => _procesarFormularioTarea(
                                    formKey: formKey,
                                    esEdicion: true,
                                    tareaId: tareaExistente['id'],
                                    titulo: titulo,
                                    descripcion: descripcion,
                                    fecha: fecha,
                                    prioridad: prioridad,
                                    categoria: categoria,
                                    recordatorioActivo: recordatorioActivo,
                                    emailRecordatorio: emailRecordatorio,
                                    fechaRecordatorio: fechaRecordatorio,
                                    horaRecordatorio: horaRecordatorio,
                                  ),
                              child: const Text(
                                "Actualizar Tarea",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // FUNCIÃ“N UNIFICADA PARA PROCESAR FORMULARIOS (CREAR Y EDITAR)
  Future<void> _procesarFormularioTarea({
  required GlobalKey<FormState> formKey,
  required bool esEdicion,
  int? tareaId,
  required String titulo,
  required String descripcion,
  required DateTime fecha,
  required String prioridad,
  required String categoria,
  required bool recordatorioActivo,
  String? emailRecordatorio,
  DateTime? fechaRecordatorio,
  String? horaRecordatorio,
}) async {
  if (!formKey.currentState!.validate()) return;

  // Validaciones de recordatorio
  if (recordatorioActivo) {
    if (fechaRecordatorio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Selecciona la fecha del recordatorio"),
          backgroundColor: Colors.orange[400],
        ),
      );
      return;
    }
    if (horaRecordatorio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Selecciona la hora del recordatorio"),
          backgroundColor: Colors.orange[400],
        ),
      );
      return;
    }

    // Validar fecha/hora no estÃ© en el pasado
    final fechaHoraRecordatorio = DateTime(
      fechaRecordatorio.year,
      fechaRecordatorio.month,
      fechaRecordatorio.day,
      int.parse(horaRecordatorio.split(':')[0]),
      int.parse(horaRecordatorio.split(':')[1]),
    );

    if (fechaHoraRecordatorio.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "La fecha/hora del recordatorio no puede ser en el pasado",
          ),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }
  }

  try {
    // Preparar datos
    final tareaData = {
      "titulo": titulo,
      "descripcion": descripcion,
      "fecha": fecha.toIso8601String().split("T")[0],
      "prioridad": prioridad,
      "categoria": categoria,
      "recordatorio_activo": recordatorioActivo,
      "email_recordatorio": recordatorioActivo ? emailRecordatorio : null,
      "fecha_recordatorio":
          recordatorioActivo && fechaRecordatorio != null
              ? fechaRecordatorio.toIso8601String().split("T")[0]
              : null,
      "hora_recordatorio": recordatorioActivo ? horaRecordatorio : null,
    };

    // Llamar API
    Map<String, dynamic> respuesta;
    if (esEdicion && tareaId != null) {
      RecordatorioScheduler.cancelarRecordatorio(tareaId.toString());
      respuesta = await ApiService.updateTarea(tareaId, tareaData);
    } else {
      respuesta = await ApiService.addTarea(tareaData);
    }

    if (!mounted) return;

    // ðŸ”¥ PROGRAMAR RECORDATORIO
    if (recordatorioActivo && respuesta['success'] == true) {
      try {
        // Obtener tarea de la respuesta o usar los datos enviados
        final tareaParaRecordatorio = respuesta['tarea'] ?? {
          ...tareaData,
          'id': tareaId ?? 0, // Si es nueva, se asignarÃ¡ despuÃ©s
        };

        await RecordatorioScheduler.programarRecordatorio(
          tarea: tareaParaRecordatorio,
          onEnviado: () {
            debugPrint('Recordatorio enviado: $titulo');
          },
          onError: (error) {
            debugPrint(' Error en recordatorio: $error');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Recordatorio programado con advertencia'),
                  backgroundColor: Colors.orange[400],
                ),
              );
            }
          },
        );
        
        debugPrint(' Recordatorio programado exitosamente');
      } catch (e) {
        debugPrint('Error programando recordatorio: $e');
        // No fallar si el recordatorio falla
      }
    }

    if (mounted) {
      Navigator.pop(context);
      _loadData();
      _loadAllTasks();

      final accion = esEdicion ? "actualizada" : "creada";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarea $accion exitosamente'),
          backgroundColor: Colors.green[400],
        ),
      );
    }
  } catch (e) {
    debugPrint(' Error en _procesarFormularioTarea: $e');
    if (mounted) {
      final accion = esEdicion ? "actualizar" : "crear";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al $accion tarea: $e'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }
}
  // Helper methods para el formulario
  Widget _buildFormField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[400]!),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[400]!, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}