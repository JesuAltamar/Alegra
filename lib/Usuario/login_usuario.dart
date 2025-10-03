import 'package:flutter/material.dart';
import 'package:pro9/Pagina_inicio/UnifiedLoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_auth.dart';
import 'package:pro9/Usuario/home_page.dart';
import 'dart:math' as math;

class LoginUsuario extends StatefulWidget {
  const LoginUsuario({super.key});

  @override
  _LoginUsuarioState createState() => _LoginUsuarioState();
}

class _LoginUsuarioState extends State<LoginUsuario>
    with TickerProviderStateMixin {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool cargando = false;
  bool isDarkMode = false;
  bool _obscurePassword = true;

  List<String> _correosGuardados = [];

  // Controladores de animación
  late AnimationController _animationController;
  late AnimationController _particlesController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  List<Particle> particles = [];
  final int particleCount = 15;

  @override
  void initState() {
    super.initState();
    _cargarCorreos();
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

  @override
  void dispose() {
    _animationController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  Future<void> _cargarCorreos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _correosGuardados = prefs.getStringList("correos") ?? [];
    });
  }

  Future<void> _guardarCorreo(String correo) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_correosGuardados.contains(correo)) {
      _correosGuardados.add(correo);
      await prefs.setStringList("correos", _correosGuardados);
    }
  }

  Future<void> _login() async {
    setState(() => cargando = true);

    final response = await loginUsuario(
      correoController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => cargando = false);

    if (response["success"]) {
      final usuario = response["data"]["usuario"];
      final nombre = usuario["nombre"];

      await _guardarCorreo(correoController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ Login exitoso"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UnifiedLoginPage (nombreUsuario: nombre)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: ${response["data"]["message"]}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
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
          child: Icon(
            icon,
            color: isDarkMode ? Colors.white : Colors.black54,
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

            // Contenido principal con scroll global
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
                              vertical:
                                  80, // Espacio para los botones superiores
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
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                          isDarkMode ? 0.3 : 0.08,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Icono principal
                                      Container(
                                        width: isSmallScreen ? 70 : 80,
                                        height: isSmallScreen ? 70 : 80,
                                        decoration: BoxDecoration(
                                          color:
                                              isDarkMode
                                                  ? const Color(
                                                    0xFF00D4FF,
                                                  ).withOpacity(0.1)
                                                  : Colors.grey.withOpacity(
                                                    0.1,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.lock_outline,
                                          size: isSmallScreen ? 35 : 40,
                                          color:
                                              isDarkMode
                                                  ? const Color(0xFF00D4FF)
                                                  : Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 20 : 24),

                                      // Título
                                      Text(
                                        "Bienvenido de vuelta",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 24 : 28,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : const Color(0xFF1A2332),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 6 : 8),

                                      // Subtítulo
                                      Text(
                                        "Inicia sesión para continuar con tu bienestar",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color:
                                              isDarkMode
                                                  ? const Color(0xFFB0B8C4)
                                                  : Colors.grey[600],
                                          height: 1.4,
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 28 : 32),

                                      // Campo de correo con Autocomplete
                                      _buildEmailField(),
                                      SizedBox(height: isSmallScreen ? 16 : 20),

                                      // Campo de contraseña
                                      _buildPasswordField(),
                                      SizedBox(height: isSmallScreen ? 28 : 32),

                                      // Botón de login
                                      _buildLoginButton(),
                                      SizedBox(height: isSmallScreen ? 16 : 20),

                                      // Link de recuperación
                                      TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          "¿Olvidaste tu contraseña?",
                                          style: TextStyle(
                                            color:
                                                isDarkMode
                                                    ? const Color(0xFF00D4FF)
                                                    : Colors.grey[600],
                                            fontSize: isSmallScreen ? 13 : 14,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                isDarkMode
                                                    ? const Color(0xFF00D4FF)
                                                    : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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

            // Botones posicionados de forma absoluta (encima de todo)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón de retroceso (esquina superior izquierda)
                  _responsiveIconButton(
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),

                  // Botón Dark/Light mode (esquina superior derecha)
                  _responsiveIconButton(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    () {
                      setState(() {
                        isDarkMode = !isDarkMode;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _correosGuardados.where(
          (correo) => correo.toLowerCase().contains(value.text.toLowerCase()),
        );
      },
      onSelected: (String seleccion) {
        correoController.text = seleccion;
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        correoController.text = controller.text;
        return Container(
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? const Color(0xFF2A3441).withOpacity(0.5)
                    : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF3A4451) : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onEditingComplete: onEditingComplete,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            decoration: InputDecoration(
              labelText: "Correo electrónico",
              labelStyle: TextStyle(
                color: isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: const Color(0xFF00D4FF),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: isDarkMode ? const Color(0xFF1A2332) : Colors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200,
                maxWidth:
                    isSmallScreen
                        ? MediaQuery.of(context).size.width * 0.8
                        : 350,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    leading: Icon(
                      Icons.email_outlined,
                      color:
                          isDarkMode
                              ? const Color(0xFF00D4FF)
                              : Colors.grey[600],
                    ),
                    title: Text(
                      option,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? const Color(0xFF2A3441).withOpacity(0.5)
                : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF3A4451) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: TextField(
        controller: passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: isSmallScreen ? 14 : 16,
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
          contentPadding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      height: isSmallScreen ? 50 : 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [const Color(0xFF00D4FF), const Color(0xFF0099CC)]
                  : [Colors.grey[800]!, Colors.grey[700]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? const Color(0xFF00D4FF) : Colors.grey[700]!)
                .withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
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
                ? SizedBox(
                  width: isSmallScreen ? 20 : 24,
                  height: isSmallScreen ? 20 : 24,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  "Iniciar Sesión",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}

// Clases de partículas
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
