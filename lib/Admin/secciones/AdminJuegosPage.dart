import 'package:flutter/material.dart';
import 'package:pro9/Usuario/home_page.dart';
import 'dart:math' as math;

// ==================== GESTIÓN DE JUEGOS ADMIN ====================
class GestionJuegosAdminApp extends StatefulWidget {
  const GestionJuegosAdminApp({super.key});

  @override
  State<GestionJuegosAdminApp> createState() => _GestionJuegosAdminAppState();
}

class _GestionJuegosAdminAppState extends State<GestionJuegosAdminApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MenuGestionJuegosAdmin(isDarkMode: _isDarkMode, onThemeToggle: _toggleTheme);
  }
}

class AdminGameItem {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  final String category;
  final String status;
  final int players;
  final double rating;

  const AdminGameItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.category,
    required this.status,
    required this.players,
    required this.rating,
  });
}

class MenuGestionJuegosAdmin extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const MenuGestionJuegosAdmin({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<MenuGestionJuegosAdmin> createState() => _MenuGestionJuegosAdminState();
}

class _MenuGestionJuegosAdminState extends State<MenuGestionJuegosAdmin> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  String _selectedCategory = 'Todos';

  static const List<String> categories = [
    'Todos',
    'Activos',
    'Pendientes',
    'Mantenimiento',
    'Estadísticas',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _animationController.forward();
    _floatingController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _navigateToGameAdmin(Widget gameAdminWidget) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => gameAdminWidget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  List<AdminGameItem> get adminGameItems => [
    AdminGameItem(
      title: 'Tetris Admin',
      description: 'Configurar niveles y puntuaciones',
      icon: Icons.view_module_outlined,
      gradient: AlegraColors.gradientBlue,
      category: 'Activos',
      status: 'Activo',
      players: 1247,
      rating: 4.8,
      onTap: () => _navigateToGameAdmin(_buildGameAdminDetail('Tetris Admin')),
    ),
    AdminGameItem(
      title: 'Adivina Número',
      description: 'Gestionar rangos y dificultad',
      icon: Icons.psychology_outlined,
      gradient: AlegraColors.gradientPink,
      category: 'Activos',
      status: 'Activo',
      players: 892,
      rating: 4.6,
      onTap: () => _navigateToGameAdmin(_buildGameAdminDetail('Adivina Número')),
    ),
    AdminGameItem(
      title: 'Memoria Emojis',
      description: 'Configurar cartas y tiempo',
      icon: Icons.favorite_border,
      gradient: AlegraColors.gradientGreen,
      category: 'Mantenimiento',
      status: 'Mantenimiento',
      players: 654,
      rating: 4.5,
      onTap: () => _navigateToGameAdmin(_buildGameAdminDetail('Memoria Emojis')),
    ),
    AdminGameItem(
      title: 'Tres en Raya',
      description: 'Gestionar IA y multijugador',
      icon: Icons.tag_outlined,
      gradient: AlegraColors.gradientPurple,
      category: 'Activos',
      status: 'Activo',
      players: 2156,
      rating: 4.7,
      onTap: () => _navigateToGameAdmin(_buildGameAdminDetail('Tres en Raya')),
    ),
    AdminGameItem(
      title: 'Nuevo Juego',
      description: 'Agregar juego al sistema',
      icon: Icons.add_circle_outline,
      gradient: AlegraColors.gradientGreen,
      category: 'Pendientes',
      status: 'Pendiente',
      players: 0,
      rating: 0.0,
      onTap: () => _navigateToGameAdmin(_buildAddNewGameForm()),
    ),
    AdminGameItem(
      title: 'Estadísticas Globales',
      description: 'Ver métricas de todos los juegos',
      icon: Icons.analytics_outlined,
      gradient: AlegraColors.gradientBlue,
      category: 'Estadísticas',
      status: 'Análisis',
      players: 4949,
      rating: 4.65,
      onTap: () => _navigateToGameAdmin(_buildGameStats()),
    ),
  ];

  List<AdminGameItem> get filteredGames =>
      _selectedCategory == 'Todos'
          ? adminGameItems
          : adminGameItems
              .where((game) => game.category == _selectedCategory)
              .toList();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AlegraColors.getBackground(widget.isDarkMode),
      appBar: AppBar(
        backgroundColor: AlegraColors.getSurface(widget.isDarkMode),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AlegraColors.getCard(widget.isDarkMode),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AlegraColors.getBorder(widget.isDarkMode),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AlegraColors.getTextPrimary(widget.isDarkMode),
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AlegraColors.gradientBlue,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AlegraColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.games_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Gestión de Juegos',
              style: TextStyle(
                color: AlegraColors.getTextPrimary(widget.isDarkMode),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AlegraColors.getCard(widget.isDarkMode),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AlegraColors.getBorder(widget.isDarkMode),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: widget.isDarkMode ? AlegraColors.warning : AlegraColors.primary,
              ),
              onPressed: widget.onThemeToggle,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: widget.isDarkMode
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AlegraColors.darkBackground,
                    AlegraColors.darkBackground.withOpacity(0.8),
                  ],
                ),
              )
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AlegraColors.lightBackground,
                    AlegraColors.lightBackground.withOpacity(0.9),
                  ],
                ),
              ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isTablet ? 30 : 20),
                  _buildTitle(),
                  SizedBox(height: isTablet ? 24 : 20),
                  _buildQuickStats(),
                  SizedBox(height: isTablet ? 32 : 24),
                  _buildCategories(),
                  SizedBox(height: isTablet ? 32 : 24),
                  _buildGamesGrid(isTablet),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Panel de ',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AlegraColors.getTextPrimary(widget.isDarkMode),
                          letterSpacing: -1,
                        ),
                      ),
                      TextSpan(
                        text: 'Juegos',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: AlegraColors.gradientBlue,
                            ).createShader(
                              const Rect.fromLTWH(0, 0, 200, 70),
                            ),
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Administra, configura y monitorea todos los juegos del sistema',
                  style: TextStyle(
                    fontSize: 16,
                    color: AlegraColors.getTextSecondary(widget.isDarkMode),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AlegraColors.getCard(widget.isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AlegraColors.getBorder(widget.isDarkMode),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDarkMode ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            'Total Juegos',
            '4',
            Icons.games_outlined,
            AlegraColors.gradientBlue,
          ),
          const SizedBox(width: 20),
          _buildStatItem(
            'Jugadores Activos',
            '4,949',
            Icons.people_outline,
            AlegraColors.gradientGreen,
          ),
          const SizedBox(width: 20),
          _buildStatItem(
            'Rating Promedio',
            '4.65',
            Icons.star_outline,
            AlegraColors.gradientPink,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, List<Color> gradient) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AlegraColors.getTextPrimary(widget.isDarkMode),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AlegraColors.getTextSecondary(widget.isDarkMode),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: AlegraColors.gradientBlue,
                          )
                        : null,
                    color: isSelected ? null : AlegraColors.getCard(widget.isDarkMode),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AlegraColors.getBorder(widget.isDarkMode),
                      width: 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AlegraColors.primary.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AlegraColors.getTextSecondary(widget.isDarkMode),
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
    );
  }

  Widget _buildGamesGrid(bool isTablet) {
    final crossAxisCount = isTablet ? 3 : 2;
    final childAspectRatio = isTablet ? 1.0 : 1.1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredGames.length,
      itemBuilder: (context, index) {
        final game = filteredGames[index];
        return _buildGameCard(game, index);
      },
    );
  }

  Widget _buildGameCard(AdminGameItem game, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationDelay = index * 0.1;
        final slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(animationDelay, 1.0, curve: Curves.easeOutCubic),
          ),
        );

        return Transform.translate(
          offset: Offset(0, 30 * (1 - slideAnimation.value)),
          child: Opacity(
            opacity: slideAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: game.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: AlegraColors.getCard(widget.isDarkMode),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AlegraColors.getBorder(widget.isDarkMode),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(widget.isDarkMode ? 0.2 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: game.gradient),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: game.gradient.first.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(game.icon, color: Colors.white, size: 20),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(game.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _getStatusColor(game.status).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                game.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(game.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          game.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AlegraColors.getTextPrimary(widget.isDarkMode),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          game.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: AlegraColors.getTextSecondary(widget.isDarkMode),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 14,
                                  color: AlegraColors.getTextSecondary(widget.isDarkMode),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${game.players}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AlegraColors.getTextSecondary(widget.isDarkMode),
                                  ),
                                ),
                              ],
                            ),
                            if (game.rating > 0)
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: AlegraColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    game.rating.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AlegraColors.getTextSecondary(widget.isDarkMode),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Activo':
        return AlegraColors.success;
      case 'Mantenimiento':
        return AlegraColors.warning;
      case 'Pendiente':
        return AlegraColors.accent;
      case 'Análisis':
        return AlegraColors.primary;
      default:
        return AlegraColors.primary;
    }
  }

  Widget _buildGameAdminDetail(String gameTitle) {
    return Scaffold(
      backgroundColor: AlegraColors.getBackground(widget.isDarkMode),
      appBar: AppBar(
        backgroundColor: AlegraColors.getSurface(widget.isDarkMode),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AlegraColors.getTextPrimary(widget.isDarkMode),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Admin: $gameTitle',
          style: TextStyle(
            color: AlegraColors.getTextPrimary(widget.isDarkMode),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AlegraColors.getCard(widget.isDarkMode),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AlegraColors.getBorder(widget.isDarkMode),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panel de Configuración',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AlegraColors.getTextPrimary(widget.isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildConfigOption('Estado del Juego', 'Activo', true),
                  const SizedBox(height: 12),
                  _buildConfigOption('Nivel de Dificultad', 'Medio', false),
                  const SizedBox(height: 12),
                  _buildConfigOption('Puntuación Máxima', '10,000', false),
                  const SizedBox(height: 12),
                  _buildConfigOption('Tiempo por Partida', '5 min', false),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Configuración guardada exitosamente'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AlegraColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigOption(String label, String value, bool isToggle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AlegraColors.getTextPrimary(widget.isDarkMode),
          ),
        ),
        isToggle
            ? Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AlegraColors.success,
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: AlegraColors.getTextSecondary(widget.isDarkMode),
                ),
              ),
      ],
    );
  }

  Widget _buildAddNewGameForm() {
    return Scaffold(
      backgroundColor: AlegraColors.getBackground(widget.isDarkMode),
      appBar: AppBar(
        backgroundColor: AlegraColors.getSurface(widget.isDarkMode),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AlegraColors.getTextPrimary(widget.isDarkMode),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Agregar Nuevo Juego',
          style: TextStyle(
            color: AlegraColors.getTextPrimary(widget.isDarkMode),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Formulario para agregar nuevo juego',
          style: TextStyle(
            fontSize: 18,
            color: AlegraColors.getTextPrimary(widget.isDarkMode),
          ),
        ),
      ),
    );
  }

  Widget _buildGameStats() {
    return Scaffold(
      backgroundColor: AlegraColors.getBackground(widget.isDarkMode),
      appBar: AppBar(
        backgroundColor: AlegraColors.getSurface(widget.isDarkMode),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AlegraColors.getTextPrimary(widget.isDarkMode),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Estadísticas de Juegos',
          style: TextStyle(
            color: AlegraColors.getTextPrimary(widget.isDarkMode),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Dashboard de estadísticas y métricas',
          style: TextStyle(
            fontSize: 18,
            color: AlegraColors.getTextPrimary(widget.isDarkMode),
          ),
        ),
      ),
    );
  }
}

// Colores de Alegra con modo oscuro/claro
class AlegraColors {
  // Colores principales de Alegra
  static const Color primary = Color(0xFF0EA5E9); // Azul cian principal
  static const Color secondary = Color(0xFF06B6D4); // Cian secundario
  static const Color accent = Color(0xFFEC4899); // Rosa de acento
  static const Color success = Color(0xFF10B981); // Verde éxito
  static const Color warning = Color(0xFFF59E0B); // Amarillo advertencia

  // Modo claro
  static const Color lightBackground = Color(0xFFFAFBFF);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Modo oscuro
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  // Gradientes de juegos con colores de Alegra
  static const List<Color> gradientBlue = [primary, secondary];
  static const List<Color> gradientPink = [accent, Color(0xFFF472B6)];
  static const List<Color> gradientGreen = [success, Color(0xFF34D399)];
  static const List<Color> gradientPurple = [
    Color(0xFF8B5CF6),
    Color(0xFFA78BFA),
  ];

  // Funciones helper
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