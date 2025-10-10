// services/foto_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class FotoService {
  static const String baseUrl = 'https://backendproyecto-producción-4a8d.up.railway.app/api';

  static Future<Map<String, dynamic>> subirFoto({
    required String token,
    required Uint8List imageBytes,
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('$baseUrl/foto/upload'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'foto_base64': 'data:image/jpeg;base64,$base64Image',
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
