import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EmailService {
  // Configuración de EmailJS (tus credenciales actuales)
  static const String serviceId = 'service_0mt2sqo';
  static const String templateId = 'template_gl69aq3';
  static const String publicKey = 'fr_hwrH9uRKe1LCQC';

  // Verificar si EmailJS está configurado
  static bool get isConfigured {
    return serviceId.isNotEmpty &&
        templateId.isNotEmpty &&
        publicKey.isNotEmpty;
  }

  /// Generar mensaje de recordatorio
  static String generarMensajeRecordatorio(Map<String, dynamic> tarea) {
    final titulo = tarea['titulo'] ?? 'Tarea sin título';
    final descripcion = tarea['descripcion']?.toString() ?? '';
    final fecha = tarea['fecha'] ?? '';

    String mensaje =
        '''
🔔 RECORDATORIO DE TAREA

📝 Título: $titulo
${descripcion.isNotEmpty ? '📋 Descripción: $descripcion\n' : ''}📅 Fecha de la tarea: $fecha

¡No olvides completar tu tarea!

---
Enviado desde tu App de Tareas
    '''.trim();

    return mensaje;
  }

  /// Enviar email usando EmailJS
  static Future<void> enviarEmail({
    required String destinatario,
    required String asunto,
    required String mensaje,
  }) async {
    if (!isConfigured) {
      throw Exception('EmailJS no está configurado correctamente');
    }

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    debugPrint('📧 Enviando email a: $destinatario');
    debugPrint('📧 Asunto: $asunto');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': publicKey,
        'template_params': {
          'to_email': destinatario,
          'from_name': 'RecordatorioApp',
          'subject': asunto,
          'message': mensaje,
        },
      }),
    );

    debugPrint('📡 Response status: ${response.statusCode}');
    debugPrint('📡 Response body: ${response.body}');

    if (response.statusCode != 200) {
      debugPrint('❌ Error EmailJS: ${response.body}');
      throw Exception('Error enviando email: ${response.body}');
    }

    debugPrint('✅ Email enviado exitosamente a: $destinatario');
  }

  /// Enviar recordatorio por email
  static Future<void> enviarRecordatorio({
    required String email,
    required Map<String, dynamic> tarea,
  }) async {
    final mensaje = generarMensajeRecordatorio(tarea);
    final titulo = tarea['titulo'] ?? 'Tarea sin título';

    await enviarEmail(
      destinatario: email,
      asunto: '🔔 Recordatorio: $titulo',
      mensaje: mensaje,
    );
  }
}
