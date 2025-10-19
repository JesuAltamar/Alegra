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
          // Ignorar errores de días individuales
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
              "¿Estás seguro? Esto también cancelará el recordatorio si existe.",
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

  // 🆕 MOSTRAR MODAL CON TAREAS DE UNA FECHA ESPECÍFICA
  void _mostrarTareasDelDia(DateTime fecha) async {
    final fechaStr = DateFormat("yyyy-MM-dd").format(fecha);
    
    try {
      final tareasDia = await ApiService.getTareas(fecha: fechaStr);
      
      if (!mounted) return;
      
      if (tareasDia.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No hay tareas para ${DateFormat("d 'de' MMMM", "es_ES").format(fecha)}"),
            backgroundColor: const Color(0xFFFFA000),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      final screenWidth = MediaQuery.of(context).size.width;
      final isMobile = screenWidth <= 600;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A73E8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_note,
                        color: Color(0xFF1A73E8),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat("d 'de' MMMM", "es_ES").format(fecha),
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "${tareasDia.length} tarea${tareasDia.length != 1 ? 's' : ''}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Lista de tareas
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  itemCount: tareasDia.length,
                  itemBuilder: (context, index) {
                    final tarea = tareasDia[index];
                    return _buildTaskItemCompact(tarea, isMobile);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error cargando tareas: $e"),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  Widget _buildTaskItemCompact(dynamic t, bool isMobile) {
    if (t == null) return const SizedBox.shrink();

    final completada = (t["estado"]?.toString() ?? "").toLowerCase() == "completada";
    final titulo = t["titulo"]?.toString() ?? "(Sin título)";
    final descripcion = t["descripcion"]?.toString() ?? "";
    final categoria = t["categoria"]?.toString() ?? "personal";
    final prioridad = t["prioridad"]?.toString() ?? "media";
    final id = t["id"];
    final recordatorioActivo = t["recordatorio_activo"] == true;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: completada ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completada ? const Color(0xFF4CAF50) : const Color(0xFF1A73E8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (completada ? const Color(0xFF4CAF50) : const Color(0xFF1A73E8)).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: completada,
            activeColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (val) => _toggleCompletar(id, val ?? false),
          ),
          const SizedBox(width: 8),
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
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: completada ? Colors.grey[600] : Colors.black87,
                          decoration: completada ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (recordatorioActivo)
                      const Icon(
                        Icons.notifications_active,
                        size: 16,
                        color: Color(0xFFFFA000),
                      ),
                  ],
                ),
                if (descripcion.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chip(
                      categoria,
                      _getCategoryColor(categoria),
                      _getCategoryIcon(categoria),
                    ),
                    _chip(
                      prioridad,
                      _getPriorityColor(prioridad),
                      _getPriorityIcon(prioridad),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF1A73E8),
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
              if (id != null) {
                _mostrarFormularioEditarTarea(t);
              }
            },
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares para UI
  Color _getEventColor(List events) {
    if (events.isEmpty) return Colors.grey;
    bool hasCompleted = events.any(
      (e) => e != null && (e["estado"]?.toString() ?? "") == "completada",
    );
    bool hasPending = events.any(
      (e) => e != null && (e["estado"]?.toString() ?? "") != "completada",
    );
    if (hasCompleted && hasPending) return const Color(0xFFFFA000);
    if (hasCompleted) return const Color(0xFF4CAF50);
    return const Color(0xFFE53935);
  }

  Color _getCategoryColor(String? categoria) {
    switch (categoria?.toLowerCase() ?? "") {
      case "trabajo":
        return const Color(0xFF1A73E8);
      case "personal":
        return const Color(0xFF9C27B0);
      case "salud":
        return const Color(0xFFE53935);
      case "hogar":
        return const Color(0xFF4CAF50);
      case "estudio":
        return const Color(0xFFFFA000);
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
        return const Color(0xFFE53935);
      case "media":
        return const Color(0xFFFFA000);
      case "baja":
        return const Color(0xFF4CAF50);
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

  // 🆕 ESTADÍSTICAS COMPACTAS EN LÍNEA HORIZONTAL
  Widget _statBox(String label, int value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              "$value",
              style: TextStyle(
                fontSize: 24,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text.isEmpty ? "Sin definir" : text,
            style: TextStyle(
              color: color,
              fontSize: 11,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    final recordatoriosActivos = RecordatorioScheduler.recordatoriosActivos;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(
              child: Text(
                "Lista de Tareas",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // 🔔 CAMPANITA SIN EL NÚMERO 0
            if (recordatoriosActivos > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFA000)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.notifications_active,
                      size: 18,
                      color: Color(0xFFFFA000),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$recordatoriosActivos',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFA000),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Icon(
                Icons.notifications_outlined,
                size: 24,
                color: Color(0xFFFFA000),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🆕 ESTADÍSTICAS EN UNA LÍNEA HORIZONTAL
            Container(
              margin: EdgeInsets.all(isMobile ? 16 : 20),
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE3F2FD),
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A73E8).withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _statBox(
                    "Completadas",
                    _getStatValue("completadas"),
                    const Color(0xFF4CAF50),
                    Icons.check_circle,
                  ),
                  const SizedBox(width: 12),
                  _statBox(
                    "Total",
                    _getStatValue("total"),
                    const Color(0xFF1A73E8),
                    Icons.list_alt,
                  ),
                  const SizedBox(width: 12),
                  _statBox(
                    "Recordatorios",
                    _getStatValue("recordatorios"),
                    const Color(0xFFFFA000),
                    Icons.notifications,
                  ),
                ],
              ),
            ),
            
            // Calendario
            Container(
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
              padding: EdgeInsets.all(isMobile ? 8 : 16),
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
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  
                  // 🆕 Mostrar modal con tareas si hay tareas en esa fecha
                  final tareasDelDia = _getEventsForDay(selectedDay);
                  if (tareasDelDia.isNotEmpty) {
                    _mostrarTareasDelDia(selectedDay);
                  } else {
                    _loadData();
                  }
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
                        right: 4,
                        top: 4,
                        child: Container(
                          width: isMobile ? 6 : 8,
                          height: isMobile ? 6 : 8,
                          decoration: BoxDecoration(
                            color: _getEventColor(events),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getEventColor(events).withOpacity(0.5),
                                blurRadius: 3,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF1A73E8),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: const BoxDecoration(
                    color: Color(0xFFFFA000),
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: const TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 14,
                  ),
                  defaultTextStyle: const TextStyle(
                    fontSize: 14,
                  ),
                  outsideDaysVisible: false,
                  markersMaxCount: 1,
                  cellMargin: EdgeInsets.all(isMobile ? 3 : 4),
                  cellPadding: EdgeInsets.all(isMobile ? 0 : 2),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF1A73E8),
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF1A73E8),
                  ),
                  headerPadding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 16),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontSize: isMobile ? 11 : 14),
                  weekendStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE53935),
                  ),
                ),
                daysOfWeekHeight: isMobile ? 30 : 40,
                rowHeight: isMobile ? 48 : 52,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(isMobile),
    );
  }

  Widget _buildFloatingActionButton(bool isMobile) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.8).animate(
        CurvedAnimation(
          parent: _fabAnimationController,
          curve: Curves.easeInOut,
        ),
      ),
      child: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _mostrarFormularioNuevaTarea,
        icon: Icon(Icons.add, color: Colors.white, size: isMobile ? 20 : 24),
        label: Text(
          isMobile ? "Nueva" : "Nueva Tarea",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 14 : 16,
          ),
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
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobile = screenWidth <= 600;
            
            return Container(
              height: screenHeight * (isMobile ? 0.95 : 0.9),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: isMobile ? 16 : 24,
                  right: isMobile ? 16 : 24,
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
                            padding: EdgeInsets.all(isMobile ? 10 : 12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.add_task,
                              color: Colors.blue[600],
                              size: isMobile ? 20 : 24,
                            ),
                          ),
                          SizedBox(width: isMobile ? 12 : 15),
                          Text(
                            "Nueva Tarea",
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 20 : 30),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título
                              _buildFormField(
                                label: "Título",
                                icon: Icons.title,
                                isMobile: isMobile,
                                child: TextFormField(
                                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                                  decoration: _inputDecoration(
                                    "Ingresa el título de la tarea",
                                    isMobile,
                                  ),
                                  validator:
                                      (v) =>
                                          v == null || v.isEmpty
                                              ? "Campo requerido"
                                              : null,
                                  onChanged: (v) => titulo = v,
                                ),
                              ),
                              SizedBox(height: isMobile ? 16 : 20),

                              // Descripción
                              _buildFormField(
                                label: "Descripción",
                                icon: Icons.description,
                                isMobile: isMobile,
                                child: TextFormField(
                                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                                  maxLines: 3,
                                  decoration: _inputDecoration(
                                    "Describe los detalles (opcional)",
                                    isMobile,
                                  ),
                                  onChanged: (v) => descripcion = v,
                                ),
                              ),
                              SizedBox(height: isMobile ? 16 : 20),

                              // Fecha
                              _buildFormField(
                                label: "Fecha",
                                icon: Icons.calendar_today,
                                isMobile: isMobile,
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
                                    padding: EdgeInsets.symmetric(
                                      vertical: isMobile ? 14 : 16,
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
                                          style: TextStyle(fontSize: isMobile ? 14 : 16),
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
                              SizedBox(height: isMobile ? 16 : 20),

                              // Prioridad y Categoría
                              isMobile
                                  ? Column(
                                      children: [
                                        _buildFormField(
                                          label: "Prioridad",
                                          icon: Icons.priority_high,
                                          isMobile: isMobile,
                                          child: DropdownButtonFormField<String>(
                                            value: prioridad,
                                            decoration: _inputDecoration("", isMobile),
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
                                        const SizedBox(height: 16),
                                        _buildFormField(
                                          label: "Categoría",
                                          icon: Icons.category,
                                          isMobile: isMobile,
                                          child: DropdownButtonFormField<String>(
                                            value: categoria,
                                            decoration: _inputDecoration("", isMobile),
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
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: _buildFormField(
                                            label: "Prioridad",
                                            icon: Icons.priority_high,
                                            isMobile: isMobile,
                                            child: DropdownButtonFormField<String>(
                                              value: prioridad,
                                              decoration: _inputDecoration("", isMobile),
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
                                            label: "Categoría",
                                            icon: Icons.category,
                                            isMobile: isMobile,
                                            child: DropdownButtonFormField<String>(
                                              value: categoria,
                                              decoration: _inputDecoration("", isMobile),
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
                              SizedBox(height: isMobile ? 20 : 30),

                              // Sección de recordatorio por email
                              Container(
                                padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                                          size: isMobile ? 18 : 20,
                                        ),
                                        SizedBox(width: isMobile ? 6 : 8),
                                        Expanded(
                                          child: Text(
                                            "Recordatorio por Email",
                                            style: TextStyle(
                                              fontSize: isMobile ? 16 : 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
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
                                        fontSize: isMobile ? 12 : 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),

                                    if (recordatorioActivo) ...[
                                      SizedBox(height: isMobile ? 16 : 20),

                                      // Campo de email
                                      _buildFormField(
                                        label: "Correo electrónico",
                                        icon: Icons.email_outlined,
                                        isMobile: isMobile,
                                        child: TextFormField(
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: TextStyle(fontSize: isMobile ? 14 : 16),
                                          decoration: _inputDecoration(
                                            "ejemplo@gmail.com",
                                            isMobile,
                                          ),
                                          validator:
                                              recordatorioActivo
                                                  ? (v) {
                                                    if (v == null || v.isEmpty)
                                                      return "Campo requerido";
                                                    if (!RegExp(
                                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                    ).hasMatch(v)) {
                                                      return "Email inválido";
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
                                        isMobile: isMobile,
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
                                            padding: EdgeInsets.symmetric(
                                              vertical: isMobile ? 14 : 16,
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
                                                  style: TextStyle(
                                                    fontSize: isMobile ? 14 : 16,
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
                                        isMobile: isMobile,
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
                                            padding: EdgeInsets.symmetric(
                                              vertical: isMobile ? 14 : 16,
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
                                                  style: TextStyle(
                                                    fontSize: isMobile ? 14 : 16,
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
                              SizedBox(height: isMobile ? 20 : 30),
                            ],
                          ),
                        ),
                      ),
                      // Botones
                      isMobile
                          ? Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
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
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
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
                              ],
                            )
                          : Row(
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
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobile = screenWidth <= 600;
            
            return Container(
              height: screenHeight * (isMobile ? 0.95 : 0.9),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: isMobile ? 16 : 24,
                  right: isMobile ? 16 : 24,
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
                            padding: EdgeInsets.all(isMobile ? 10 : 12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.orange[600],
                              size: isMobile ? 20 : 24,
                            ),
                          ),
                          SizedBox(width: isMobile ? 12 : 15),
                          Text(
                            "Editar Tarea",
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 20 : 30),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título
                              _buildFormField(
                                label: "Título",
                                icon: Icons.title,
                                isMobile: isMobile,
                                child: TextFormField(
                                  initialValue: titulo,
                                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                                  decoration: _inputDecoration(
                                    "Ingresa el título de la tarea",
                                    isMobile,
                                  ),
                                  validator:(v) =>
                                          v == null || v.isEmpty
                                              ? "Campo requerido"
                                              : null,
                                  onChanged: (v) => titulo = v,
                                ),
                              ),
                              SizedBox(height: isMobile ? 16 : 20),

                              // Descripción
                              _buildFormField(
                                label: "Descripción",
                                icon: Icons.description,
                                isMobile: isMobile,
                                child: TextFormField(
                                  initialValue: descripcion,
                                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                                  maxLines: 3,
                                  decoration: _inputDecoration(
                                    "Describe los detalles (opcional)",
                                    isMobile,
                                  ),
                                  onChanged: (v) => descripcion = v ?? "",
                                ),
                              ),
                              SizedBox(height: isMobile ? 16 : 20),

                              // Fecha
                              _buildFormField(
                                label: "Fecha",
                                icon: Icons.calendar_today,
                                isMobile: isMobile,
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
                                    padding: EdgeInsets.symmetric(
                                      vertical: isMobile ? 14 : 16,
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
                                          style: TextStyle(fontSize: isMobile ? 14 : 16),
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
                              SizedBox(height: isMobile ? 16 : 20),

                              // Prioridad y Categoría
                              isMobile
                                  ? Column(
                                      children: [
                                        _buildFormField(
                                          label: "Prioridad",
                                          icon: Icons.priority_high,
                                          isMobile: isMobile,
                                          child: DropdownButtonFormField<String>(
                                            value: prioridad,
                                            decoration: _inputDecoration("", isMobile),
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
                                        const SizedBox(height: 16),
                                        _buildFormField(
                                          label: "Categoría",
                                          icon: Icons.category,
                                          isMobile: isMobile,
                                          child: DropdownButtonFormField<String>(
                                            value: categoria,
                                            decoration: _inputDecoration("", isMobile),
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
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: _buildFormField(
                                            label: "Prioridad",
                                            icon: Icons.priority_high,
                                            isMobile: isMobile,
                                            child: DropdownButtonFormField<String>(
                                              value: prioridad,
                                              decoration: _inputDecoration("", isMobile),
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
                                            label: "Categoría",
                                            icon: Icons.category,
                                            isMobile: isMobile,
                                            child: DropdownButtonFormField<String>(
                                              value: categoria,
                                              decoration: _inputDecoration("", isMobile),
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
                              SizedBox(height: isMobile ? 20 : 30),

                              // Sección de recordatorio
                              Container(
                                padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                                          size: isMobile ? 18 : 20,
                                        ),
                                        SizedBox(width: isMobile ? 6 : 8),
                                        Expanded(
                                          child: Text(
                                            "Recordatorio por Email",
                                            style: TextStyle(
                                              fontSize: isMobile ? 16 : 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
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
                                      SizedBox(height: isMobile ? 16 : 20),

                                      // Campo de email
                                      _buildFormField(
                                        label: "Correo electrónico",
                                        icon: Icons.email_outlined,
                                        isMobile: isMobile,
                                        child: TextFormField(
                                          initialValue: emailRecordatorio,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: TextStyle(fontSize: isMobile ? 14 : 16),
                                          decoration: _inputDecoration(
                                            "ejemplo@gmail.com",
                                            isMobile,
                                          ),
                                          validator:
                                              recordatorioActivo
                                                  ? (v) {
                                                    if (v == null || v.isEmpty)
                                                      return "Campo requerido";
                                                    if (!RegExp(
                                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                    ).hasMatch(v)) {
                                                      return "Email inválido";
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
                                        isMobile: isMobile,
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
                                            padding: EdgeInsets.symmetric(
                                              vertical: isMobile ? 14 : 16,
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
                                                  style: TextStyle(
                                                    fontSize: isMobile ? 14 : 16,
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
                                        isMobile: isMobile,
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
                                            padding: EdgeInsets.symmetric(
                                              vertical: isMobile ? 14 : 16,
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
                                                  style: TextStyle(
                                                    fontSize: isMobile ? 14 : 16,
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
                              SizedBox(height: isMobile ? 20 : 30),
                            ],
                          ),
                        ),
                      ),
                      // Botones
                      isMobile
                          ? Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
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
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "Cancelar",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
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

  // FUNCIÓN UNIFICADA PARA PROCESAR FORMULARIOS (CREAR Y EDITAR)
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

      // Validar fecha/hora no esté en el pasado
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

      // 🔥 PROGRAMAR RECORDATORIO
      if (recordatorioActivo && respuesta['success'] == true) {
        try {
          // Obtener tarea de la respuesta o usar los datos enviados
          final tareaParaRecordatorio = respuesta['tarea'] ?? {
            ...tareaData,
            'id': tareaId ?? 0,
          };

          await RecordatorioScheduler.programarRecordatorio(
            tarea: tareaParaRecordatorio,
            onEnviado: () {
              debugPrint('✅ Recordatorio enviado: $titulo');
            },
            onError: (error) {
              debugPrint('❌ Error en recordatorio: $error');
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
          
          debugPrint('✅ Recordatorio programado exitosamente');
        } catch (e) {
          debugPrint('❌ Error programando recordatorio: $e');
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
      debugPrint('❌ Error en _procesarFormularioTarea: $e');
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
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: isMobile ? 14 : 16, color: Colors.grey[600]),
            SizedBox(width: isMobile ? 4 : 6),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 6 : 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, bool isMobile) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: isMobile ? 12 : 14,
      ),
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
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 10 : 12,
      ),
    );
  }
}
