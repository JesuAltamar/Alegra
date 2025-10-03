import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_auth.dart';
import '../Admin/AdminScreen.dart';
import 'package:pro9/Usuario/home_page.dart';
import 'package:pro9/Registros_usuarios_y_evaluaciones/usuinterfaz.dart';

class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key, required nombreUsuario});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage>
    with TickerProviderStateMixin {
  // Controladores
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Estado
  bool cargando = false;
  bool isDarkMode = false;
  bool _obscurePassword = true;
  bool isUserLogin = true;
  String? _errorMessage;
  List<String> _correosGuardados = [];

  // Animaciones
  late AnimationController _animationController;
  late AnimationController _switchController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _switchAnimation;

  // Paleta de colores idéntica a RegistroPage
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
    _cargarCorreos();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _switchController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

    _switchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _switchController, curve: Curves.easeInOut),
    );

    _animationController.forward();
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

  void _switchLoginType() {
    setState(() {
      isUserLogin = !isUserLogin;
      _errorMessage = null;
      _userController.clear();
      _passController.clear();
      _emailController.clear();
    });

    _switchController.forward().then((_) {
      _switchController.reset();
    });
  }

  Future<void> _login() async {
    setState(() {
      cargando = true;
      _errorMessage = null;
    });

    if (isUserLogin) {
      // Login de Usuario
      final response = await loginUsuario(
        _emailController.text.trim(),
        _passController.text.trim(),
      );

      setState(() => cargando = false);

      if (response["success"]) {
        final usuario = response["data"]["usuario"];
        final nombre = usuario["nombre"];

        await _guardarCorreo(_emailController.text.trim());
        final token = response["data"]["token"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Login exitoso"),
            backgroundColor: mentalhealthGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    HomePage(nombreUsuario: nombre, usuarioId: usuario["id"]),
          ),
        );
      } else {
        setState(() {
          _errorMessage = "Error: ${response["data"]["message"]}";
        });
      }
    } else {
      // Login de Admin
      await Future.delayed(const Duration(seconds: 1));
      setState(() => cargando = false);

      String user = _userController.text.trim();
      String pass = _passController.text.trim();

      if (user == 'admin' && pass == '1234') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
      } else {
        setState(() {
          _errorMessage = 'Usuario o contraseña incorrectos';
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _switchController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Container(
        margin: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
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
              Icons.arrow_back_ios_new,
              color: isDarkMode ? softWhite : deepPurple,
              size: isSmallScreen ? 18 : 20,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: vibrantPurple,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: vibrantPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.psychology, color: softWhite, size: 16),
          ),
          SizedBox(width: 12),
          Text(
            'ALEGRA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDarkMode ? softWhite : deepPurple,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8),
          child: Container(
            width: isSmallScreen ? 44 : 48,
            height: isSmallScreen ? 44 : 48,
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
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
                color: isDarkMode ? accentPink : vibrantPurple,
                size: isSmallScreen ? 20 : 22,
              ),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : softWhite,
      appBar: _buildAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      softWhite,
                      vibrantPurple.withOpacity(0.05),
                      softWhite,
                    ],
                  ),
        ),
        child: Stack(
          children: [
            // Contenido principal
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeInAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 6.0,
                      radius: const Radius.circular(3.0),
                      scrollbarOrientation: ScrollbarOrientation.right,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight:
                                  size.height -
                                  MediaQuery.of(context).padding.top -
                                  kToolbarHeight -
                                  40,
                              maxWidth: isSmallScreen ? size.width * 0.9 : 450,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 20.0 : 32.0,
                              vertical: 40,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [_buildMainCard(isSmallScreen)],
                            ),
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

  Widget _buildMainCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? cardDark.withOpacity(0.9)
                : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
          if (isDarkMode)
            BoxShadow(
              color: vibrantPurple.withOpacity(0.05),
              blurRadius: 40,
              spreadRadius: -5,
              offset: const Offset(0, 20),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle buttons
          _buildToggleButtons(isSmallScreen),
          SizedBox(height: isSmallScreen ? 24 : 32),

          // Icono principal
          Container(
            width: isSmallScreen ? 60 : 80,
            height: isSmallScreen ? 60 : 80,
            decoration: BoxDecoration(
              color: (isDarkMode ? vibrantPurple : deepPurple).withOpacity(0.1),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(
                color: (isDarkMode ? vibrantPurple : deepPurple).withOpacity(
                  0.2,
                ),
                width: 1,
              ),
            ),
            child: Icon(
              isUserLogin ? Icons.psychology : Icons.admin_panel_settings,
              size: isSmallScreen ? 30 : 40,
              color: isDarkMode ? vibrantPurple : deepPurple,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),

          // Título
          Text(
            isUserLogin ? "Bienvenido a Alegra" : "Panel de Administración",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 30,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? softWhite : deepPurple,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),

          // Subtítulo
          Text(
            isUserLogin
                ? "Tu bienestar mental es nuestra prioridad"
                : "Gestiona el sistema de salud mental",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 15,
              color: isDarkMode ? Colors.grey[300] : Color(0xFF64748B),
              height: 1.6,
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 28),

          // Campos del formulario
          AnimatedBuilder(
            animation: _switchAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  if (isUserLogin) ...[
                    _buildEmailField(),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    _buildPasswordField(),
                  ] else ...[
                    _buildUserField(),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    _buildPasswordField(),
                  ],
                ],
              );
            },
          ),

          SizedBox(height: isSmallScreen ? 20 : 24),

          // Botón de login
          _buildLoginButton(isSmallScreen),

          // Mensaje de error
          if (_errorMessage != null) ...[
            SizedBox(height: isSmallScreen ? 16 : 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentPink.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: accentPink, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: accentPink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: isSmallScreen ? 20 : 28),

          // Olvidaste tu contraseña
          Container(
            decoration: BoxDecoration(
              color: cloudBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cloudBlue.withOpacity(0.3)),
            ),
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
              child: Text(
                "¿Olvidaste tu contraseña?",
                style: TextStyle(
                  color: cloudBlue,
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Registrarse (solo para usuarios)
          if (isUserLogin) ...[
            SizedBox(height: isSmallScreen ? 16 : 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "¿No tienes cuenta? ",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: isDarkMode ? Colors.grey[300] : Color(0xFF64748B),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Registra().registro(context);
                  },
                  child: Text(
                    "Regístrate aquí",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: isDarkMode ? vibrantPurple : deepPurple,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: isDarkMode ? vibrantPurple : deepPurple,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleButtons(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      height: isSmallScreen ? 50 : 56,
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? cardDark.withOpacity(0.5)
                : vibrantPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: vibrantPurple.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isUserLogin) _switchLoginType();
              },
              child: Container(
                height: isSmallScreen ? 50 : 56,
                decoration: BoxDecoration(
                  color: isUserLogin ? vibrantPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow:
                      isUserLogin
                          ? [
                            BoxShadow(
                              color: vibrantPurple.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                          : null,
                ),
                child: Center(
                  child: Text(
                    "Iniciar Sesión",
                    style: TextStyle(
                      color:
                          isUserLogin
                              ? softWhite
                              : (isDarkMode ? softWhite : deepPurple),
                      fontWeight:
                          isUserLogin ? FontWeight.w700 : FontWeight.w500,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isUserLogin) _switchLoginType();
              },
              child: Container(
                height: isSmallScreen ? 50 : 56,
                decoration: BoxDecoration(
                  color: !isUserLogin ? accentPink : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow:
                      !isUserLogin
                          ? [
                            BoxShadow(
                              color: accentPink.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                          : null,
                ),
                child: Center(
                  child: Text(
                    "Administrador",
                    style: TextStyle(
                      color:
                          !isUserLogin
                              ? softWhite
                              : (isDarkMode ? softWhite : deepPurple),
                      fontWeight:
                          !isUserLogin ? FontWeight.w700 : FontWeight.w500,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          fontSize: isSmallScreen ? 13 : 15,
          color: isDarkMode ? softWhite : deepPurple,
        ),
        decoration: InputDecoration(
          labelText: "Email",
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Color(0xFF64748B),
            fontSize: isSmallScreen ? 12 : 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (isDarkMode ? vibrantPurple : deepPurple).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.email_rounded,
              color: isDarkMode ? vibrantPurple : deepPurple,
              size: isSmallScreen ? 16 : 18,
            ),
          ),
          filled: true,
          fillColor:
              isDarkMode
                  ? cardDark.withOpacity(0.8)
                  : Colors.white.withOpacity(0.95),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: BorderSide(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: BorderSide(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: BorderSide(
              color: isDarkMode ? vibrantPurple : deepPurple,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 14 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildUserField() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: TextFormField(
        controller: _userController,
        style: TextStyle(
          fontSize: isSmallScreen ? 13 : 15,
          color: isDarkMode ? softWhite : deepPurple,
        ),
        decoration: InputDecoration(
          labelText: "Usuario",
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Color(0xFF64748B),
            fontSize: isSmallScreen ? 12 : 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: accentPink,
              size: isSmallScreen ? 16 : 18,
            ),
          ),
          filled: true,
          fillColor:
              isDarkMode
                  ? cardDark.withOpacity(0.8)
                  : Colors.white.withOpacity(0.95),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: BorderSide(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: BorderSide(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: BorderSide(color: accentPink, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 14 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: TextFormField(
        controller: _passController,
        obscureText: _obscurePassword,
        style: TextStyle(
          fontSize: isSmallScreen ? 13 : 15,
          color: isDarkMode ? softWhite : deepPurple,
        ),
        decoration: InputDecoration(
          labelText: "Contraseña",
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Color(0xFF64748B),
            fontSize: isSmallScreen ? 12 : 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: mentalhealthGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.lock_rounded,
              color: mentalhealthGreen,
              size: isSmallScreen ? 16 : 18,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: isDarkMode ? Colors.grey[400] : Color(0xFF64748B),
              size: isSmallScreen ? 16 : 18,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          filled: true,
          fillColor:
              isDarkMode
                  ? cardDark.withOpacity(0.8)
                  : Colors.white.withOpacity(0.95),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: BorderSide(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: BorderSide(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            borderSide: BorderSide(color: mentalhealthGreen, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 14 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      height: isSmallScreen ? 48 : 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 14),
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [vibrantPurple, lightPurple]
                  : [deepPurple, vibrantPurple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? vibrantPurple : deepPurple).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.2),
            blurRadius: 4,
            spreadRadius: -1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: cargando ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 14),
          ),
          elevation: 0,
        ),
        child:
            cargando
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isUserLogin ? "Iniciar Sesión" : "Ingresar",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
