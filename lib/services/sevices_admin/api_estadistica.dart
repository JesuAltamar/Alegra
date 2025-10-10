import 'package:http/http.dart' as http;
import 'dart:convert';

// URL base de tu API
const String _baseUrlAdmin = 'http://backendproyecto-producción-4a8d.up.railway.app/api/admin';
const String _baseUrlJuegos = 'http://backendproyecto-producción-4a8d.up.railway.app/api/juegos';

// ----------- Estadísticas globales -----------
Future<Map<String, dynamic>> fetchAdminStats() async {
  final url = '$_baseUrlAdmin/estadisticas';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data as Map<String, dynamic>;
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

// ----------- Usuarios activos por día -----------
Future<Map<String, int>> fetchWeeklyActiveUsers() async {
  final url = '$_baseUrlAdmin/usuarios-activos-semanal';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Map<String, int>.from(jsonDecode(response.body));
    } else {
      throw Exception("Error al cargar usuarios activos por día");
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

// ----------- Iniciar sesión de juego -----------
Future<int?> iniciarJuego(int usuarioId, String juegoNombre) async {
  final url = '$_baseUrlJuegos/iniciar';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario_id': usuarioId,
        'juego_nombre': juegoNombre,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['sesion_id'] as int; // 👈 devuelve el ID de la sesión
    } else {
      throw Exception('Error al iniciar sesión de juego');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

// ----------- Finalizar sesión de juego -----------
Future<void> finalizarJuego(int sesionId) async {
  final url = '$_baseUrlJuegos/finalizar';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sesion_id': sesionId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al finalizar sesión de juego');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

// ----------- Estadísticas de juegos -----------
Future<int> fetchJuegosStats() async {
  final url = '$_baseUrlJuegos/estadisticas';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['total_sesiones'] as int;
    } else {
      throw Exception("Error al cargar estadísticas de juegos");
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

