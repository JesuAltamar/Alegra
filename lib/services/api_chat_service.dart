// lib/services/api_chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiChatService {
  static const String baseUrl = 'http://backendproyecto-producción-4a8d.up.railway.app';
  
  /// Enviar mensaje al chat
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String sessionId,
    int? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'sessionId': sessionId,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  /// Reiniciar chat
  Future<void> resetChat(String sessionId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/chat/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': sessionId}),
      );
    } catch (e) {
      print('Error reseteando chat: $e');
    }
  }
  
  /// Obtener estadísticas
  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/chat/stats'));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error obteniendo stats: $e');
      return null;
    }
  }
}
    