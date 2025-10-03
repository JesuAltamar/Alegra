import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pro9/Registros_usuarios_y_evaluaciones/usuarioapi.dart';

class Registra {
  final _formKey = GlobalKey<FormState>();

  final nombre = TextEditingController();
  final fechaNacimiento = TextEditingController();
  final telefono = TextEditingController();
  final correo = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  void registro(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RegistroPage(
              formKey: _formKey,
              nombre: nombre,
              fechaNacimiento: fechaNacimiento,
              telefono: telefono,
              correo: correo,
              password: password,
              confirmPassword: confirmPassword,
            ),
      ),
    );
  }
}

class RegistroPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombre;
  final TextEditingController fechaNacimiento;
  final TextEditingController telefono;
  final TextEditingController correo;
  final TextEditingController password;
  final TextEditingController confirmPassword;

  const RegistroPage({
    super.key,
    required this.formKey,
    required this.nombre,
    required this.fechaNacimiento,
    required this.telefono,
    required this.correo,
    required this.password,
    required this.confirmPassword,
  });

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  bool _isPressed = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isDarkMode = false;

  // Paleta de colores idéntica a ServicesPage
  final Color deepPurple = Color(0xFF2D1B69);
  final Color vibrantPurple = Color(0xFF6366F1);
  final Color lightPurple = Color(0xFFA855F7);
  final Color darkBackground = Color(0xFF0F0A1F);
  final Color cardDark = Color(0xFF1A1335);
  final Color accentPink = Color(0xFFEC4899);
  final Color softWhite = Color(0xFFF8FAFC);
  final Color cloudBlue = Color(0xFF8B5CF6);
  final Color mentalhealthGreen = Color(0xFF10B981);

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale("es", "ES"),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                _isDarkMode
                    ? ColorScheme.dark(
                      primary: vibrantPurple,
                      onSurface: Colors.white,
                    )
                    : ColorScheme.light(
                      primary: deepPurple,
                      onSurface: Colors.black,
                    ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        widget.fechaNacimiento.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.inter(
          fontSize: isMobile ? 13 : 15,
          color: _isDarkMode ? softWhite : deepPurple,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            color: _isDarkMode ? Colors.grey[400] : Color(0xFF64748B),
            fontSize: isMobile ? 12 : 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (_isDarkMode ? vibrantPurple : deepPurple).withOpacity(
                0.1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: _isDarkMode ? vibrantPurple : deepPurple,
              size: isMobile ? 16 : 18,
            ),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor:
              _isDarkMode
                  ? cardDark.withOpacity(0.8)
                  : Colors.white.withOpacity(0.95),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            borderSide: BorderSide(
              color:
                  _isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            borderSide: BorderSide(
              color:
                  _isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            borderSide: BorderSide(
              color: _isDarkMode ? vibrantPurple : deepPurple,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 14 : 16,
          ),
          errorStyle: GoogleFonts.inter(
            color: Colors.red,
            fontSize: isMobile ? 10 : 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
    final maxWidth = isDesktop ? 400.0 : (isTablet ? 450.0 : double.infinity);

    return Scaffold(
      backgroundColor: _isDarkMode ? darkBackground : softWhite,

      // AppBar con colores actualizados
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color:
                  _isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              border: Border.all(
                color:
                    _isDarkMode
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: _isDarkMode ? softWhite : deepPurple,
                size: isMobile ? 18 : 20,
              ),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: horizontalPadding - 10),
            child: Container(
              width: isMobile ? 44 : 48,
              height: isMobile ? 44 : 48,
              decoration: BoxDecoration(
                color:
                    _isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                border: Border.all(
                  color:
                      _isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: _isDarkMode ? accentPink : vibrantPurple,
                  size: isMobile ? 20 : 22,
                ),
                onPressed: () {
                  setState(() {
                    _isDarkMode = !_isDarkMode;
                  });
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient:
              _isDarkMode
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
        child: SafeArea(
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 6.0,
            radius: const Radius.circular(3.0),
            scrollbarOrientation: ScrollbarOrientation.right,
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isMobile ? 16 : 24,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: isMobile ? 16 : 24),

                        // Card principal
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isMobile ? 16 : 20),
                          decoration: BoxDecoration(
                            color:
                                _isDarkMode
                                    ? cardDark.withOpacity(0.9)
                                    : Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(
                              isMobile ? 16 : 20,
                            ),
                            border: Border.all(
                              color:
                                  _isDarkMode
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  _isDarkMode ? 0.3 : 0.1,
                                ),
                                blurRadius: 24,
                                spreadRadius: 0,
                                offset: const Offset(0, 12),
                              ),
                              if (_isDarkMode)
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
                              // Icono principal
                              Container(
                                width: isMobile ? 60 : 80,
                                height: isMobile ? 60 : 80,
                                decoration: BoxDecoration(
                                  color: (_isDarkMode
                                          ? vibrantPurple
                                          : deepPurple)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    isMobile ? 16 : 20,
                                  ),
                                  border: Border.all(
                                    color: (_isDarkMode
                                            ? vibrantPurple
                                            : deepPurple)
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_add_rounded,
                                  color:
                                      _isDarkMode ? vibrantPurple : deepPurple,
                                  size: isMobile ? 30 : 40,
                                ),
                              ),

                              SizedBox(height: isMobile ? 16 : 20),

                              // Título principal
                              Text(
                                "Crear Cuenta",
                                style: GoogleFonts.inter(
                                  fontSize: isMobile ? 24 : 30,
                                  fontWeight: FontWeight.w700,
                                  color: _isDarkMode ? softWhite : deepPurple,
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: isMobile ? 6 : 8),

                              // Subtítulo
                              Text(
                                "Completa los datos para registrarte",
                                style: GoogleFonts.inter(
                                  fontSize: isMobile ? 13 : 15,
                                  color:
                                      _isDarkMode
                                          ? Colors.grey[300]
                                          : Color(0xFF64748B),
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: isMobile ? 20 : 28),

                              // Formulario
                              Form(
                                key: widget.formKey,
                                child: Column(
                                  children: [
                                    // Nombre completo
                                    _buildTextField(
                                      controller: widget.nombre,
                                      label: "Nombre completo",
                                      icon: Icons.person_rounded,
                                      validator:
                                          (value) =>
                                              value == null || value.isEmpty
                                                  ? "Campo obligatorio"
                                                  : null,
                                    ),

                                    // Fecha de nacimiento
                                    _buildTextField(
                                      controller: widget.fechaNacimiento,
                                      label: "Fecha de nacimiento",
                                      icon: Icons.calendar_today_rounded,
                                      readOnly: true,
                                      onTap: () => _seleccionarFecha(context),
                                      validator:
                                          (value) =>
                                              value == null || value.isEmpty
                                                  ? "Seleccione su fecha"
                                                  : null,
                                    ),

                                    // Teléfono
                                    _buildTextField(
                                      controller: widget.telefono,
                                      label: "Teléfono",
                                      icon: Icons.phone_rounded,
                                      keyboardType: TextInputType.phone,
                                      validator:
                                          (value) =>
                                              value == null || value.isEmpty
                                                  ? "Campo obligatorio"
                                                  : null,
                                    ),

                                    // Correo electrónico
                                    _buildTextField(
                                      controller: widget.correo,
                                      label: "Correo electrónico",
                                      icon: Icons.email_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Campo obligatorio";
                                        }
                                        if (!value.contains("@") ||
                                            !value.contains(".")) {
                                          return "Ingrese un correo válido";
                                        }
                                        return null;
                                      },
                                    ),

                                    // Contraseña
                                    _buildTextField(
                                      controller: widget.password,
                                      label: "Contraseña",
                                      icon: Icons.lock_rounded,
                                      obscureText: _obscurePassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color:
                                              _isDarkMode
                                                  ? Colors.grey[400]
                                                  : Color(0xFF64748B),
                                          size: isMobile ? 16 : 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      validator:
                                          (value) =>
                                              value == null || value.isEmpty
                                                  ? "Campo obligatorio"
                                                  : null,
                                    ),

                                    // Confirmar contraseña
                                    _buildTextField(
                                      controller: widget.confirmPassword,
                                      label: "Confirmar contraseña",
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _obscureConfirmPassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color:
                                              _isDarkMode
                                                  ? Colors.grey[400]
                                                  : Color(0xFF64748B),
                                          size: isMobile ? 16 : 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                      validator:
                                          (value) =>
                                              value != widget.password.text
                                                  ? "Las contraseñas no coinciden"
                                                  : null,
                                    ),

                                    SizedBox(height: isMobile ? 20 : 24),

                                    // Botón de crear cuenta
                                    GestureDetector(
                                      onTapDown:
                                          (_) =>
                                              setState(() => _isPressed = true),
                                      onTapUp:
                                          (_) => setState(
                                            () => _isPressed = false,
                                          ),
                                      onTapCancel:
                                          () => setState(
                                            () => _isPressed = false,
                                          ),
                                      onTap: () {
                                        if (widget.formKey.currentState!
                                            .validate()) {
                                          registrarDatos(
                                                nombre:
                                                    widget.nombre.text.trim(),
                                                fechaNacimiento:
                                                    widget.fechaNacimiento.text
                                                        .trim(),
                                                telefono:
                                                    widget.telefono.text.trim(),
                                                correo:
                                                    widget.correo.text.trim(),
                                                password:
                                                    widget.password.text.trim(),
                                              )
                                              .then((resultado) {
                                                if (resultado["success"]) {
                                                  // Limpiar campos
                                                  widget.nombre.clear();
                                                  widget.fechaNacimiento
                                                      .clear();
                                                  widget.telefono.clear();
                                                  widget.correo.clear();
                                                  widget.password.clear();
                                                  widget.confirmPassword
                                                      .clear();

                                                  Navigator.pop(context);

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Registro exitoso',
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      backgroundColor:
                                                          mentalhealthGreen,
                                                      behavior:
                                                          SnackBarBehavior
                                                              .floating,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error: ${resultado["data"]}',
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                      behavior:
                                                          SnackBarBehavior
                                                              .floating,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              })
                                              .catchError((e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error inesperado: $e',
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    behavior:
                                                        SnackBarBehavior
                                                            .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              });
                                        }
                                      },
                                      child: AnimatedScale(
                                        scale: _isPressed ? 0.95 : 1.0,
                                        duration: const Duration(
                                          milliseconds: 120,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          height: isMobile ? 48 : 52,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              isMobile ? 10 : 14,
                                            ),
                                            gradient: LinearGradient(
                                              colors:
                                                  _isDarkMode
                                                      ? [
                                                        vibrantPurple,
                                                        lightPurple,
                                                      ]
                                                      : [
                                                        deepPurple,
                                                        vibrantPurple,
                                                      ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (_isDarkMode
                                                        ? vibrantPurple
                                                        : deepPurple)
                                                    .withOpacity(0.4),
                                                blurRadius: 20,
                                                spreadRadius: 0,
                                                offset: const Offset(0, 8),
                                              ),
                                              BoxShadow(
                                                color: Colors.white.withOpacity(
                                                  _isDarkMode ? 0.1 : 0.2,
                                                ),
                                                blurRadius: 4,
                                                spreadRadius: -1,
                                                offset: const Offset(0, -1),
                                              ),
                                            ],
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Crear Cuenta',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: isMobile ? 15 : 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: isMobile ? 20 : 28),

                                    // Enlace para iniciar sesión
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "¿Ya tienes cuenta? ",
                                          style: GoogleFonts.inter(
                                            fontSize: isMobile ? 12 : 14,
                                            color:
                                                _isDarkMode
                                                    ? Colors.grey[300]
                                                    : Color(0xFF64748B),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Inicia Sesión",
                                            style: GoogleFonts.inter(
                                              fontSize: isMobile ? 12 : 14,
                                              color:
                                                  _isDarkMode
                                                      ? vibrantPurple
                                                      : deepPurple,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  _isDarkMode
                                                      ? vibrantPurple
                                                      : deepPurple,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isMobile ? 20 : 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
