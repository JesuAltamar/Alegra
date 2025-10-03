import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pro9/services/sevices_admin/api_notificaciones.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsScreen> {
  final Color deepPurple = Color(0xFF2D1B69);
  final Color vibrantPurple = Color(0xFF6366F1);
  final Color lightPurple = Color(0xFFA855F7);
  final Color darkBackground = Color(0xFF0F0A1F);
  final Color cardDark = Color(0xFF1A1335);
  final Color accentPink = Color(0xFFEC4899);
  final Color softWhite = Color(0xFFF8FAFC);
  final Color cloudBlue = Color(0xFF8B5CF6);
  final Color mentalhealthGreen = Color(0xFF10B981);
  final Color crisisRed = Color(0xFFEF4444);

  List<Map<String, dynamic>> notificaciones = [];
  bool isLoading = true;
  bool isDarkMode = false;
  String filtroTipo = 'todas';
  Timer? _refreshTimer;

  @override
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', timeago.EsMessages());
    _cargarNotificaciones();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _cargarNotificaciones() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final result = await ApiNotificaciones.getNotificaciones(
      tipo: filtroTipo == 'todas' ? null : filtroTipo,
      limit: 100,
    );

    if (mounted) {
      setState(() {
        notificaciones = List<Map<String, dynamic>>.from(
          result['notificaciones'],
        );
        isLoading = false;
      });
    }
  }

  void _toggleReadStatus(int notifId, bool estadoActual) async {
    if (!estadoActual) {
      final success = await ApiNotificaciones.marcarLeida(notifId);
      if (success && mounted) {
        setState(() {
          final index = notificaciones.indexWhere((n) => n['id'] == notifId);
          if (index != -1) {
            notificaciones[index]['leida'] = true;
          }
        });
      }
    }
  }

  void _deleteNotificacion(int notifId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? cardDark : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.delete_outline, color: crisisRed, size: 24),
                SizedBox(width: 12),
                Text(
                  'Eliminar Notificación',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? softWhite : deepPurple,
                  ),
                ),
              ],
            ),
            content: Text(
              '¿Estás seguro de eliminar esta notificación?',
              style: GoogleFonts.inter(
                color:
                    isDarkMode
                        ? softWhite.withOpacity(0.8)
                        : deepPurple.withOpacity(0.8),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(color: cloudBlue),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: crisisRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Eliminar',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final success = await ApiNotificaciones.eliminarNotificacion(notifId);
      if (success && mounted) {
        setState(() => notificaciones.removeWhere((n) => n['id'] == notifId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notificación eliminada',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: mentalhealthGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _marcarTodasLeidas() async {
    final success = await ApiNotificaciones.marcarTodasLeidas();
    if (success && mounted) {
      setState(() {
        for (var notif in notificaciones) notif['leida'] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Todas marcadas como leídas',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: mentalhealthGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _mostrarDetallesCrisis(Map<String, dynamic> notif) {
    final tieneUsuario = notif['usuario_id'] != null;
    final nombreUsuario = notif['nombre_usuario'] ?? 'Anónimo';
    final correo = notif['correo_usuario'];
    final telefono = notif['telefono_usuario'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? cardDark : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: crisisRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.emergency, color: crisisRed, size: 28),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detalles de Crisis',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? softWhite : deepPurple,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          tieneUsuario
                              ? vibrantPurple.withOpacity(0.1)
                              : crisisRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            tieneUsuario
                                ? vibrantPurple.withOpacity(0.3)
                                : crisisRed.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              tieneUsuario ? Icons.person : Icons.person_off,
                              color: tieneUsuario ? vibrantPurple : crisisRed,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Usuario',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? softWhite : deepPurple,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          nombreUsuario,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? softWhite : deepPurple,
                          ),
                        ),
                        if (!tieneUsuario) ...[
                          SizedBox(height: 4),
                          Text(
                            'Sin información de contacto disponible',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: crisisRed,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (correo != null || telefono != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: mentalhealthGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: mentalhealthGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.contact_phone,
                                color: mentalhealthGreen,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Información de Contacto',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? softWhite : deepPurple,
                                ),
                              ),
                            ],
                          ),
                          if (correo != null) ...[
                            SizedBox(height: 12),
                            _buildContactItem(
                              Icons.email,
                              'Email',
                              correo,
                              mentalhealthGreen,
                              onTap: () async {
                                final url = Uri.parse('mailto:$correo');
                                if (await canLaunchUrl(url))
                                  await launchUrl(url);
                              },
                            ),
                          ],
                          if (telefono != null) ...[
                            SizedBox(height: 12),
                            _buildContactItem(
                              Icons.phone,
                              'Teléfono',
                              telefono,
                              mentalhealthGreen,
                              onTap: () async {
                                final url = Uri.parse('tel:$telefono');
                                if (await canLaunchUrl(url))
                                  await launchUrl(url);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 16),
                  Divider(
                    color:
                        isDarkMode
                            ? vibrantPurple.withOpacity(0.2)
                            : deepPurple.withOpacity(0.1),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Mensaje del usuario:',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDarkMode ? softWhite : deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: crisisRed.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: crisisRed.withOpacity(0.2)),
                    ),
                    child: Text(
                      notif['mensaje'],
                      style: GoogleFonts.inter(
                        height: 1.5,
                        color:
                            isDarkMode
                                ? softWhite.withOpacity(0.9)
                                : deepPurple.withOpacity(0.9),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color:
                            isDarkMode
                                ? softWhite.withOpacity(0.6)
                                : deepPurple.withOpacity(0.6),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Fecha: ${notif['fecha_creacion']}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color:
                              isDarkMode
                                  ? softWhite.withOpacity(0.6)
                                  : deepPurple.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              if (telefono != null)
                ElevatedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse('tel:$telefono');
                    if (await canLaunchUrl(url)) await launchUrl(url);
                  },
                  icon: Icon(Icons.phone, size: 18),
                  label: Text('Llamar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mentalhealthGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              if (correo != null)
                ElevatedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse('mailto:$correo');
                    if (await canLaunchUrl(url)) await launchUrl(url);
                  },
                  icon: Icon(Icons.email, size: 18),
                  label: Text('Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cloudBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style: GoogleFonts.inter(
                    color: vibrantPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDarkMode ? softWhite : deepPurple,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificacionesNoLeidas =
        notificaciones.where((n) => n['leida'] == false).length;

    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : softWhite,
      appBar: AppBar(
        backgroundColor: isDarkMode ? cardDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? softWhite : deepPurple,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificaciones',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? softWhite : deepPurple,
              ),
            ),
            if (notificacionesNoLeidas > 0)
              Text(
                '$notificacionesNoLeidas sin leer',
                style: GoogleFonts.inter(fontSize: 12, color: accentPink),
              ),
          ],
        ),
        actions: [
          if (notificacionesNoLeidas > 0)
            IconButton(
              icon: Icon(Icons.done_all, color: mentalhealthGreen),
              onPressed: _marcarTodasLeidas,
            ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? accentPink : vibrantPurple,
            ),
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: vibrantPurple),
            onPressed: _cargarNotificaciones,
          ),
        ],
      ),
      body: Container(
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      softWhite,
                      vibrantPurple.withOpacity(0.05),
                      lightPurple.withOpacity(0.03),
                    ],
                  ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? cardDark.withOpacity(0.5)
                        : Colors.white.withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(
                    color:
                        isDarkMode
                            ? vibrantPurple.withOpacity(0.2)
                            : deepPurple.withOpacity(0.1),
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChipFiltro('Todas', 'todas', Icons.all_inbox),
                    SizedBox(width: 8),
                    _buildChipFiltro('Crisis', 'crisis', Icons.emergency),
                    SizedBox(width: 8),
                    _buildChipFiltro('Avisos', 'warning', Icons.warning),
                    SizedBox(width: 8),
                    _buildChipFiltro('Info', 'info', Icons.info),
                  ],
                ),
              ),
            ),
            Expanded(
              child:
                  isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: vibrantPurple,
                          strokeWidth: 3,
                        ),
                      )
                      : notificaciones.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                        onRefresh: _cargarNotificaciones,
                        color: vibrantPurple,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: notificaciones.length,
                          itemBuilder:
                              (context, index) => _buildNotificacionCard(
                                notificaciones[index],
                                index,
                              ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipFiltro(String label, String valor, IconData icon) {
    final isSelected = filtroTipo == valor;
    return FilterChip(
      avatar: Icon(
        icon,
        size: 18,
        color:
            isSelected
                ? vibrantPurple
                : (isDarkMode
                    ? softWhite.withOpacity(0.7)
                    : deepPurple.withOpacity(0.7)),
      ),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color:
              isSelected
                  ? vibrantPurple
                  : (isDarkMode
                      ? softWhite.withOpacity(0.7)
                      : deepPurple.withOpacity(0.7)),
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => filtroTipo = valor);
        _cargarNotificaciones();
      },
      selectedColor: vibrantPurple.withOpacity(0.2),
      checkmarkColor: vibrantPurple,
      backgroundColor:
          isDarkMode
              ? cardDark.withOpacity(0.5)
              : Colors.white.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              isSelected
                  ? vibrantPurple
                  : (isDarkMode
                      ? vibrantPurple.withOpacity(0.2)
                      : deepPurple.withOpacity(0.2)),
        ),
      ),
    );
  }

  Widget _buildNotificacionCard(Map<String, dynamic> notif, int index) {
    final esLeida = notif['leida'] == true || notif['leida'] == 1;
    final esCrisis = notif['tipo'] == 'crisis';
    String tiempoRelativo = 'Hace un momento';
    try {
      tiempoRelativo = timeago.format(
        DateTime.parse(notif['fecha_creacion']),
        locale: 'es',
      );
    } catch (e) {}

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder:
          (context, value, child) => Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: Opacity(
              opacity: value,
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color:
                      esLeida
                          ? (isDarkMode
                              ? cardDark.withOpacity(0.3)
                              : lightPurple.withOpacity(0.03))
                          : (isDarkMode
                              ? cardDark.withOpacity(0.95)
                              : Colors.white.withOpacity(0.95)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        esCrisis
                            ? crisisRed.withOpacity(0.5)
                            : (isDarkMode
                                ? vibrantPurple.withOpacity(0.2)
                                : deepPurple.withOpacity(0.1)),
                    width: esCrisis ? 2 : 1,
                  ),
                  boxShadow:
                      esLeida
                          ? []
                          : [
                            BoxShadow(
                              color: (esCrisis ? crisisRed : vibrantPurple)
                                  .withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient:
                          esCrisis
                              ? LinearGradient(colors: [crisisRed, accentPink])
                              : LinearGradient(
                                colors: [vibrantPurple, lightPurple],
                              ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (esCrisis ? crisisRed : vibrantPurple)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getIconTipo(notif['tipo']),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    notif['titulo'],
                    style: GoogleFonts.inter(
                      fontWeight: esLeida ? FontWeight.w500 : FontWeight.w700,
                      color: isDarkMode ? softWhite : deepPurple,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6),
                      Text(
                        notif['mensaje'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color:
                              isDarkMode
                                  ? softWhite.withOpacity(0.7)
                                  : deepPurple.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color:
                                isDarkMode
                                    ? softWhite.withOpacity(0.5)
                                    : deepPurple.withOpacity(0.5),
                          ),
                          SizedBox(width: 4),
                          Text(
                            tiempoRelativo,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color:
                                  isDarkMode
                                      ? softWhite.withOpacity(0.5)
                                      : deepPurple.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (esCrisis)
                        IconButton(
                          icon: Icon(Icons.info_outline, color: crisisRed),
                          onPressed: () => _mostrarDetallesCrisis(notif),
                          tooltip: 'Ver detalles',
                        ),
                      IconButton(
                        icon: Icon(
                          esLeida ? Icons.visibility_off : Icons.visibility,
                          color:
                              isDarkMode
                                  ? softWhite.withOpacity(0.6)
                                  : deepPurple.withOpacity(0.6),
                        ),
                        onPressed:
                            () => _toggleReadStatus(notif['id'], esLeida),
                        tooltip:
                            esLeida
                                ? 'Marcar como no leída'
                                : 'Marcar como leída',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: crisisRed),
                        onPressed: () => _deleteNotificacion(notif['id']),
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  IconData _getIconTipo(String? tipo) {
    switch (tipo) {
      case 'crisis':
        return Icons.emergency;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                vibrantPurple.withOpacity(0.1),
                lightPurple.withOpacity(0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_none,
            size: 80,
            color: vibrantPurple.withOpacity(0.5),
          ),
        ),
        SizedBox(height: 24),
        Text(
          'No hay notificaciones',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? softWhite : deepPurple,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Las alertas de crisis aparecerán aquí',
          style: GoogleFonts.inter(
            fontSize: 14,
            color:
                isDarkMode
                    ? softWhite.withOpacity(0.6)
                    : deepPurple.withOpacity(0.6),
          ),
        ),
      ],
    ),
  );
}
