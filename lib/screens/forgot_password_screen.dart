import 'package:flutter/material.dart';
import '../services/api_password_reset.dart';
import 'dart:math' as math;

// Clases de partículas para animación de fondo
class Particle {
  late double x;
  late double y;
  late double speed;
  late double size;
  late double opacity;
  late double angle;

  Particle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = 1.0 + math.Random().nextDouble() * 0.1;
    speed = 0.0005 + math.Random().nextDouble() * 0.001;
    size = 1 + math.Random().nextDouble() * 2;
    opacity = 0.1 + math.Random().nextDouble() * 0.3;
    angle = math.Random().nextDouble() * 2 * math.pi;
  }

  void update() {
    y -= speed;
    x += math.sin(angle) * 0.0001;
    if (y < -0.1) {
      reset();
    }
  }
}

class ModernParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final bool isDarkMode;

  ModernParticlesPainter(this.particles, this.animationValue, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();

      final paint =
          Paint()
            ..color =
                isDarkMode
                    ? const Color(0xFF8B5CF6).withOpacity(
                      particle.opacity,
                    ) // cloudBlue
                    : const Color(0xFF6366F1).withOpacity(
                      particle.opacity * 0.4,
                    ) // vibrantPurple
            ..style = PaintingStyle.fill;

      final position = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  bool isDarkMode = false;
  bool emailSent = false;

  // Controladores de animación
  late AnimationController _animationController;
  late AnimationController _particlesController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  List<Particle> particles = [];
  final int particleCount = 12;

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
    _initAnimations();
    _initParticles();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  void _initParticles() {
    particles.clear();
    for (int i = 0; i < particleCount; i++) {
      particles.add(Particle());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particlesController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Por favor, ingresa tu correo electrónico", accentPink);
      return;
    }

    if (!PasswordResetService.isValidEmail(email)) {
      _showSnackBar("Por favor, ingresa un correo válido", accentPink);
      return;
    }

    setState(() => isLoading = true);

    final response = await PasswordResetService.requestPasswordReset(email);

    setState(() => isLoading = false);

    if (response["success"]) {
      setState(() => emailSent = true);
      _showSnackBar(
        response["data"]["message"] ?? "Enlace enviado a tu correo",
        mentalhealthGreen,
      );
    } else {
      _showSnackBar(
        response["data"]["message"] ?? "Error al enviar el enlace",
        accentPink,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _responsiveIconButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: MediaQuery.of(context).size.width < 600 ? 44 : 48,
          height: MediaQuery.of(context).size.width < 600 ? 44 : 48,
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? cardDark.withOpacity(0.8)
                    : softWhite.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDarkMode
                      ? vibrantPurple.withOpacity(0.3)
                      : deepPurple.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isDarkMode ? softWhite : deepPurple,
            size: MediaQuery.of(context).size.width < 600 ? 20 : 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : softWhite,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient:
              isDarkMode
                  ? RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [
                      deepPurple.withOpacity(0.3),
                      darkBackground,
                      Color(0xFF0A0614),
                    ],
                  )
                  : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      softWhite,
                      vibrantPurple.withOpacity(0.05),
                      lightPurple.withOpacity(0.03),
                    ],
                  ),
        ),
        child: Stack(
          children: [
            // Partículas de fondo
            AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ModernParticlesPainter(
                    particles,
                    _particlesController.value,
                    isDarkMode,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Contenido principal
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height),
                child: SafeArea(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeInAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16.0 : 24.0,
                              vertical: 80,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Card principal
                                Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        isSmallScreen ? double.infinity : 750,
                                  ),
                                  padding: EdgeInsets.all(
                                    isSmallScreen ? 24 : 32,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isDarkMode
                                            ? cardDark.withOpacity(0.95)
                                            : Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color:
                                          isDarkMode
                                              ? vibrantPurple.withOpacity(0.2)
                                              : deepPurple.withOpacity(0.1),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isDarkMode
                                                ? Colors.black
                                                : vibrantPurple)
                                            .withOpacity(
                                              isDarkMode ? 0.3 : 0.08,
                                            ),
                                        blurRadius: 30,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child:
                                      emailSent
                                          ? _buildSuccessContent()
                                          : _buildFormContent(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Botones superiores
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _responsiveIconButton(
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),
                  _responsiveIconButton(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    () => setState(() => isDarkMode = !isDarkMode),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono principal
        Container(
          width: isSmallScreen ? 70 : 80,
          height: isSmallScreen ? 70 : 80,
          decoration: BoxDecoration(
            color: vibrantPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: vibrantPurple.withOpacity(0.3), width: 2),
          ),
          child: Icon(
            Icons.lock_reset,
            size: isSmallScreen ? 35 : 40,
            color: vibrantPurple,
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 24),

        // Título
        Text(
          "¿Olvidaste tu contraseña?",
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 28,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? softWhite : deepPurple,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),

        // Subtítulo
        Text(
          "Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color:
                isDarkMode
                    ? softWhite.withOpacity(0.7)
                    : deepPurple.withOpacity(0.7),
            height: 1.4,
          ),
        ),
        SizedBox(height: isSmallScreen ? 28 : 32),

        // Campo de email
        Container(
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? cardDark.withOpacity(0.5)
                    : lightPurple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDarkMode
                      ? vibrantPurple.withOpacity(0.3)
                      : deepPurple.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            style: TextStyle(
              color: isDarkMode ? softWhite : deepPurple,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            decoration: InputDecoration(
              labelText: "Correo electrónico",
              labelStyle: TextStyle(
                color:
                    isDarkMode
                        ? softWhite.withOpacity(0.7)
                        : deepPurple.withOpacity(0.7),
              ),
              prefixIcon: Icon(Icons.email_outlined, color: vibrantPurple),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 28 : 32),

        // Botón de enviar
        Container(
          width: double.infinity,
          height: isSmallScreen ? 50 : 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [vibrantPurple, lightPurple],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: vibrantPurple.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _requestPasswordReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child:
                isLoading
                    ? SizedBox(
                      width: isSmallScreen ? 20 : 24,
                      height: isSmallScreen ? 20 : 24,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      "Enviar enlace de recuperación",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),

        // Link para volver al login
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Volver al inicio de sesión",
            style: TextStyle(
              color: cloudBlue,
              fontSize: isSmallScreen ? 13 : 14,
              decoration: TextDecoration.underline,
              decorationColor: cloudBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono de éxito
        Container(
          width: isSmallScreen ? 80 : 90,
          height: isSmallScreen ? 80 : 90,
          decoration: BoxDecoration(
            color: mentalhealthGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: mentalhealthGreen.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.mark_email_unread,
            size: isSmallScreen ? 40 : 45,
            color: mentalhealthGreen,
          ),
        ),
        SizedBox(height: isSmallScreen ? 24 : 28),

        // Título de éxito
        Text(
          "¡Correo enviado!",
          style: TextStyle(
            fontSize: isSmallScreen ? 26 : 30,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? softWhite : deepPurple,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),

        // Mensaje de éxito
        Text(
          "Hemos enviado un enlace de recuperación a:",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color:
                isDarkMode
                    ? softWhite.withOpacity(0.7)
                    : deepPurple.withOpacity(0.7),
            height: 1.4,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),

        // Email destacado
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 20,
            vertical: isSmallScreen ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? cardDark.withOpacity(0.5)
                    : lightPurple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDarkMode
                      ? vibrantPurple.withOpacity(0.3)
                      : deepPurple.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            emailController.text.trim(),
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: vibrantPurple,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 24),

        // Instrucciones
        Text(
          "Revisa tu bandeja de entrada y haz clic en el enlace para restablecer tu contraseña. El enlace expirará en 1 hora.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            color:
                isDarkMode
                    ? softWhite.withOpacity(0.7)
                    : deepPurple.withOpacity(0.7),
            height: 1.5,
          ),
        ),
        SizedBox(height: isSmallScreen ? 28 : 32),

        // Botón para reenviar
        Container(
          width: double.infinity,
          height: isSmallScreen ? 48 : 52,
          child: OutlinedButton.icon(
            onPressed:
                isLoading
                    ? null
                    : () {
                      setState(() => emailSent = false);
                      _requestPasswordReset();
                    },
            icon: Icon(
              Icons.refresh,
              color: vibrantPurple,
              size: isSmallScreen ? 18 : 20,
            ),
            label: Text(
              "Reenviar enlace",
              style: TextStyle(
                color: vibrantPurple,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: vibrantPurple, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),

        // Link para volver al login
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Volver al inicio de sesión",
            style: TextStyle(
              color: cloudBlue,
              fontSize: isSmallScreen ? 13 : 14,
              decoration: TextDecoration.underline,
              decorationColor: cloudBlue,
            ),
          ),
        ),
      ],
    );
  }
}
