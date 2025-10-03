import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../Admin/AdminScreen.dart'; // Pantalla de admin

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  String? _errorMessage;
  bool cargando = false;
  bool isDarkMode = false;
  bool _obscurePassword = true;

  // Animaciones
  late AnimationController _animationController;
  late AnimationController _particlesController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  List<Particle> particles = [];
  final int particleCount = 15;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initParticles();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(seconds: 25),
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

  void _login() {
    String user = _userController.text.trim();
    String pass = _passController.text.trim();

    setState(() => cargando = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => cargando = false);

      if (user == 'admin' && pass == '1234') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
      } else {
        setState(() {
          _errorMessage = '❌ Usuario o contraseña incorrectos';
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFFAFAFA),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient:
              isDarkMode
                  ? const RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [
                      Color(0xFF1A2332),
                      Color(0xFF0F1419),
                      Color(0xFF0A0E14),
                    ],
                  )
                  : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFF8F6F0),
                      Color(0xFFF0EDE5),
                    ],
                  ),
        ),
        child: Stack(
          children: [
            // Fondo de partículas
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
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDarkMode ? Colors.white : Colors.black54,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Botón Dark/Light mode
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: isDarkMode ? Colors.white : Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                ),
              ),
            ),

            // Contenido principal
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeInAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height,
                            maxWidth: 450,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 80),

                              // Card principal
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode
                                          ? const Color(
                                            0xFF1A2332,
                                          ).withOpacity(0.8)
                                          : Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color:
                                        isDarkMode
                                            ? const Color(0xFF2A3441)
                                            : Colors.grey.withOpacity(0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        isDarkMode ? 0.3 : 0.08,
                                      ),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Icono
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color:
                                            isDarkMode
                                                ? const Color(
                                                  0xFF00D4FF,
                                                ).withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        Icons.admin_panel_settings,
                                        size: 40,
                                        color:
                                            isDarkMode
                                                ? const Color(0xFF00D4FF)
                                                : Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    Text(
                                      "Login Administrador",
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : const Color(0xFF1A2332),
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Campo usuario
                                    _buildUserField(),

                                    const SizedBox(height: 20),

                                    // Campo contraseña
                                    _buildPasswordField(),

                                    const SizedBox(height: 32),

                                    // Botón login
                                    _buildLoginButton(),

                                    if (_errorMessage != null) ...[
                                      const SizedBox(height: 20),
                                      Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserField() {
    return Container(
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? const Color(0xFF2A3441).withOpacity(0.5)
                : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF3A4451) : Colors.grey[200]!,
        ),
      ),
      child: TextField(
        controller: _userController,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: "Usuario",
          labelStyle: TextStyle(
            color: isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.person_outline,
            color:
                isDarkMode ? const Color(0xFF00D4FF) : const Color(0xFF00D4FF),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? const Color(0xFF2A3441).withOpacity(0.5)
                : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF3A4451) : Colors.grey[200]!,
        ),
      ),
      child: TextField(
        controller: _passController,
        obscureText: _obscurePassword,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: "Contraseña",
          labelStyle: TextStyle(
            color: isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
          ),
          prefixIcon: Icon(Icons.lock_outline, color: const Color(0xFF00D4FF)),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [const Color(0xFF00D4FF), const Color(0xFF0099CC)]
                  : [Colors.grey[800]!, Colors.grey[700]!],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? const Color(0xFF00D4FF) : Colors.grey[700]!)
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: cargando ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            cargando
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Text(
                  "Ingresar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}

// Partículas
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
                    ? const Color(0xFF00D4FF).withOpacity(particle.opacity)
                    : Colors.grey.withOpacity(particle.opacity * 0.4)
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
