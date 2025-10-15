// services/streak_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro9/rachas/streak_models.dart';

class StreakService {
  final String baseUrl = 'https://backendproyecto-production-4a8d.up.railway.app/api'; // Cambia a tu IP/URL

  // Obtener racha actual del usuario
  Future<StreakStats> obtenerRacha(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/streak/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return StreakStats.fromJson(data);
        } else {
          throw Exception('Error en respuesta del servidor');
        }
      } else {
        throw Exception('Error al obtener la racha: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerRacha: $e');
      rethrow;
    }
  }

  // Completar tarea diaria
  Future<Map<String, dynamic>> completarTarea(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/streak/completar-tarea'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error al completar tarea');
      }
    } catch (e) {
      print('Error en completarTarea: $e');
      rethrow;
    }
  }

  // Verificar si ya completó la tarea hoy
  Future<bool> yaCompletoHoy(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/streak/verificar-hoy/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['completada_hoy'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error en yaCompletoHoy: $e');
      return false;
    }
  }

  // Obtener historial de racha
  Future<List<StreakHistorialItem>> obtenerHistorial(int userId, {int dias = 30}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/streak/historial/$userId?dias=$dias'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List historial = data['historial'];
          return historial.map((item) => StreakHistorialItem.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error en obtenerHistorial: $e');
      return [];
    }
  }
}