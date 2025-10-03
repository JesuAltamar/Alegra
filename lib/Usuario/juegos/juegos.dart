import 'package:flutter/material.dart';
import 'package:pro9/Usuario/home_page.dart';
import 'dart:math' as math;
import 'package:pro9/Usuario/juegos/Adivina_numero.dart';
import 'package:pro9/Usuario/juegos/TetrisApp.dart';
import 'package:pro9/Usuario/juegos/memoria.dart';
import 'package:pro9/Usuario/juegos/tresenraya.dart';
import 'package:pro9/services/sevices_admin/api_estadistica.dart';

class JuegosApp extends StatefulWidget {
  final int usuarioId;
  const JuegosApp({super.key, required this.usuarioId});
  
  @override
  State<JuegosApp> createState() => _JuegosAppState();
}

class _JuegosAppState extends State<JuegosApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MenuJuegos(
      isDarkMode: _isDarkMode,
      onThemeToggle: _toggleTheme,
      usuarioId: widget.usuarioId,
    );
  }
}

class MenuJuegos extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final int usuarioId;

  const MenuJuegos({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.usuarioId,
  });

  @override
  State<MenuJuegos> createState() => _MenuJuegosState();
}

class _MenuJuegosState extends State<MenuJuegos> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late AnimationController _cardController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;
  
  late ScrollController _scrollControllerWidget;
  double _scrollOffset = 0.0;
  String _selectedCategory = 'Todos';

  // Colores estilo Alegra
  final Color deepPurple = Color(0xFF2D1B69);
  final Color vibrantPurple = Color(0xFF6366F1);
  final Color lightPurple = Color(0xFFA855F7);
  final Color darkBackground = Color(0xFF0F0A1F);
  final Color cardDark = Color(0xFF1A1335);
  final Color accentPink = Color(0xFFEC4899);
  final Color softWhite = Color(0xFFF8FAFC);
  final Color cloudBlue = Color(0xFF8B5CF6);
  final Color mentalhealthGreen = Color(0xFF10B981);
  final Color warningYellow = Color(0xFFFFD93D);

  static const List<String> categories = ['Todos', 'Puzzle', 'Clásicos', 'Memoria'];

  @override
  void initState() {
    super.initState();
    
    _scrollControllerWidget = ScrollController();
    _scrollControllerWidget.addListener(() {
      setState(() {
        _scrollOffset = _scrollControllerWidget.offset;
      });
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_floatingController);

    _animationController.forward();
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _cardController.forward();
    });
  }

  @override
  void dispose() {
    _scrollControllerWidget.dispose();
    _animationController.dispose();
    _floatingController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _navigateToGame(Widget gameWidget, String juegoNombre) async {
    int? sesionId;
    try {
      sesionId = await iniciarJuego(widget.usuarioId, juegoNombre);
      print("Sesión iniciada para $juegoNombre con ID $sesionId");
    } catch (e) {
      print("Error al iniciar sesión: $e");
    }

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => gameWidget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    if (sesionId != null) {
      try {
        await finalizarJuego(sesionId);
      } catch (e) {
        print("Error al finalizar sesión: $e");
      }
    }
  }

  List<GameItem> get gameItems => [
    GameItem(
      title: 'Tetris',
      description: 'Clásico de bloques que desafía tu agilidad mental',
      icon: Icons.view_module_rounded,
      color: vibrantPurple,
      category: 'Puzzle',
      onTap: () => _navigateToGame(const TetrisApp(), "Tetris"),
    ),
    GameItem(
      title: 'Adivina',
      description: 'Ejercita tu lógica adivinando números',
      icon: Icons.psychology_rounded,
      color: accentPink,
      category: 'Puzzle',
      onTap: () => _navigateToGame(GuessNumberGame(), "Adivina Número"),
    ),
    GameItem(
      title: 'Memoria',
      description: 'Fortalece tu memoria con parejas',
      icon: Icons.favorite_rounded,
      color: mentalhealthGreen,
      category: 'Memoria',
      onTap: () => _navigateToGame(MemoryGameWidget(), "Memoria"),
    ),
    GameItem(
      title: 'Tres en Raya',
      description: 'Estrategia clásica para relajarte',
      icon: Icons.tag_rounded,
      color: cloudBlue,
      category: 'Clásicos',
      onTap: () => _navigateToGame(TicTacToeApp(), "Tres en Raya"),
    ),
  ];

  List<GameItem> get filteredGames =>
      _selectedCategory == 'Todos'
          ? gameItems
          : gameItems.where((game) => game.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final horizontalPadding = isMobile ? 20.0 : (isTablet ? 40.0 : 80.0);

    return Scaffold(
      backgroundColor: widget.isDarkMode ? darkBackground : softWhite,
      appBar: _buildAppBar(isMobile, horizontalPadding),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDarkMode
                ? [darkBackground, deepPurple.withOpacity(0.3), darkBackground]
                : [softWhite, vibrantPurple.withOpacity(0.05), softWhite],
          ),
        ),
        child: Stack(
          children: [
            // Elementos flotantes de fondo
            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: FloatingElementsPainter(
                    _floatingAnimation.value,
                    widget.isDarkMode,
                    vibrantPurple,
                    accentPink,
                    mentalhealthGreen,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            
            // Contenido principal
            SingleChildScrollView(
              controller: _scrollControllerWidget,
              physics: BouncingScrollPhysics(),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeInAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: isMobile ? 20 : 40),
                            Transform.translate(
                              offset: Offset(0, -_scrollOffset * 0.3),
                              child: _buildHeader(isMobile, isTablet),
                            ),
                            SizedBox(height: isMobile ? 30 : 40),
                            Transform.translate(
                              offset: Offset(0, -_scrollOffset * 0.2),
                              child: _buildCategories(),
                            ),
                            SizedBox(height: isMobile ? 30 : 40),
                            _buildGamesGrid(isMobile, isTablet),
                            SizedBox(height: 40),
                          ],
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
    );
  }

  PreferredSizeWidget _buildAppBar(bool isMobile, double horizontalPadding) {
    return AppBar(
      backgroundColor: (widget.isDarkMode ? cardDark : softWhite).withOpacity(0.95),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: widget.isDarkMode ? softWhite : deepPurple,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [vibrantPurple, lightPurple],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: vibrantPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.gamepad_rounded, color: softWhite, size: 20),
          ),
          SizedBox(width: 16),
          Text(
            'JUEGOS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: widget.isDarkMode ? softWhite : deepPurple,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: widget.isDarkMode ? warningYellow : vibrantPurple,
            size: 24,
          ),
          onPressed: widget.onThemeToggle,
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeader(bool isMobile, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: vibrantPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: vibrantPurple.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars_rounded, size: 16, color: vibrantPurple),
              SizedBox(width: 6),
              Text(
                'Relaja tu mente',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: vibrantPurple,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 20 : 30),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Zona de ',
                style: TextStyle(
                  fontSize: isMobile ? 32 : (isTablet ? 42 : 48),
                  fontWeight: FontWeight.w900,
                  color: widget.isDarkMode ? softWhite : deepPurple,
                  height: 1.1,
                ),
              ),
              TextSpan(
                text: 'Juegos\n',
                style: TextStyle(
                  fontSize: isMobile ? 32 : (isTablet ? 42 : 48),
                  fontWeight: FontWeight.w900,
                  color: vibrantPurple,
                  height: 1.1,
                ),
              ),
              TextSpan(
                text: 'Terapéuticos',
                style: TextStyle(
                  fontSize: isMobile ? 32 : (isTablet ? 42 : 48),
                  fontWeight: FontWeight.w900,
                  color: widget.isDarkMode ? softWhite : deepPurple,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        Container(
          constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 500),
          child: Text(
            'Ejercita tu mente de forma divertida. Cada juego está diseñado para ayudarte a relajarte y mejorar tus habilidades cognitivas.',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: widget.isDarkMode ? Colors.grey[300] : deepPurple.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [vibrantPurple, lightPurple])
                        : null,
                    color: isSelected
                        ? null
                        : widget.isDarkMode
                            ? cardDark.withOpacity(0.6)
                            : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : widget.isDarkMode
                              ? vibrantPurple.withOpacity(0.3)
                              : deepPurple.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: vibrantPurple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? softWhite
                          : widget.isDarkMode
                              ? Colors.grey[300]
                              : deepPurple.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
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

  Widget _buildGamesGrid(bool isMobile, bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
        childAspectRatio: isMobile ? 1.3 : 1.1,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: filteredGames.length,
      itemBuilder: (context, index) {
        final game = filteredGames[index];
        return _buildGameCard(game, index, isMobile);
      },
    );
  }

  Widget _buildGameCard(GameItem game, int index, bool isMobile) {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        final delay = index * 0.1;
        final cardValue = math.max(0.0, (_cardController.value - delay) * (1.0 / (1.0 - delay)));
        
        return Transform.translate(
          offset: Offset(0, (1 - cardValue) * 60),
          child: Opacity(
            opacity: cardValue.clamp(0.0, 1.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: game.onTap,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 24 : 20),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? cardDark.withOpacity(0.8)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: game.color.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: game.color.withOpacity(0.15),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              game.color.withOpacity(0.2),
                              game.color.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: game.color.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(game.icon, color: game.color, size: 28),
                      ),
                      SizedBox(height: 16),
                      Text(
                        game.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: widget.isDarkMode ? softWhite : deepPurple,
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          game.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.isDarkMode
                                ? Colors.grey[300]
                                : deepPurple.withOpacity(0.7),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [game.color, game.color.withOpacity(0.5)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class GameItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String category;

  const GameItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.category,
  });
}

class FloatingElementsPainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;
  final Color vibrantPurple;
  final Color accentPink;
  final Color mentalhealthGreen;

  FloatingElementsPainter(
    this.animationValue,
    this.isDarkMode,
    this.vibrantPurple,
    this.accentPink,
    this.mentalhealthGreen,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [vibrantPurple, accentPink, mentalhealthGreen];
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2 / 6) + (animationValue * 0.5);
      final x = size.width * (0.2 + 0.6 * ((i % 3) / 2));
      final y = size.height * (0.3 + 0.4 * ((i % 2)));
      final radius = 30 + math.sin(animationValue * 2 * math.pi + i) * 10;
      
      final paint = Paint()
        ..color = colors[i % 3].withOpacity(isDarkMode ? 0.08 : 0.05)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}