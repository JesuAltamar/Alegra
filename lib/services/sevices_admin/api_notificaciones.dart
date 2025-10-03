// lib/services/sevices_admin/api_notificaciones.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiNotificaciones {
  static const String baseUrl = 'http://localhost:5000';

  /// Obtener todas las notificaciones
  static Future<Map<String, dynamic>> getNotificaciones({
    bool soloNoLeidas = false,
    String? tipo,
    int limit = 50,
  }) async {
    try {
      final queryParams = {
        'no_leidas': soloNoLeidas.toString(),
        'limit': limit.toString(),
        if (tipo != null) 'tipo': tipo,
      };

      final uri = Uri.parse('$baseUrl/api/admin/notificaciones')
          .replace(queryParameters: queryParams);

      print('🔍 Obteniendo notificaciones: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        print('✅ Notificaciones recibidas: ${data['total']} total, ${data['no_leidas']} sin leer');
        
        return {
          'notificaciones': List<Map<String, dynamic>>.from(
            data['notificaciones'] ?? [],
          ),
          'total': data['total'] ?? 0,
          'no_leidas': data['no_leidas'] ?? 0,
        };
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo notificaciones: $e');
      return {
        'notificaciones': [],
        'total': 0,
        'no_leidas': 0,
      };
    }
  }

  /// Contar notificaciones no leídas (SIN limit=1)
  static Future<int> getCountNoLeidas() async {
    try {
      // 🔥 CAMBIO CRÍTICO: Usar el mismo endpoint pero solo leer el campo 'no_leidas'
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/notificaciones?no_leidas=false&limit=5'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final count = data['no_leidas'] ?? 0;
        print('📊 Contador no leídas: $count');
        return count;
      }
      return 0;
    } catch (e) {
      print('❌ Error contando notificaciones: $e');
      return 0;
    }
  }

  /// Marcar notificación como leída
  static Future<bool> marcarLeida(int notifId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/notificaciones/$notifId/marcar-leida'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('✅ Notificación $notifId marcada como leída');
        return true;
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error marcando como leída: $e');
      return false;
    }
  }

  /// Marcar todas como leídas
  static Future<bool> marcarTodasLeidas() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/notificaciones/marcar-todas-leidas'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('✅ Todas las notificaciones marcadas como leídas');
        return true;
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error marcando todas como leídas: $e');
      return false;
    }
  }

  /// Eliminar notificación
  static Future<bool> eliminarNotificacion(int notifId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/notificaciones/$notifId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('✅ Notificación $notifId eliminada');
        return true;
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error eliminando notificación: $e');
      return false;
    }
  }

  /// Obtener solo alertas de crisis
  static Future<List<Map<String, dynamic>>> getCrisisAlerts() async {
    try {
      final result = await getNotificaciones(
        soloNoLeidas: false,
        tipo: 'crisis',
        limit: 100,
      );

      return List<Map<String, dynamic>>.from(result['notificaciones']);
    } catch (e) {
      print('❌ Error obteniendo crisis alerts: $e');
      return [];
    }
  }
}