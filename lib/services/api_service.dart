import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://backendproyecto-produccion-4a8d.up.railway.app/api';

  // Recuperar token desde SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // OBTENER TAREAS
  static Future<List<dynamic>> getTareas({String? fecha}) async {
    try {
      String url = '$baseUrl/tareas';
      if (fecha != null) {
        url += '?fecha_inicio=$fecha&fecha_fin=$fecha';
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 401) {
        throw Exception('401');
      }

      if (response.statusCode != 200) {
        throw Exception('Error del servidor: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      return data['tareas'] ?? [];
    } catch (e) {
      debugPrint('Error getTareas: $e');
      rethrow;
    }
  }

  // OBTENER TAREAS CON RECORDATORIOS
  static Future<List<dynamic>> getTareasConRecordatorios() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tareas/recordatorios'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        throw Exception('401');
      }

      if (response.statusCode != 200) {
        throw Exception('Error del servidor: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      return data['tareas'] ?? [];
    } catch (e) {
      debugPrint('Error getTareasConRecordatorios: $e');
      rethrow;
    }
  }

  // CREAR TAREA
  static Future<Map<String, dynamic>> addTarea(Map<String, dynamic> tarea) async {
    try {
      debugPrint('Enviando tarea a API: $tarea');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/tareas'),
        headers: headers,
        body: jsonEncode(tarea),
      );

      debugPrint('Respuesta API: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('401');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error creando tarea');
      }
    } catch (e) {
      debugPrint('Error addTarea: $e');
      rethrow;
    }
  }

  // ACTUALIZAR TAREA
  static Future<Map<String, dynamic>> updateTarea(int id, Map<String, dynamic> tarea) async {
    try {
      debugPrint('Actualizando tarea $id: $tarea');

      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/tareas/$id'),
        headers: headers,
        body: jsonEncode(tarea),
      );

      debugPrint('Respuesta API actualización: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('401');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error actualizando tarea');
      }
    } catch (e) {
      debugPrint('Error updateTarea: $e');
      rethrow;
    }
  }

  // COMPLETAR TAREA
  static Future<void> completarTarea(int id, bool completada) async {
    try {
      final estado = completada ? 'completada' : 'pendiente';
      
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/tareas/$id'),
        headers: headers,
        body: jsonEncode({'estado': estado}),
      );

      if (response.statusCode == 401) {
        throw Exception('401');
      }

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error actualizando estado');
      }
    } catch (e) {
      debugPrint('Error completarTarea: $e');
      rethrow;
    }
  }

  // ELIMINAR TAREA
  static Future<void> deleteTarea(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/tareas/$id'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        throw Exception('401');
      }

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error eliminando tarea');
      }
    } catch (e) {
      debugPrint('Error deleteTarea: $e');
      rethrow;
    }
  }

  // ESTADÍSTICAS
  static Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/estadisticas'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        throw Exception('401');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['estadisticas'] ?? {};
      } else {
        // Si no hay endpoint de estadísticas, calcular básicas
        final tareas = await getTareas();
        final completadas = tareas.where((t) => t['estado'] == 'completada').length;
        final recordatorios = tareas.where((t) => t['recordatorio_activo'] == true).length;
        
        return {
          'total': tareas.length,
          'completadas': completadas,
          'pendientes': tareas.length - completadas,
          'recordatorios': recordatorios,
        };
      }
    } catch (e) {
      debugPrint('Error getEstadisticas: $e');
      return {
        'total': 0,
        'completadas': 0,
        'pendientes': 0,
        'recordatorios': 0,
      };
    }
  }

  //Metodo para que salgan las estadisticas en el admin
  

  // Método para limpiar el token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  static getAllTareasAdmin() {}

  static getEstadisticasAdmin() {}

  
}