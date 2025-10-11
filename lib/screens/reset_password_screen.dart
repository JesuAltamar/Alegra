// screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import '../services/api_password_reset.dart';
import 'dart:math' as math;

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool isDarkMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool tokenValid = false;
  bool tokenVerified = false;
  Map<String, dynamic>? userInfo;
  bool passwordReset = false;

  // Controladores de animación
  late AnimationController _animationController;
  late AnimationController _particlesController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  List<Particle> particles = [];
  final int particleCount = 10;

@override
void initState() {
  super.initState();
  print('🚀 Iniciando ResetPasswordScreen con token: ${widget.token.substring(0, 30)}...');
  _initAnimations();
  _initParticles();
  _verifyToken();
  
  // Debugging temporal
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _debugInfo();
  });
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
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyToken() async {
  print('🔍 Verificando token: ${widget.token.substring(0, 20)}...');
  
  setState(() => isLoading = true);

  final response = await PasswordResetService.verifyResetToken(widget.token);
  
  print('📦 Respuesta verifyToken: $response');

  setState(() {
    isLoading = false;
    tokenVerified = true;
  });

  if (response["success"]) {
    setState(() {
      tokenValid = true;
      // CORRECCIÓN: Acceder correctamente a los datos del usuario
      userInfo = response["data"]["usuario"] ?? response["data"];
    });
    print('✅ Token válido, usuario: ${userInfo?['nombre']}');
  } else {
    print('❌ Token inválido: ${response["data"]["message"]}');
    _showSnackBar(
      response["data"]["message"] ?? "Token inválido o expirado",
      Colors.red,
    );
  }
}

// ---------------------------------------------------------------
Future<void> _resetPassword() async {
  final password = passwordController.text;
  final confirmPassword = confirmPasswordController.text;

  if (password.isEmpty || confirmPassword.isEmpty) {
    _showSnackBar("Por favor, completa todos los campos", Colors.orange);
    return;
  }

  if (password != confirmPassword) {
    _showSnackBar("Las contraseñas no coinciden", Colors.orange);
    return;
  }

  final passwordValidation = PasswordResetService.validatePassword(password);
  if (!passwordValidation['isValid']) {
    final errors = passwordValidation['errors'] as List<String>;
    _showSnackBar("Contraseña no válida: ${errors.first}", Colors.orange);
    return;
  }

  print('🔄 Iniciando reset de contraseña...');
  setState(() => isLoading = true);

  final response = await PasswordResetService.resetPassword(
    widget.token,
    password,
  );

  print('📦 Respuesta resetPassword: $response');
  setState(() => isLoading = false);

  if (response["success"]) {
    setState(() {
      passwordReset = true;
      // CORRECCIÓN: Actualizar userInfo si viene en la respuesta
      if (response["data"]["usuario"] != null) {
        userInfo = response["data"]["usuario"];
      }
    });
    _showSnackBar(
      response["data"]["message"] ?? "Contraseña actualizada exitosamente",
      Colors.green,
    );
    print('✅ Contraseña actualizada exitosamente');
  } else {
    _showSnackBar(
      response["data"]["message"] ?? "Error al actualizar la contraseña",
      Colors.red,
    );
    print('❌ Error al actualizar contraseña: ${response["data"]["message"]}');
  }
}

// 3. AGREGAR método de debugging (temporal)
void _debugInfo() {
  print('=== DEBUG INFO ===');
  print('Token: ${widget.token.substring(0, 30)}...');
  print('TokenVerified: $tokenVerified');
  print('TokenValid: $tokenValid');
  print('PasswordReset: $passwordReset');
  print('UserInfo: $userInfo');
  print('==================');
}
  /////------------------------------------------------------------
