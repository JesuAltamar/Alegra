import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:pro9/Pagina_inicio/UnifiedLoginPage.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late AnimationController _cardController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _floatingAnimation;

  List<FloatingDecoration> floatingDecorations = [];
  final int decorationCount = 15;
  bool isDarkMode = false;

  // Paleta de colores coherente con PagInicio
  final Color deepPurple = Color(0xFF2D1B69);
  final Color vibrantPurple = Color(0xFF6366F1);
  final Color lightPurple = Color(0xFFA855F7);
  final Color darkBackground = Color(0xFF0F0A1F);
  final Color cardDark = Color(0xFF1A1335);
  final Color accentPink = Color(0xFFEC4899);
  final Color softWhite = Color(0xFFF8FAFC);
  final Color cloudBlue = Color(0xFF8B5CF6);
  final Color mentalhealthGreen = Color(0xFF10B981);

  void _showLoginRequiredDialog(String serviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? cardDark : softWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: vibrantPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.lock, color: vibrantPurple, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Iniciar Sesión Requerido',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? softWhite : deepPurple,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para acceder a $serviceName necesitas iniciar sesión en tu cuenta de Alegra.',
                style: TextStyle(
                  color:
                      isDarkMode
                          ? Colors.grey[300]
                          : deepPurple.withOpacity(0.8),
                  height: 1.6,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mentalhealthGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: mentalhealthGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: mentalhealthGreen,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tu bienestar es nuestra prioridad. Regístrate gratis.',
                        style: TextStyle(
                          color: mentalhealthGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: vibrantPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const UnifiedLoginPage(nombreUsuario: null),
                    ),
                  );
                },
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: softWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_floatingController);

    _initFloatingDecorations();
    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _cardController.forward();
    });
  }

  void _initFloatingDecorations() {
    floatingDecorations.clear();
    for (int i = 0; i < decorationCount; i++) {
      floatingDecorations.add(FloatingDecoration());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final horizontalPadding = isMobile ? 20.0 : (isTablet ? 40.0 : 80.0);

    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : softWhite,
      appBar: _buildAppBar(isMobile, horizontalPadding),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDarkMode
                    ? [
                      darkBackground,
                      deepPurple.withOpacity(0.3),
                      darkBackground,
                    ]
                    : [softWhite, vibrantPurple.withOpacity(0.05), softWhite],
          ),
        ),
        child: Stack(
          children: [
            // Contenido principal - SIN ScrollController
            SingleChildScrollView(
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
                            _buildHeroSection(isMobile, isTablet),
                            SizedBox(height: isMobile ? 40 : 60),
                            _buildServicesGrid(isMobile, isTablet),
                            SizedBox(height: isMobile ? 40 : 60),
                            _buildCallToAction(isMobile),
                            SizedBox(height: isMobile ? 20 : 40),
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
      backgroundColor: (isDarkMode ? cardDark : softWhite).withOpacity(0.95),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDarkMode ? softWhite : deepPurple,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: vibrantPurple,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: vibrantPurple.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.psychology, color: softWhite, size: 16),
          ),
          SizedBox(width: 12),
          Text(
            'Servicios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? softWhite : deepPurple,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: isDarkMode ? accentPink : vibrantPurple,
            size: 22,
          ),
          onPressed: () {
            setState(() {
              isDarkMode = !isDarkMode;
            });
          },
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeroSection(bool isMobile, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: vibrantPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: vibrantPurple.withOpacity(0.3)),
          ),
          child: Text(
            '🌟 Servicios de Bienestar Mental',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: vibrantPurple,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 24 : 32),

        Text(
          'Descubre todas nuestras',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 28 : (isTablet ? 36 : 42),
            fontWeight: FontWeight.w900,
            color: isDarkMode ? softWhite : deepPurple,
            height: 1.1,
          ),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'herramientas ',
                style: TextStyle(
                  fontSize: isMobile ? 28 : (isTablet ? 36 : 42),
                  fontWeight: FontWeight.w900,
                  color: vibrantPurple,
                  height: 1.1,
                ),
              ),
              TextSpan(
                text: 'terapéuticas',
                style: TextStyle(
                  fontSize: isMobile ? 28 : (isTablet ? 36 : 42),
                  fontWeight: FontWeight.w900,
                  color: isDarkMode ? softWhite : deepPurple,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),

        Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 600,
          ),
          child: Text(
            'Cada herramienta está diseñada para apoyar tu proceso de sanación y crecimiento personal. Inicia sesión para acceder a tu viaje hacia el bienestar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color:
                  isDarkMode ? Colors.grey[300] : deepPurple.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesGrid(bool isMobile, bool isTablet) {
    final services = [
      {
        'icon': Icons.checklist,
        'title': 'Lista de Tareas de Bienestar',
        'description':
            'Organiza tu rutina diaria con recordatorios personalizados para tu salud mental',
        'color': mentalhealthGreen,
        'features': [
          'Recordatorios personalizados',
          'Seguimiento de hábitos',
          'Metas de bienestar',
        ],
      },
      {
        'icon': Icons.psychology,
        'title': 'Asistente IA Terapéutica',
        'description':
            'Chatbot especializado en salud mental disponible 24/7 para apoyo emocional',
        'color': vibrantPurple,
        'features': [
          'Apoyo emocional inmediato',
          'Técnicas de relajación',
          'Juegos interactivos',
        ],
      },
      {
        'icon': Icons.games_outlined,
        'title': 'Ejercicios Mindfulness',
        'description':
            'Actividades interactivas para reducir el estrés y mejorar tu concentración',
        'color': accentPink,
        'features': [
          'Meditaciones guiadas',
          'Respiración consciente',
          'Relajación muscular',
        ],
      },
    ];

    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: isMobile ? 1.1 : 1.0,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return _buildServiceCard(
              service['icon'] as IconData,
              service['title'] as String,
              service['description'] as String,
              service['color'] as Color,
              service['features'] as List<String>,
              index,
            );
          },
        );
      },
    );
  }

  Widget _buildServiceCard(
    IconData icon,
    String title,
    String description,
    Color accentColor,
    List<String> features,
    int index,
  ) {
    return Transform.translate(
      offset: Offset(0, (1 - _cardAnimation.value) * 50),
      child: Opacity(
        opacity: _cardAnimation.value.clamp(0.0, 1.0),
        child: GestureDetector(
          onTap: () => _showLoginRequiredDialog(title),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? cardDark.withOpacity(0.8)
                      : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Icon(icon, color: accentColor, size: 24),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.lock, color: accentColor, size: 14),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? softWhite : deepPurple,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        isDarkMode
                            ? Colors.grey[300]
                            : deepPurple.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        features.map((feature) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 4),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          isDarkMode
                                              ? Colors.grey[400]
                                              : deepPurple.withOpacity(0.6),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Acceder al Servicio',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: accentColor, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallToAction(bool isMobile) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 500, // Limitamos el ancho máximo
        ),
        padding: EdgeInsets.all(isMobile ? 20 : 24), // Padding más pequeño
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [vibrantPurple, lightPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20), // Radio más pequeño
          boxShadow: [
            BoxShadow(
              color: vibrantPurple.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60, // Icono más pequeño
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.favorite, color: softWhite, size: 30),
            ),
            SizedBox(height: 16), // Espacios más pequeños
            Text(
              '¡Comienza tu viaje hacia el bienestar!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 20 : 24, // Texto más pequeño
                fontWeight: FontWeight.w800,
                color: softWhite,
                height: 1.2,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Únete a miles de personas que ya han transformado su salud mental con Alegra.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16, // Texto más pequeño
                color: softWhite.withOpacity(0.9),
                height: 1.5,
              ),
            ),
            SizedBox(height: 20), // Espacios más pequeños
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: softWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: deepPurple,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 24,
                    vertical: isMobile ? 12 : 14, // Padding más pequeño
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const UnifiedLoginPage(nombreUsuario: null),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Iniciar Sesión Ahora',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16, // Texto más pequeño
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.arrow_forward, size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Clases auxiliares para las decoraciones flotantes
class FloatingDecoration {
  late double x;
  late double y;
  late double speed;
  late double size;
  late double opacity;
  late Color color;

  FloatingDecoration() {
    reset();
  }

  void reset() {
    final random = math.Random();
    x = random.nextDouble();
    y = 1.0 + random.nextDouble() * 0.1;
    speed = 0.001 + random.nextDouble() * 0.002;
    size = 8 + random.nextDouble() * 12;
    opacity = 0.3 + random.nextDouble() * 0.4;

    final colors = [
      Color(0xFF6366F1),
      Color(0xFFA855F7),
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
      Color(0xFF10B981),
    ];
    color = colors[random.nextInt(colors.length)];
  }

  void update() {
    y -= speed;
    if (y < -0.1) {
      reset();
    }
  }
}

class FloatingDecorationsPainter extends CustomPainter {
  final List<FloatingDecoration> decorations;
  final double animationValue;
  final bool isDarkMode;

  FloatingDecorationsPainter(
    this.decorations,
    this.animationValue,
    this.isDarkMode,
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (var decoration in decorations) {
      decoration.update();

      final paint =
          Paint()
            ..color = decoration.color.withOpacity(
              decoration.opacity * (isDarkMode ? 0.6 : 0.8),
            )
            ..style = PaintingStyle.fill;

      final position = Offset(
        decoration.x * size.width,
        decoration.y * size.height,
      );

      canvas.drawCircle(position, decoration.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}