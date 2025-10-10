import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrlAdmin = "http://backendproyecto-producción-4a8d.up.railway.app'/api/admin";

/// 🔹 Obtiene actividades recientes (últimos registros, tareas, juegos, chats)
Future<List<Map<String, dynamic>>> fetchRecentActivities() async {
  final url = Uri.parse("$baseUrlAdmin/actividades-recientes");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception("Error al cargar actividades recientes");
  }
}

/// 🔹 Busca actividades de un usuario específico
Future<List<Map<String, dynamic>>> searchUserActivities(String userName) async {
  final url = Uri.parse("$baseUrlAdmin/actividades-usuario?nombre=$userName");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception("Error al buscar actividades del usuario");
  }
}
