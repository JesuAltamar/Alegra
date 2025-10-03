// lib/Admin/AdminScreen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:pro9/Admin/api.dart';
import 'package:pro9/Admin/interfazeva.dart';
import 'package:pro9/Admin/secciones/AdminTareasPage.dart';
import 'package:pro9/services/sevices_admin/gestion_usuario.dart';
import 'package:pro9/estado_emocional_screen.dart';
import 'Notificacion_admin.dart';
import 'Configuracion_admin.dart';
import 'Soporte_admin.dart';
import 'package:pro9/Registros_usuarios_y_evaluaciones/usuinterfaz.dart';
import 'package:pro9/Admin/secciones/AdminJuegosPage.dart';
import 'package:pro9/Admin/secciones/AdminChatPage.dart';
import 'package:pro9/services/sevices_admin/api_estadistica.dart';
import 'package:pro9/services/sevices_admin/api_notificaciones.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pro9/Admin/gestion_chat_admin.dart';
import 'package:pro9/services/sevices_admin/api_actividades.dart';
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>

    with TickerProviderStateMixin {
  bool isDarkMode = false;
  int selectedSidebarIndex = 0;
  int notificacionesNoLeidas = 0;
  Timer? _notificationTimer;

  late AnimationController _mainAnimationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Paleta de colores unificada con Alegra
  final Color deepPurple = Color(0xFF2D1B69);
  final Color vibrantPurple = Color(0xFF6366F1);
  final Color lightPurple = Color(0xFFA855F7);
  final Color darkBackground = Color(0xFF0F0A1F);
  final Color cardDark = Color(0xFF1A1335);
  final Color accentPink = Color(0xFFEC4899);
  final Color softWhite = Color(0xFFF8FAFC);
  final Color cloudBlue = Color(0xFF8B5CF6);
  final Color mentalhealthGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();

    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _mainAnimationController.forward();
    _floatingController.repeat();

    // Cargar notificaciones al iniciar

    // Actualizar contador cada 30 segundos
    _notificationTimer = Timer.periodic(
      Duration(minutes: 2),
      (_) => _cargarContadorNotificaciones(),
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _mainAnimationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _cargarContadorNotificaciones() async {
    try {
      final count = await ApiNotificaciones.getCountNoLeidas();
      if (mounted) {
        setState(() {
          notificacionesNoLeidas = count;
        });
      }
    } catch (e) {
      print('Error cargando contador de notificaciones: $e');
    }
  }

  void _mostrarDialogoLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? cardDark : softWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.logout, color: accentPink, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Cerrar Sesión',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? softWhite : deepPurple,
                ),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro de que quieres cerrar tu sesión como administrador?\n\nSerás redirigido a la página principal.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color:
                  isDarkMode
                      ? softWhite.withOpacity(0.8)
                      : deepPurple.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: cloudBlue,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cerrarSesion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'Cerrar Sesión',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _cerrarSesion() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sesión de administrador cerrada exitosamente',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: mentalhealthGreen,
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
      backgroundColor: isDarkMode ? darkBackground : softWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDarkMode
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      darkBackground,
                      deepPurple.withOpacity(0.3),
                      darkBackground,
                    ],
                  )
                  : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      softWhite,
                      vibrantPurple.withOpacity(0.05),
                      lightPurple.withOpacity(0.03),
                    ],
                  ),
        ),
        child: Column(
          children: [
            _buildModernAppBar(context, isTablet),
            Expanded(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        children: [
                          if (isTablet) _buildSidebar(context),
                          Expanded(child: _buildMainContent(isTablet)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? cardDark.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color:
                isDarkMode
                    ? vibrantPurple.withOpacity(0.2)
                    : deepPurple.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : vibrantPurple).withOpacity(
              isDarkMode ? 0.2 : 0.05,
            ),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Botón de logout
            Container(
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? cardDark.withOpacity(0.8)
                        : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accentPink.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.logout, color: accentPink),
                onPressed: _mostrarDialogoLogout,
                tooltip: 'Cerrar Sesión',
              ),
            ),
            const SizedBox(width: 16),

            // Logo y título
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [vibrantPurple, lightPurple],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: vibrantPurple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.dashboard_rounded,
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
                        'Alegra Dashboard',
                        style: GoogleFonts.inter(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? softWhite : deepPurple,
                        ),
                      ),
                      Text(
                        'Panel de Control',
                        style: GoogleFonts.inter(
                          fontSize: isTablet ? 14 : 12,
                          color:
                              isDarkMode
                                  ? softWhite.withOpacity(0.7)
                                  : deepPurple.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Notificaciones y controles
            Row(
              children: [
                // BOTÓN DE NOTIFICACIONES CON BADGE ANIMADO
                Container(
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? cardDark.withOpacity(0.8)
                            : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          notificacionesNoLeidas > 0
                              ? accentPink.withOpacity(0.5)
                              : (isDarkMode
                                  ? vibrantPurple.withOpacity(0.3)
                                  : deepPurple.withOpacity(0.1)),
                      width: notificacionesNoLeidas > 0 ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_rounded,
                          color:
                              notificacionesNoLeidas > 0
                                  ? accentPink
                                  : (isDarkMode
                                      ? softWhite.withOpacity(0.7)
                                      : deepPurple.withOpacity(0.7)),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationsScreen(),
                            ),
                          );
                          // Recargar contador al volver
                          _cargarContadorNotificaciones();
                        },
                        tooltip: 'Notificaciones',
                      ),
                      if (notificacionesNoLeidas > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 800),
                            tween: Tween(begin: 0.8, end: 1.0),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  padding: EdgeInsets.all(
                                    notificacionesNoLeidas > 9 ? 4 : 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [accentPink, lightPurple],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentPink.withOpacity(0.6),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Center(
                                    child: Text(
                                      notificacionesNoLeidas > 99
                                          ? '99+'
                                          : '$notificacionesNoLeidas',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Botón de tema
                Container(
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? cardDark.withOpacity(0.8)
                            : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDarkMode
                              ? vibrantPurple.withOpacity(0.3)
                              : deepPurple.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: isDarkMode ? accentPink : vibrantPurple,
                    ),
                    onPressed: () => setState(() => isDarkMode = !isDarkMode),
                  ),
                ),

                const SizedBox(width: 8),

                // Avatar de usuario
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [vibrantPurple, lightPurple],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDarkMode ? cardDark : softWhite,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: vibrantPurple,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.dashboard_rounded,
        'title': 'Admin',
        'action': () {
          setState(() {
            selectedSidebarIndex = 0;
          });
        },
      },
      {
        'icon': Icons.people_rounded,
        'title': 'Usuarios',
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MostrarConsulta()),
          );
        },
      },
      {
        'icon': Icons.task_alt_rounded,
        'title': 'Analisis',
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GestionChatAdmin()),
          );
        },
      },
    ];

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? cardDark.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
        border: Border(
          right: BorderSide(
            color:
                isDarkMode
                    ? vibrantPurple.withOpacity(0.2)
                    : deepPurple.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NAVEGACIÓN',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isDarkMode
                            ? softWhite.withOpacity(0.7)
                            : deepPurple.withOpacity(0.7),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedSidebarIndex == index;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 2,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (item['action'] != null) {
                          (item['action'] as Function).call();
                        }

                        if (index == 0) {
                          setState(() {
                            selectedSidebarIndex = index;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? vibrantPurple.withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              isSelected
                                  ? Border.all(
                                    color: vibrantPurple.withOpacity(0.3),
                                    width: 1,
                                  )
                                  : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              color:
                                  isSelected
                                      ? vibrantPurple
                                      : isDarkMode
                                      ? softWhite.withOpacity(0.7)
                                      : deepPurple.withOpacity(0.7),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                color:
                                    isSelected
                                        ? vibrantPurple
                                        : isDarkMode
                                        ? softWhite
                                        : deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isDarkMode
                          ? [
                            cardDark.withOpacity(0.8),
                            darkBackground.withOpacity(0.8),
                          ]
                          : [
                            lightPurple.withOpacity(0.05),
                            vibrantPurple.withOpacity(0.03),
                          ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDarkMode
                          ? vibrantPurple.withOpacity(0.2)
                          : deepPurple.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: mentalhealthGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sistema activo',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? softWhite : deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versión 1.0.0 - Beta',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color:
                          isDarkMode
                              ? softWhite.withOpacity(0.7)
                              : deepPurple.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isTablet) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchAdminStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: vibrantPurple,
              strokeWidth: 3,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar los datos: ${snapshot.error}',
              style: GoogleFonts.inter(
                color: isDarkMode ? softWhite : deepPurple,
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(isTablet),
                const SizedBox(height: 32),
                _buildMetricsGrid(data, isTablet),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: fetchWeeklyActiveUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: vibrantPurple,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error al cargar la actividad: ${snapshot.error}',
                                style: GoogleFonts.inter(
                                  color: isDarkMode ? softWhite : deepPurple,
                                ),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return _buildActivityChart(
                              isTablet,
                              snapshot.data!,
                            );
                          } else {
                            return Center(
                              child: Text(
                                'No hay actividad disponible.',
                                style: GoogleFonts.inter(
                                  color: isDarkMode ? softWhite : deepPurple,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    if (isTablet) const SizedBox(width: 24),
                    if (isTablet)
                      Expanded(flex: 1, child: _buildRecentActivity()),
                  ],
                ),
                if (!isTablet) ...[
                  const SizedBox(height: 24),
                  _buildRecentActivity(),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        } else {
          return Center(
            child: Text(
              'No hay datos disponibles.',
              style: GoogleFonts.inter(
                color: isDarkMode ? softWhite : deepPurple,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildWelcomeSection(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido de vuelta',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? softWhite : deepPurple,
              ),
            ),
            Text(
              'Aquí tienes un resumen de tu aplicación',
              style: GoogleFonts.inter(
                fontSize: 14,
                color:
                    isDarkMode
                        ? softWhite.withOpacity(0.7)
                        : deepPurple.withOpacity(0.7),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: mentalhealthGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: mentalhealthGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: mentalhealthGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'En desarrollo',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: mentalhealthGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> data, bool isTablet) {
    final metrics = [
      {
        'title': 'Usuarios Registrados',
        'value': '${data['total_usuarios']}',
        'change': 'Total del sistema',
        'icon': Icons.people_rounded,
        'color': vibrantPurple,
      },
      {
        'title': 'Tareas Creadas',
        'value': '${data['total_tareas']}',
        'change': '${data['promedio_tareas_por_usuario']} por usuario',
        'icon': Icons.task_alt_rounded,
        'color': mentalhealthGreen,
      },
      {
        'title': 'Interacciones Chat',
        'value': '${data['total_chat_interacciones']}',
        'change': 'Esta semana',
        'icon': Icons.chat_bubble_rounded,
        'color': accentPink,
      },
      {
        'title': 'Sesiones de Juego',
        'value': '${data['total_sesiones_juego']}',
        'change': 'Partidas jugadas',
        'icon': Icons.sports_esports_rounded,
        'color': cloudBlue,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        childAspectRatio: isTablet ? 1.2 : 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _buildMetricCard(metric, index, isTablet);
      },
    );
  }

  Widget _buildMetricCard(
    Map<String, dynamic> metric,
    int index,
    bool isTablet,
  ) {
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
              color:
                  isDarkMode
                      ? cardDark.withOpacity(0.95)
                      : Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isDarkMode
                        ? vibrantPurple.withOpacity(0.2)
                        : deepPurple.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode ? Colors.black : vibrantPurple)
                      .withOpacity(isDarkMode ? 0.1 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (metric['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        metric['icon'] as IconData,
                        color: metric['color'] as Color,
                        size: 20,
                      ),
                    ),
                    Icon(
                      Icons.trending_up_rounded,
                      color: mentalhealthGreen,
                      size: 16,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  metric['value'] as String,
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? softWhite : deepPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric['title'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color:
                        isDarkMode
                            ? softWhite.withOpacity(0.7)
                            : deepPurple.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric['change'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color:
                        isDarkMode
                            ? softWhite.withOpacity(0.6)
                            : deepPurple.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityChart(bool isTablet, Map<String, dynamic> weeklyData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? cardDark.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDarkMode
                  ? vibrantPurple.withOpacity(0.2)
                  : deepPurple.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actividad de Usuarios',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? softWhite : deepPurple,
                    ),
                  ),
                  Text(
                    'Últimos 7 días',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color:
                          isDarkMode
                              ? softWhite.withOpacity(0.7)
                              : deepPurple.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? cardDark.withOpacity(0.8)
                          : lightPurple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isDarkMode
                            ? vibrantPurple.withOpacity(0.2)
                            : deepPurple.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: cloudBlue),
                    const SizedBox(width: 4),
                    Text(
                      '7 días',
                      style: GoogleFonts.inter(fontSize: 12, color: cloudBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: _buildSimpleChart()),
        ],
      ),
    );
  }

  Widget _buildSimpleChart() {
    final data = [1, 0, 2, 1, 0, 1, 3];
    final maxValue = data.isNotEmpty ? data.reduce(math.max) : 1;
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(data.length, (index) {
              final value = data[index];
              final height =
                  maxValue > 0 ? (value / maxValue) * 140 + 20 : 20.0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 32,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [vibrantPurple, lightPurple],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color:
                          isDarkMode
                              ? softWhite.withOpacity(0.7)
                              : deepPurple.withOpacity(0.7),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchRecentActivities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? cardDark.withOpacity(0.95)
                      : Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isDarkMode
                        ? vibrantPurple.withOpacity(0.2)
                        : deepPurple.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(color: vibrantPurple),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Text("Error: ${snapshot.error}"),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: const Text("No hay actividad reciente"),
          );
        }

        final actividades = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? cardDark.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDarkMode
                      ? vibrantPurple.withOpacity(0.2)
                      : deepPurple.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Actividad Reciente",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? softWhite : deepPurple,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Últimas acciones de los usuarios",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color:
                              isDarkMode
                                  ? softWhite.withOpacity(0.7)
                                  : deepPurple.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed:
                        () => _mostrarActividadUsuario(context, actividades),
                    child: Text(
                      "Ver Todo",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: vibrantPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista de actividades
              ...actividades.map((activity) {
                final detail = activity['detalle'] ?? '-';
                final action = activity['action'] ?? 'Acción Desconocida';
                final time = activity['time'] ?? '-';

                // Determinar icono según la acción
                IconData icon;
                Color color;
                if (action.contains('Usuario registrado')) {
                  icon = Icons.person_add;
                  color = vibrantPurple;
                } else if (action.contains('Tarea')) {
                  icon = Icons.check_circle;
                  color = mentalhealthGreen;
                } else if (action.contains('juego')) {
                  icon = Icons.sports_esports;
                  color = cloudBlue;
                } else {
                  icon = Icons.chat;
                  color = accentPink;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(icon, size: 14, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? softWhite : deepPurple,
                              ),
                            ),
                            if (detail != '-')
                              Text(
                                detail,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color:
                                      isDarkMode
                                          ? softWhite.withOpacity(0.6)
                                          : deepPurple.withOpacity(0.6),
                                ),
                              ),
                            Text(
                              time,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color:
                                    isDarkMode
                                        ? softWhite.withOpacity(0.6)
                                        : deepPurple.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // Función del diálogo de búsqueda
  void _mostrarActividadUsuario(
    BuildContext context,
    List<Map<String, dynamic>> actividadesIniciales,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => _ActividadUsuarioDialog(
            actividadesIniciales: actividadesIniciales,
            isDarkMode: isDarkMode,
            vibrantPurple: vibrantPurple,
            deepPurple: deepPurple,
            softWhite: softWhite,
            cardDark: cardDark,
          ),
    );
  }
}
class _ActividadUsuarioDialog extends StatefulWidget {
  final List<Map<String, dynamic>> actividadesIniciales;
  final bool isDarkMode;
  final Color vibrantPurple;
  final Color deepPurple;
  final Color softWhite;
  final Color cardDark;

  const _ActividadUsuarioDialog({
    required this.actividadesIniciales,
    required this.isDarkMode,
    required this.vibrantPurple,
    required this.deepPurple,
    required this.softWhite,
    required this.cardDark,
  });

  @override
  State<_ActividadUsuarioDialog> createState() => _ActividadUsuarioDialogState();
}

class _ActividadUsuarioDialogState extends State<_ActividadUsuarioDialog> {
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _actividades;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _actividades = widget.actividadesIniciales;
  }

  Future<void> _searchActivities() async {
    final userName = _searchController.text.trim();
    if (userName.isEmpty) {
      setState(() {
        _error = "Introduce un nombre de usuario.";
        _actividades = widget.actividadesIniciales;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _actividades = [];
    });

    try {
      final resultados = await searchUserActivities(userName);
      setState(() {
        _actividades = resultados;
        if (resultados.isEmpty) {
          _error = "No se encontraron actividades para '$userName'.";
        }
      });
    } catch (e) {
      setState(() {
        _error = "Error al buscar: ${e.toString().replaceAll('Exception: ', '')}";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? widget.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        "Actividad del Usuario",
        style: GoogleFonts.inter(
          color: widget.isDarkMode ? widget.softWhite : widget.deepPurple,
        ),
      ),
      content: SizedBox(
        width: 400,
        height: 500,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Buscar usuario",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _searchActivities,
                      ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchActivities(),
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator())),

            if (_error != null && !_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

            if (!_isLoading && _error == null)
              Expanded(
                child: _actividades.isEmpty && _searchController.text.isNotEmpty
                    ? const Center(child: Text("No se encontraron resultados."))
                    : ListView.builder(
                        itemCount: _actividades.length,
                        itemBuilder: (context, index) {
                          final activity = _actividades[index];
                          final detail = activity['detalle'] ?? '-';
                          final action = activity['action'] ?? 'Actividad Desconocida';
                          final time = activity['time'] ?? '-';

                          return ListTile(
                            leading: _buildActivityIcon(action),
                            title: Text(action),
                            subtitle: Text(
                              detail != '-' ? '$detail\n$time' : time,
                              style: const TextStyle(height: 1.5),
                            ),
                            isThreeLine: detail != '-',
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }

  Widget _buildActivityIcon(String? action) {
    IconData icon;
    if (action != null) {
      if (action.contains('Tarea')) {
        icon = Icons.assignment_turned_in;
      } else if (action.contains('juego')) {
        icon = Icons.sports_esports;
      } else if (action.contains('Chat')) {
        icon = Icons.chat;
      } else if (action.contains('Usuario registrado')) {
        icon = Icons.person_add_alt_1;
      } else {
        icon = Icons.history;
      }
    } else {
      icon = Icons.history;
    }

    return Icon(icon, color: widget.vibrantPurple);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}