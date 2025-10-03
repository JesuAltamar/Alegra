import 'package:flutter/material.dart';
import 'package:pro9/services/sevices_admin/gestion_usuario.dart';
import 'package:google_fonts/google_fonts.dart';

class MostrarConsulta extends StatefulWidget {
  @override
  State<MostrarConsulta> createState() => _MostrarConsultaState();
}

class _MostrarConsultaState extends State<MostrarConsulta> {
  late Future<List<Usuario>> _usuariosFuture;
  bool isDarkMode = false;

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
    _usuariosFuture = buscarUsuarios();
  }

  void _refrescarUsuarios() {
    setState(() {
      _usuariosFuture = buscarUsuarios();
    });
  }

  void _mostrarDialogEditar(BuildContext context, Usuario user) {
    final nombreController = TextEditingController(text: user.nombre);
    final correoController = TextEditingController(text: user.correo);
    final telefonoController = TextEditingController(text: user.telefono ?? '');

    showDialog(
      context: context,
      builder: (context) {
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
                child: Icon(Icons.edit_rounded, color: vibrantPurple, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                "Editar Usuario",
                style: GoogleFonts.inter(
                  color: isDarkMode ? softWhite : deepPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nombreController, "Nombre", Icons.person_rounded),
              SizedBox(height: 16),
              _buildTextField(correoController, "Correo", Icons.email_rounded),
              SizedBox(height: 16),
              _buildTextField(telefonoController, "Teléfono", Icons.phone_rounded),
            ],
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancelar",
                  style: GoogleFonts.inter(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: vibrantPurple,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: vibrantPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () async {
                  final actualizado = Usuario(
                    id: user.id,
                    nombre: nombreController.text,
                    genero: user.genero,
                    fechaNacimiento: user.fechaNacimiento,
                    telefono: telefonoController.text,
                    correo: correoController.text,
                  );

                  await editarUsuario(actualizado);
                  Navigator.pop(context);
                  _refrescarUsuarios();
                },
                child: Text(
                  "Guardar",
                  style: GoogleFonts.inter(
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? cardDark.withOpacity(0.5) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? vibrantPurple.withOpacity(0.3)
              : deepPurple.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(
          color: isDarkMode ? softWhite : deepPurple,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            color: isDarkMode ? Colors.grey[300] : deepPurple.withOpacity(0.7),
          ),
          prefixIcon: Icon(icon, color: vibrantPurple, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Usuario user) {
    showDialog(
      context: context,
      builder: (context) {
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
                  color: accentPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete_rounded, color: accentPink, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                "Eliminar Usuario",
                style: GoogleFonts.inter(
                  color: isDarkMode ? softWhite : deepPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentPink.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentPink.withOpacity(0.2)),
            ),
            child: Text(
              "¿Seguro que deseas eliminar a ${user.nombre}? Esta acción no se puede deshacer.",
              style: GoogleFonts.inter(
                color: isDarkMode
                    ? softWhite.withOpacity(0.8)
                    : deepPurple.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancelar",
                  style: GoogleFonts.inter(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: accentPink,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: accentPink.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () async {
                  await eliminarUsuario(user.id);
                  Navigator.pop(context);
                  _refrescarUsuarios();
                },
                child: Text(
                  "Eliminar",
                  style: GoogleFonts.inter(
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : softWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    darkBackground,
                    deepPurple.withOpacity(0.3),
                    darkBackground,
                  ]
                : [softWhite, vibrantPurple.withOpacity(0.05), softWhite],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: FutureBuilder<List<Usuario>>(
                    future: _usuariosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: vibrantPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: CircularProgressIndicator(
                                  color: vibrantPurple,
                                  strokeWidth: 3,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Cargando usuarios...",
                                style: GoogleFonts.inter(
                                  color: isDarkMode
                                      ? softWhite.withOpacity(0.8)
                                      : deepPurple.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Container(
                            padding: EdgeInsets.all(24),
                            margin: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: accentPink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: accentPink.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: accentPink,
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Error al cargar usuarios',
                                  style: GoogleFonts.inter(
                                    color: accentPink,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${snapshot.error}',
                                  style: GoogleFonts.inter(
                                    color: isDarkMode
                                        ? softWhite.withOpacity(0.8)
                                        : deepPurple.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Container(
                            padding: EdgeInsets.all(32),
                            margin: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? cardDark.withOpacity(0.95)
                                  : Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDarkMode
                                    ? vibrantPurple.withOpacity(0.3)
                                    : deepPurple.withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: vibrantPurple.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cloudBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.people_outline,
                                    color: cloudBlue,
                                    size: 48,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'No hay usuarios registrados',
                                  style: GoogleFonts.inter(
                                    color: isDarkMode ? softWhite : deepPurple,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Los usuarios aparecerán aquí una vez que se registren',
                                  style: GoogleFonts.inter(
                                    color: isDarkMode
                                        ? softWhite.withOpacity(0.7)
                                        : deepPurple.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final user = snapshot.data![index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? cardDark.withOpacity(0.95)
                                    : Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDarkMode
                                      ? vibrantPurple.withOpacity(0.3)
                                      : deepPurple.withOpacity(0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: vibrantPurple.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [vibrantPurple, lightPurple],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.id.toString(),
                                      style: GoogleFonts.inter(
                                        color: softWhite,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  user.nombre,
                                  style: GoogleFonts.inter(
                                    color: isDarkMode ? softWhite : deepPurple,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.email_rounded,
                                          size: 14,
                                          color: cloudBlue,
                                        ),
                                        SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            user.correo,
                                            style: GoogleFonts.inter(
                                              color: isDarkMode
                                                  ? softWhite.withOpacity(0.7)
                                                  : deepPurple.withOpacity(0.7),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // 🔥 CORRECCIÓN: Validación segura de telefono
                                    if (user.telefono != null && user.telefono!.isNotEmpty) ...[
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.phone_rounded,
                                            size: 14,
                                            color: mentalhealthGreen,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            user.telefono!,
                                            style: GoogleFonts.inter(
                                              color: isDarkMode
                                                  ? softWhite.withOpacity(0.7)
                                                  : deepPurple.withOpacity(0.7),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: vibrantPurple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit_rounded,
                                          color: vibrantPurple,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _mostrarDialogEditar(context, user),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: accentPink.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete_rounded,
                                          color: accentPink,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _confirmarEliminar(context, user),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? cardDark.withOpacity(0.95)
                  : softWhite.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? vibrantPurple.withOpacity(0.3)
                    : deepPurple.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: vibrantPurple.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDarkMode ? softWhite : deepPurple,
                size: 24,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: vibrantPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.people_rounded,
                        color: vibrantPurple,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Consulta de Usuarios',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? softWhite : deepPurple,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Gestiona los usuarios registrados en Alegra',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDarkMode
                        ? softWhite.withOpacity(0.7)
                        : deepPurple.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? cardDark.withOpacity(0.95)
                  : softWhite.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? vibrantPurple.withOpacity(0.3)
                    : deepPurple.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: vibrantPurple.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDarkMode ? accentPink : vibrantPurple,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}