void _showSnackBar(String message, Color color) {
  print('📢 SnackBar: $message');
  
  if (!mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4), // Más tiempo para leer
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
                                  child: _buildContent(),
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

            // Botón superior derecho
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 20,
              child: _responsiveIconButton(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                () => setState(() => isDarkMode = !isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!tokenVerified) {
      return _buildLoadingContent();
    } else if (!tokenValid) {
      return _buildInvalidTokenContent();
    } else if (passwordReset) {
      return _buildSuccessContent();
    } else {
      return _buildResetFormContent();
    }
  }

  Widget _buildLoadingContent() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: isSmallScreen ? 50 : 60,
          height: isSmallScreen ? 50 : 60,
          child: CircularProgressIndicator(
            color: isDarkMode ? const Color(0xFF00D4FF) : Colors.grey[700],
            strokeWidth: 3,
          ),
        ),
        SizedBox(height: isSmallScreen ? 24 : 28),
        Text(
          "Verificando enlace...",
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1A2332),
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Text(
          "Por favor espera mientras validamos tu enlace de recuperación",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInvalidTokenContent() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSmallScreen ? 70 : 80,
          height: isSmallScreen ? 70 : 80,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.error_outline,
            size: isSmallScreen ? 35 : 40,
            color: Colors.red,
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 24),

        Text(
          "Enlace no válido",
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 28,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : const Color(0xFF1A2332),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),

        Text(
          "El enlace de recuperación ha expirado o no es válido. Solicita un nuevo enlace para restablecer tu contraseña.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
            height: 1.4,
          ),
        ),
        SizedBox(height: isSmallScreen ? 28 : 32),

        Container(
          width: double.infinity,
          height: isSmallScreen ? 48 : 52,
          child: ElevatedButton.icon(
            onPressed:
                () =>
                    Navigator.pushReplacementNamed(context, '/forgot-password'),
            icon: const Icon(Icons.refresh),
            label: const Text("Solicitar nuevo enlace"),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDarkMode ? const Color(0xFF00D4FF) : Colors.grey[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  
  // Continúa desde ResetPasswordScreen - Métodos restantes
Widget _buildResetFormContent() {
  final isSmallScreen = MediaQuery.of(context).size.width < 600;
  final passwordValidation = PasswordResetService.validatePassword(
    passwordController.text,
  );

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Icono principal
      Container(
        width: isSmallScreen ? 70 : 80,
        height: isSmallScreen ? 70 : 80,
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? const Color(0xFF00D4FF).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.lock_reset,
          size: isSmallScreen ? 35 : 40,
          color: isDarkMode ? const Color(0xFF00D4FF) : Colors.grey[700],
        ),
      ),
      SizedBox(height: isSmallScreen ? 20 : 24),

      // Título
      Text(
        "Nueva contraseña",
        style: TextStyle(
          fontSize: isSmallScreen ? 24 : 28,
          fontWeight: FontWeight.w700,
          color: isDarkMode ? Colors.white : const Color(0xFF1A2332),
          letterSpacing: -0.5,
        ),
      ),
      SizedBox(height: isSmallScreen ? 6 : 8),

      // CORRECCIÓN: Usuario info con validación mejorada
      if (userInfo != null && userInfo!['nombre'] != null && userInfo!['correo'] != null) ...[
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 20,
            vertical: isSmallScreen ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? const Color(0xFF2A3441).withOpacity(0.3)
                    : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color:
                    isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "${userInfo!['nombre']} (${userInfo!['correo']})",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color:
                        isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 24),
      ],

      // Campo nueva contraseña
      _buildPasswordField(),
      SizedBox(height: isSmallScreen ? 16 : 20),

      // Indicador de fortaleza
      if (passwordController.text.isNotEmpty) ...[
        _buildPasswordStrengthIndicator(passwordValidation),
        SizedBox(height: isSmallScreen ? 16 : 20),
      ],

      // Campo confirmar contraseña
      _buildConfirmPasswordField(),
      SizedBox(height: isSmallScreen ? 28 : 32),

      // Botón restablecer - MEJORADO
      Container(
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
              color: (isDarkMode
                      ? const Color(0xFF00D4FF)
                      : Colors.grey[700]!)
                  .withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: (isLoading || 
                      passwordController.text.isEmpty || 
                      confirmPasswordController.text.isEmpty ||
                      passwordController.text != confirmPasswordController.text) 
              ? null 
              : _resetPassword,
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
                    "Restablecer contraseña",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        ),
      ),

    
      if (const bool.fromEnvironment('dart.vm.product') == false) ...[
        SizedBox(height: isSmallScreen ? 16 : 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.yellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.yellow.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "DEBUG INFO:",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.yellow[200] : Colors.orange[800],
                ),
              ),
              Text(
                "Token: ${widget.token.substring(0, 30)}...",
                style: TextStyle(
                  fontSize: 9,
                  color: isDarkMode ? Colors.yellow[200] : Colors.orange[700],
                ),
              ),
              Text(
                "Valid: $tokenValid | User: ${userInfo?['nombre'] ?? 'null'}",
                style: TextStyle(
                  fontSize: 9,
                  color: isDarkMode ? Colors.yellow[200] : Colors.orange[700],
                ),
              ),
            ],
          ),
        ),
      ],
    ],
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
        onChanged:
            (_) => setState(() {}), // Para actualizar indicador en tiempo real
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        decoration: InputDecoration(
          labelText: "Nueva contraseña",
          labelStyle: TextStyle(
            color: isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
          ),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00D4FF)),
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

  Widget _buildConfirmPasswordField() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isMatching =
        passwordController.text == confirmPasswordController.text;
    final showError = confirmPasswordController.text.isNotEmpty && !isMatching;

    return Container(
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? const Color(0xFF2A3441).withOpacity(0.5)
                : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              showError
                  ? Colors.red
                  : isDarkMode
                  ? const Color(0xFF3A4451)
                  : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: TextField(
        controller: confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        onChanged:
            (_) => setState(() {}), // Para actualizar validación en tiempo real
        // Continuación del método _buildConfirmPasswordField
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        decoration: InputDecoration(
          labelText: "Confirmar contraseña",
          labelStyle: TextStyle(
            color: isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
          ),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00D4FF)),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (confirmPasswordController.text.isNotEmpty)
                Icon(
                  isMatching ? Icons.check_circle : Icons.error,
                  color: isMatching ? Colors.green : Colors.red,
                  size: 20,
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color:
                      isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          helperText: showError ? "Las contraseñas no coinciden" : null,
          helperStyle: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(Map<String, dynamic> validation) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final strength = validation['strength'] as int;
    final errors = validation['errors'] as List<String>;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? const Color(0xFF2A3441).withOpacity(0.3)
                : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF3A4451) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y nivel de fortaleza
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fortaleza de contraseña",
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                PasswordResetService.getPasswordStrengthText(strength),
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 13,
                  fontWeight: FontWeight.w500,
                  color: Color(
                    PasswordResetService.getPasswordStrengthColor(strength),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),

          // Barra de progreso
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF3A4451) : Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color:
                          index < strength
                              ? Color(
                                PasswordResetService.getPasswordStrengthColor(
                                  strength,
                                ),
                              )
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Errores de validación
          if (errors.isNotEmpty) ...[
            SizedBox(height: isSmallScreen ? 8 : 12),
            ...errors
                .map(
                  (error) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color:
                              isDarkMode
                                  ? const Color(0xFFB0B8C4)
                                  : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            error,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color:
                                  isDarkMode
                                      ? const Color(0xFFB0B8C4)
                                      : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ],
      ),
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
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: isSmallScreen ? 40 : 45,
            color: Colors.green,
          ),
        ),
        SizedBox(height: isSmallScreen ? 24 : 28),

        // Título de éxito
        Text(
          "¡Contraseña actualizada!",
          style: TextStyle(
            fontSize: isSmallScreen ? 26 : 30,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : const Color(0xFF1A2332),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),

        // Mensaje de éxito
        Text(
          "Tu contraseña ha sido restablecida exitosamente. Ahora puedes iniciar sesión con tu nueva contraseña.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
            height: 1.5,
          ),
        ),
        SizedBox(height: isSmallScreen ? 28 : 32),

        // Usuario info
        if (userInfo != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20,
              vertical: isSmallScreen ? 16 : 20,
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2A3441).withOpacity(0.3)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? const Color(0xFF3A4451) : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isSmallScreen ? 40 : 44,
                  height: isSmallScreen ? 40 : 44,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.green,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userInfo!['nombre'],
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userInfo!['correo'],
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          color: isDarkMode ? const Color(0xFFB0B8C4) : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.verified_user,
                  color: Colors.green,
                  size: isSmallScreen ? 20 : 24,
                ),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 24 : 28),
        ],

        // Botón ir al login
        Container(
          width: double.infinity,
          height: isSmallScreen ? 50 : 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.green[600]!, Colors.green[700]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              // Navegar al login, limpiando toda la pila de navegación
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            icon: const Icon(Icons.login, color: Colors.white),
            label: Text(
              "Iniciar Sesión",
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),

        // Mensaje de seguridad
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.blue.withOpacity(0.1)
                : Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.blue,
                size: isSmallScreen ? 16 : 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Por seguridad, cierra sesión en todos los dispositivos y vuelve a iniciar sesión.",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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

      final paint = Paint()
        ..color = isDarkMode
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
