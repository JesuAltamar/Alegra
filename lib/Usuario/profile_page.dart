import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pro9/services/foto_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pro9/screens/forgot_password_screen.dart';
import 'lista_tareas_page.dart';
import 'package:provider/provider.dart';

import '../rachas/streak_models.dart';
import '../rachas/streak_service.dart';
import '../rachas/streak_provider.dart';
import '../rachas/weekly_streak_widget.dart';

class ProfilePage extends StatefulWidget {
  final String nombreUsuario;
  final int usuarioId;

  const ProfilePage({
    super.key,
    required this.nombreUsuario,
    required this.usuarioId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDarkMode = false;

  // Variables para manejo de imagen
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingImage = false;
  String? _avatarUrl;
  bool _isLoadingProfile = true;

  // Colores Alegra
  final Color deepPurple = Color(0xFF2D1B69);
  final Color vibrantPurple = Color(0xFF6366F1);
  final Color lightPurple = Color(0xFFA855F7);
  final Color darkBackground = Color(0xFF0F0A1F);
  final Color cardDark = Color(0xFF1A1335);
  final Color accentPink = Color(0xFFEC4899);
  final Color softWhite = Color(0xFFF8FAFC);
  final Color mentalhealthGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StreakProvider>(
        context,
        listen: false,
      ).cargarRacha(widget.usuarioId);
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('https://backendproyecto-production-4a8d.up.railway.app/api/usuario/perfil'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            setState(() {
              _avatarUrl = data['usuario']['avatar_url'];
              _isLoadingProfile = false;
            });
          } else {
            setState(() => _isLoadingProfile = false);
          }
        } else {
          setState(() => _isLoadingProfile = false);
        }
      } else {
        setState(() => _isLoadingProfile = false);
      }
    } catch (e) {
      setState(() => _isLoadingProfile = false);
      print('Error cargando perfil: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isLoadingImage = true);

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');

        if (token != null) {
          final result = await FotoService.subirFoto(
            token: token,
            imageBytes: bytes,
          );

          if (result['success'] == true) {
            setState(() {
              _webImage = bytes;
              _avatarUrl = result['foto_url'];
            });
            _showSnackbar('Foto actualizada correctamente', mentalhealthGreen);
          } else {
            _showSnackbar(
              result['message'] ?? 'Error al subir foto',
              accentPink,
            );
          }
        }
      }
    } catch (e) {
      _showSnackbar('Error: $e', accentPink);
    } finally {
      setState(() => _isLoadingImage = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
  Widget _buildImageWidget() {
  if (_isLoadingProfile || _isLoadingImage) {
    return Center(
      child: CircularProgressIndicator(color: vibrantPurple, strokeWidth: 3),
    );
  }

  if (_webImage != null) {
    return Image.memory(_webImage!, fit: BoxFit.cover);
  } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
    // ⬇️ SOLUCIÓN: Detectar si la URL ya es completa
    String imageUrl;
    if (_avatarUrl!.startsWith('http://') || _avatarUrl!.startsWith('https://')) {
      // Ya es una URL completa de Cloudinary
      imageUrl = _avatarUrl!;
    } else {
      // Es una ruta relativa del sistema antiguo
      imageUrl = 'https://backendproyecto-production-4a8d.up.railway.app$_avatarUrl';
    }
    
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            color: vibrantPurple,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ Error cargando imagen desde: $imageUrl');
        print('Error: $error');
        return _buildDefaultAvatar();
      },
    );
  }
  return _buildDefaultAvatar();
}
 
  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [vibrantPurple.withOpacity(0.3), accentPink.withOpacity(0.3)],
        ),
      ),
      child: Icon(Icons.person_rounded, size: 50, color: vibrantPurple),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 360),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? cardDark : softWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: vibrantPurple.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: vibrantPurple.withOpacity(0.2),
                  blurRadius: 30,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: accentPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accentPink.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 30,
                    color: accentPink,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '¿Cerrar sesión?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? softWhite : deepPurple,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '¿Estás seguro de que deseas cerrar tu sesión?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isDarkMode
                            ? Colors.grey[300]
                            : deepPurple.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: vibrantPurple.withOpacity(0.5),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: isDarkMode ? softWhite : deepPurple,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentPink, accentPink.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: accentPink.withOpacity(0.4),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            await _performLogout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 800 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : softWhite,
      appBar: AppBar(
        backgroundColor: (isDarkMode ? cardDark : softWhite).withOpacity(0.95),
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: vibrantPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: vibrantPurple.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: vibrantPurple,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
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
              child: Icon(Icons.person, color: softWhite, size: 18),
            ),
            SizedBox(width: 12),
            Text(
              'Mi Perfil',
              style: TextStyle(
                color: isDarkMode ? softWhite : deepPurple,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: vibrantPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: vibrantPurple.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDarkMode ? accentPink : vibrantPurple,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
              tooltip: isDarkMode ? 'Modo claro' : 'Modo oscuro',
            ),
          ),
        ],
      ),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 80 : (isTablet ? 60 : 24),
              vertical: 32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 900 : double.infinity,
                ),
                child: Column(
                  children: [
                    Text(
                      widget.nombreUsuario,
                      style: TextStyle(
                        fontSize: isDesktop ? 32 : 28,
                        fontWeight: FontWeight.w900,
                        color: isDarkMode ? softWhite : deepPurple,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Miembro de Alegra',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            isDarkMode
                                ? Colors.grey[300]
                                : deepPurple.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 24),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: isDesktop ? 220 : 180,
                            height: isDesktop ? 220 : 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: vibrantPurple.withOpacity(0.3),
                                width: 5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: vibrantPurple.withOpacity(0.25),
                                  blurRadius: 30,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipOval(child: _buildImageWidget()),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: isDesktop ? 56 : 48,
                              height: isDesktop ? 56 : 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [vibrantPurple, lightPurple],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: isDarkMode ? cardDark : softWhite,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: vibrantPurple.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: isDesktop ? 24 : 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    WeeklyStreakWidget(
                      userId: widget.usuarioId,
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 32),
                    _buildMenuItem(
                      Icons.task_alt_rounded,
                      'Lista de Tareas',
                      vibrantPurple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListaTareasPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12),
                    _buildMenuItem(
                      Icons.lock_outline_rounded,
                      'Cambiar Contraseña',
                      lightPurple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12),
                    _buildMenuItem(
                      Icons.logout_rounded,
                      'Cerrar Sesión',
                      accentPink,
                      _showLogoutDialog,
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? cardDark.withOpacity(0.8)
                  : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? softWhite : deepPurple,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withOpacity(0.6),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
