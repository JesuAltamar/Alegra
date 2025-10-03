import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pro9/services/api_service.dart';
import 'package:pro9/services/recordatorio_scheduler.dart';

class AdminTareasPage extends StatefulWidget {
  const AdminTareasPage({super.key});

  @override
  State<AdminTareasPage> createState() => _AdminTareasPageState();
}

class _AdminTareasPageState extends State<AdminTareasPage>
    with TickerProviderStateMixin {
  bool isDarkMode = false;
  String filtroSeleccionado = 'Todas';
  String busquedaTerm = '';
  List<dynamic> todasLasTareas = [];
  Map<String, dynamic> estadisticasGlobales = {};
  bool isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

  // Métricas de administrador
  int totalTareas = 0;
  int tareasCompletadas = 0;
  int tareasPendientes = 0;
  int recordatoriosActivos = 0;
  int tareasVencidas = 0;
  Map<String, int> tareasPorUsuario = {};
  Map<String, int> tareasPorCategoria = {};

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _loadAdminData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() => isLoading = true);

    try {
      // Cargar todas las tareas de todos los usuarios
      final allTasks =
          await ApiService.getAllTareasAdmin(); // Necesitarás crear este método
      final stats = await ApiService.getEstadisticasAdmin(); // Y este también

      if (mounted) {
        setState(() {
          todasLasTareas = allTasks;
          estadisticasGlobales = stats;
          _calculateMetrics();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showError('Error cargando datos: $e');
      }
    }
  }

  void _calculateMetrics() {
    totalTareas = todasLasTareas.length;
    tareasCompletadas =
        todasLasTareas.where((t) => t['estado'] == 'completada').length;
    tareasPendientes = totalTareas - tareasCompletadas;
    recordatoriosActivos =
        todasLasTareas.where((t) => t['recordatorio_activo'] == true).length;

    // Calcular tareas vencidas
    final now = DateTime.now();
    tareasVencidas =
        todasLasTareas.where((t) {
          if (t['estado'] == 'completada') return false;
          try {
            final fechaTarea = DateTime.parse(t['fecha']);
            return fechaTarea.isBefore(DateTime(now.year, now.month, now.day));
          } catch (e) {
            return false;
          }
        }).length;

    // Calcular tareas por usuario
    tareasPorUsuario.clear();
    for (final tarea in todasLasTareas) {
      final usuario = tarea['usuario_nombre'] ?? 'Usuario desconocido';
      tareasPorUsuario[usuario] = (tareasPorUsuario[usuario] ?? 0) + 1;
    }

    // Calcular tareas por categoría
    tareasPorCategoria.clear();
    for (final tarea in todasLasTareas) {
      final categoria = tarea['categoria'] ?? 'personal';
      tareasPorCategoria[categoria] = (tareasPorCategoria[categoria] ?? 0) + 1;
    }
  }

  List<dynamic> get tareasFiltradas {
    var tareas =
        todasLasTareas.where((tarea) {
          // Filtro por estado
          switch (filtroSeleccionado) {
            case 'Completadas':
              if (tarea['estado'] != 'completada') return false;
              break;
            case 'Pendientes':
              if (tarea['estado'] == 'completada') return false;
              break;
            case 'Con Recordatorio':
              if (tarea['recordatorio_activo'] != true) return false;
              break;
            case 'Vencidas':
              if (tarea['estado'] == 'completada') return false;
              try {
                final fechaTarea = DateTime.parse(tarea['fecha']);
                final now = DateTime.now();
                if (!fechaTarea.isBefore(
                  DateTime(now.year, now.month, now.day),
                ))
                  return false;
              } catch (e) {
                return false;
              }
              break;
          }

          // Filtro por búsqueda
          if (busquedaTerm.isNotEmpty) {
            final titulo = tarea['titulo']?.toString().toLowerCase() ?? '';
            final descripcion =
                tarea['descripcion']?.toString().toLowerCase() ?? '';
            final usuario =
                tarea['usuario_nombre']?.toString().toLowerCase() ?? '';
            final busqueda = busquedaTerm.toLowerCase();

            if (!titulo.contains(busqueda) &&
                !descripcion.contains(busqueda) &&
                !usuario.contains(busqueda)) {
              return false;
            }
          }

          return true;
        }).toList();

    // Ordenar por fecha (más recientes primero)
    tareas.sort((a, b) {
      try {
        final fechaA = DateTime.parse(a['fecha'] ?? '');
        final fechaB = DateTime.parse(b['fecha'] ?? '');
        return fechaB.compareTo(fechaA);
      } catch (e) {
        return 0;
      }
    });

    return tareas;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AlegraColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 768;

    return Scaffold(
      backgroundColor: AlegraColors.getBackground(isDarkMode),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDarkMode
                  ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  )
                  : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFAFBFF), Color(0xFFF8FAFC)],
                  ),
        ),
        child: Column(
          children: [
            _buildAppBar(isTablet),
            Expanded(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child:
                        isLoading
                            ? _buildLoadingState()
                            : _buildContent(isTablet),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        border: Border(
          bottom: BorderSide(
            color: AlegraColors.getBorder(isDarkMode),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AlegraColors.getCard(isDarkMode),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AlegraColors.getBorder(isDarkMode),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: AlegraColors.getTextPrimary(isDarkMode),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AlegraColors.gradientGreen,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AlegraColors.success.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Gestión de Tareas',
                        style: GoogleFonts.inter(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w700,
                          color: AlegraColors.getTextPrimary(isDarkMode),
                        ),
                      ),
                      Text(
                        'Panel Administrativo',
                        style: GoogleFonts.inter(
                          fontSize: isTablet ? 14 : 12,
                          color: AlegraColors.getTextSecondary(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AlegraColors.getCard(isDarkMode),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AlegraColors.getBorder(isDarkMode),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color:
                      isDarkMode ? AlegraColors.warning : AlegraColors.primary,
                ),
                onPressed: () => setState(() => isDarkMode = !isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AlegraColors.getSurface(isDarkMode),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AlegraColors.getBorder(isDarkMode)),
            ),
            child: CircularProgressIndicator(color: AlegraColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando datos administrativos...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AlegraColors.getTextSecondary(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsOverview(isTablet),
          const SizedBox(height: 24),
          _buildFiltersAndSearch(isTablet),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildTasksList(isTablet)),
              if (isTablet) ...[
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildAnalyticsSidebar()),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(bool isTablet) {
    final stats = [
      {
        'title': 'Total Tareas',
        'value': '$totalTareas',
        'icon': Icons.task_alt_rounded,
        'color': AlegraColors.primary,
      },
      {
        'title': 'Completadas',
        'value': '$tareasCompletadas',
        'icon': Icons.check_circle_rounded,
        'color': AlegraColors.success,
      },
      {
        'title': 'Pendientes',
        'value': '$tareasPendientes',
        'icon': Icons.pending_actions_rounded,
        'color': AlegraColors.warning,
      },
      {
        'title': 'Vencidas',
        'value': '$tareasVencidas',
        'icon': Icons.warning_rounded,
        'color': AlegraColors.accent,
      },
      {
        'title': 'Con Recordatorio',
        'value': '$recordatoriosActivos',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 5 : 2,
        childAspectRatio: isTablet ? 1.2 : 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AlegraColors.getSurface(isDarkMode),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AlegraColors.getBorder(isDarkMode),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (stat['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      stat['value'] as String,
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.w700,
                        color: AlegraColors.getTextPrimary(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AlegraColors.getTextSecondary(isDarkMode),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFiltersAndSearch(bool isTablet) {
    final filtros = [
      'Todas',
      'Completadas',
      'Pendientes',
      'Con Recordatorio',
      'Vencidas',
    ];

    return Column(
      children: [
        // Barra de búsqueda
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AlegraColors.getSurface(isDarkMode),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AlegraColors.getBorder(isDarkMode)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar tareas, usuarios...',
                    hintStyle: GoogleFonts.inter(
                      color: AlegraColors.getTextSecondary(isDarkMode),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AlegraColors.getTextSecondary(isDarkMode),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AlegraColors.getBorder(isDarkMode),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AlegraColors.getBorder(isDarkMode),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AlegraColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) => setState(() => busquedaTerm = value),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AlegraColors.gradientBlue,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _loadAdminData,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Filtros
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filtros.length,
            itemBuilder: (context, index) {
              final filtro = filtros[index];
              final isSelected = filtroSeleccionado == filtro;

              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => filtroSeleccionado = filtro),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient:
                            isSelected
                                ? const LinearGradient(
                                  colors: AlegraColors.gradientBlue,
                                )
                                : null,
                        color:
                            isSelected
                                ? null
                                : AlegraColors.getCard(isDarkMode),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors.transparent
                                  : AlegraColors.getBorder(isDarkMode),
                          width: 1,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: AlegraColors.primary.withOpacity(
                                      0.25,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Text(
                        filtro,
                        style: GoogleFonts.inter(
                          color:
                              isSelected
                                  ? Colors.white
                                  : AlegraColors.getTextSecondary(isDarkMode),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList(bool isTablet) {
    final tareas = tareasFiltradas;

    if (tareas.isEmpty) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: AlegraColors.getSurface(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AlegraColors.getBorder(isDarkMode)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_rounded,
                size: 64,
                color: AlegraColors.getTextSecondary(isDarkMode),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay tareas que coincidan con los filtros',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AlegraColors.getTextSecondary(isDarkMode),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.list_alt_rounded, color: AlegraColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Tareas del Sistema',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AlegraColors.getTextPrimary(isDarkMode),
                  ),
                ),
                const Spacer(),
                Text(
                  '${tareas.length} resultado${tareas.length != 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AlegraColors.getTextSecondary(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tareas.length,
            itemBuilder:
                (context, index) => _buildTaskItem(tareas[index], index),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> tarea, int index) {
    final completada =
        tarea['estado']?.toString().toLowerCase() == 'completada';
    final titulo = tarea['titulo']?.toString() ?? '(Sin título)';
    final descripcion = tarea['descripcion']?.toString() ?? '';
    final usuario =
        tarea['usuario_nombre']?.toString() ?? 'Usuario desconocido';
    final categoria = tarea['categoria']?.toString() ?? 'personal';
    final prioridad = tarea['prioridad']?.toString() ?? 'media';
    final recordatorioActivo = tarea['recordatorio_activo'] == true;

    DateTime? fechaTarea;
    bool esVencida = false;
    try {
      fechaTarea = DateTime.parse(tarea['fecha']);
      if (!completada) {
        final now = DateTime.now();
        esVencida = fechaTarea.isBefore(DateTime(now.year, now.month, now.day));
      }
    } catch (e) {
      fechaTarea = null;
    }

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    completada
                        ? AlegraColors.success.withOpacity(0.05)
                        : esVencida
                        ? AlegraColors.accent.withOpacity(0.05)
                        : AlegraColors.getCard(isDarkMode),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      completada
                          ? AlegraColors.success.withOpacity(0.3)
                          : esVencida
                          ? AlegraColors.accent.withOpacity(0.3)
                          : AlegraColors.getBorder(isDarkMode),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color:
                              completada
                                  ? AlegraColors.success.withOpacity(0.2)
                                  : esVencida
                                  ? AlegraColors.accent.withOpacity(0.2)
                                  : AlegraColors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          completada
                              ? Icons.check_circle
                              : esVencida
                              ? Icons.warning
                              : Icons.pending,
                          size: 16,
                          color:
                              completada
                                  ? AlegraColors.success
                                  : esVencida
                                  ? AlegraColors.accent
                                  : AlegraColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          titulo,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AlegraColors.getTextPrimary(isDarkMode),
                            decoration:
                                completada ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (recordatorioActivo)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AlegraColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.notifications_active,
                            size: 14,
                            color: AlegraColors.warning,
                          ),
                        ),
                    ],
                  ),

                  if (descripcion.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      descripcion,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AlegraColors.getTextSecondary(isDarkMode),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _buildChip(
                        usuario,
                        AlegraColors.primary,
                        Icons.person_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        categoria,
                        _getCategoryColor(categoria),
                        _getCategoryIcon(categoria),
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        prioridad,
                        _getPriorityColor(prioridad),
                        _getPriorityIcon(prioridad),
                      ),
                      const Spacer(),
                      if (fechaTarea != null)
                        Text(
                          DateFormat('dd/MM/yyyy').format(fechaTarea),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color:
                                esVencida
                                    ? AlegraColors.accent
                                    : AlegraColors.getTextSecondary(isDarkMode),
                            fontWeight:
                                esVencida ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text.isEmpty ? 'Sin definir' : text,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSidebar() {
    return Column(
      children: [
        // Tareas por usuario
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AlegraColors.getSurface(isDarkMode),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AlegraColors.getBorder(isDarkMode)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Usuarios',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AlegraColors.getTextPrimary(isDarkMode),
                ),
              ),
              const SizedBox(height: 16),
              ...tareasPorUsuario.entries
                  .take(5)
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AlegraColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key.length > 15
                                  ? '${entry.key.substring(0, 15)}...'
                                  : entry.key,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AlegraColors.getTextPrimary(isDarkMode),
                              ),
                            ),
                          ),
                          Text(
                            '${entry.value}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AlegraColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tareas por categoría
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AlegraColors.getSurface(isDarkMode),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AlegraColors.getBorder(isDarkMode)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categorías',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AlegraColors.getTextPrimary(isDarkMode),
                ),
              ),
              const SizedBox(height: 16),
              ...tareasPorCategoria.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(entry.key).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _getCategoryIcon(entry.key),
                          size: 14,
                          color: _getCategoryColor(entry.key),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AlegraColors.getTextPrimary(isDarkMode),
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(entry.key),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String? categoria) {
    switch (categoria?.toLowerCase() ?? "") {
      case "trabajo":
        return AlegraColors.primary;
      case "personal":
        return const Color(0xFF8B5CF6);
      case "salud":
        return AlegraColors.accent;
      case "hogar":
        return AlegraColors.success;
      case "estudio":
        return AlegraColors.warning;
      default:
        return AlegraColors.getTextSecondary(isDarkMode);
    }
  }

  IconData _getCategoryIcon(String? categoria) {
    switch (categoria?.toLowerCase() ?? "") {
      case "trabajo":
        return Icons.work_rounded;
      case "personal":
        return Icons.person_rounded;
      case "salud":
        return Icons.local_hospital_rounded;
      case "hogar":
        return Icons.home_rounded;
      case "estudio":
        return Icons.school_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  Color _getPriorityColor(String? prioridad) {
    switch (prioridad?.toLowerCase() ?? "") {
      case "alta":
        return AlegraColors.accent;
      case "media":
        return AlegraColors.warning;
      case "baja":
        return AlegraColors.success;
      default:
        return AlegraColors.getTextSecondary(isDarkMode);
    }
  }

  IconData _getPriorityIcon(String? prioridad) {
    switch (prioridad?.toLowerCase() ?? "") {
      case "alta":
        return Icons.priority_high_rounded;
      case "media":
        return Icons.remove_rounded;
      case "baja":
        return Icons.keyboard_arrow_down_rounded;
      default:
        return Icons.label_rounded;
    }
  }
}

// Clase de colores de Alegra (misma que en el dashboard)
class AlegraColors {
  static const Color primary = Color(0xFF0EA5E9);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFFEC4899);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  static const Color lightBackground = Color(0xFFFAFBFF);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  static const List<Color> gradientBlue = [primary, secondary];
  static const List<Color> gradientPink = [accent, Color(0xFFF472B6)];
  static const List<Color> gradientGreen = [success, Color(0xFF34D399)];
  static const List<Color> gradientPurple = [
    Color(0xFF8B5CF6),
    Color(0xFFA78BFA),
  ];

  static Color getBackground(bool isDark) =>
      isDark ? darkBackground : lightBackground;
  static Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color getCard(bool isDark) => isDark ? darkCard : lightCard;
  static Color getBorder(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color getTextPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
}
