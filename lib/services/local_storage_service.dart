// services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mood_entry.dart';

class LocalStorageService {
  static const String _moodEntriesKey = 'mood_entries';
  static const String _lastCheckInKey = 'last_checkin_date';
  static const String _completedResourcesKey = 'completed_resources';
  static const String _resourceProgressKey = 'resource_progress';

  // ============ MÉTODOS DE MOOD ENTRIES ============
  
  /// Guardar entrada de ánimo
  static Future<void> saveMoodEntry(MoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getMoodEntries();
    entries.add(entry);
    
    // Mantener solo últimos 90 días
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    entries.removeWhere((e) => e.date.isBefore(cutoffDate));
    
    await prefs.setString(_moodEntriesKey, MoodEntry.encodeList(entries));
    await prefs.setString(_lastCheckInKey, DateTime.now().toIso8601String());
  }

  /// Obtener todas las entradas de ánimo
  static Future<List<MoodEntry>> getMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesString = prefs.getString(_moodEntriesKey);
    
    if (entriesString == null || entriesString.isEmpty) {
      return [];
    }
    
    try {
      return MoodEntry.decodeList(entriesString);
    } catch (e) {
      print('Error decoding mood entries: $e');
      return [];
    }
  }

  /// Verificar si ya hizo check-in hoy
  static Future<bool> hasCheckedInToday() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastCheckIn = prefs.getString(_lastCheckInKey);
    
    if (lastCheckIn == null) return false;
    
    final lastDate = DateTime.parse(lastCheckIn);
    final today = DateTime.now();
    
    return lastDate.year == today.year &&
           lastDate.month == today.month &&
           lastDate.day == today.day;
  }

  /// Obtener entrada de ánimo de hoy
  static Future<MoodEntry?> getTodayMoodEntry() async {
    final entries = await getMoodEntries();
    final today = DateTime.now();
    
    try {
      return entries.firstWhere(
        (entry) =>
            entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day,
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtener promedio de ánimo de la última semana
  static Future<double> getWeeklyAverageMood() async {
    final entries = await getMoodEntries();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final weekEntries = entries.where((e) => e.date.isAfter(weekAgo)).toList();
    
    if (weekEntries.isEmpty) return 0;
    
    final sum = weekEntries.fold<int>(0, (sum, entry) => sum + entry.moodLevel);
    return sum / weekEntries.length;
  }

  /// Obtener entradas de ánimo de un rango de fechas
  static Future<List<MoodEntry>> getMoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final entries = await getMoodEntries();
    return entries.where((entry) {
      return entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             entry.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Obtener estadísticas de ánimo del último mes
  static Future<Map<String, dynamic>> getMonthlyMoodStats() async {
    final entries = await getMoodEntries();
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    
    final monthEntries = entries.where((e) => e.date.isAfter(monthAgo)).toList();
    
    if (monthEntries.isEmpty) {
      return {
        'average': 0.0,
        'totalEntries': 0,
        'bestDay': null,
        'worstDay': null,
      };
    }
    
    final sum = monthEntries.fold<int>(0, (sum, entry) => sum + entry.moodLevel);
    final average = sum / monthEntries.length;
    
    // Ordenar por nivel de ánimo
    monthEntries.sort((a, b) => b.moodLevel.compareTo(a.moodLevel));
    
    return {
      'average': average,
      'totalEntries': monthEntries.length,
      'bestDay': monthEntries.first,
      'worstDay': monthEntries.last,
    };
  }

  /// Eliminar todas las entradas de ánimo
  static Future<void> clearAllMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_moodEntriesKey);
    await prefs.remove(_lastCheckInKey);
  }

  // ============ MÉTODOS DE RECURSOS ============
  
  /// Obtener recursos completados
  static Future<Set<String>> getCompletedResources() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? completed = prefs.getStringList(_completedResourcesKey);
    return completed?.toSet() ?? {};
  }

  /// Marcar recurso como completado
  static Future<void> markResourceAsCompleted(String resourceId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await getCompletedResources();
    completed.add(resourceId);
    await prefs.setStringList(_completedResourcesKey, completed.toList());
    
    // Establecer progreso a 100%
    await updateResourceProgress(resourceId, 100);
  }

  /// Desmarcar recurso como completado
  static Future<void> unmarkResourceAsCompleted(String resourceId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await getCompletedResources();
    completed.remove(resourceId);
    await prefs.setStringList(_completedResourcesKey, completed.toList());
    
    // Limpiar progreso
    await clearResourceProgress(resourceId);
  }

  /// Verificar si un recurso está completado
  static Future<bool> isResourceCompleted(String resourceId) async {
    final completed = await getCompletedResources();
    return completed.contains(resourceId);
  }

  /// Obtener progreso de recursos (0-100)
  static Future<Map<String, int>> getResourceProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final String? progressJson = prefs.getString(_resourceProgressKey);
    
    if (progressJson == null || progressJson.isEmpty) {
      return {};
    }
    
    try {
      final Map<String, dynamic> decoded = jsonDecode(progressJson);
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      print('Error decoding resource progress: $e');
      return {};
    }
  }

  /// Obtener progreso de un recurso específico
  static Future<int> getResourceProgressById(String resourceId) async {
    final progressMap = await getResourceProgress();
    return progressMap[resourceId] ?? 0;
  }

  /// Actualizar progreso de un recurso
  static Future<void> updateResourceProgress(String resourceId, int progress) async {
    final prefs = await SharedPreferences.getInstance();
    final progressMap = await getResourceProgress();
    
    // Asegurar que el progreso esté entre 0 y 100
    progressMap[resourceId] = progress.clamp(0, 100);
    
    await prefs.setString(_resourceProgressKey, jsonEncode(progressMap));
    
    // Si llegó a 100%, marcar como completado
    if (progress >= 100) {
      final completed = await getCompletedResources();
      if (!completed.contains(resourceId)) {
        completed.add(resourceId);
        await prefs.setStringList(_completedResourcesKey, completed.toList());
      }
    }
  }

  /// Limpiar progreso de un recurso específico
  static Future<void> clearResourceProgress(String resourceId) async {
    final prefs = await SharedPreferences.getInstance();
    final progressMap = await getResourceProgress();
    progressMap.remove(resourceId);
    
    await prefs.setString(_resourceProgressKey, jsonEncode(progressMap));
  }

  /// Limpiar todos los recursos completados y progreso
  static Future<void> clearAllResources() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedResourcesKey);
    await prefs.remove(_resourceProgressKey);
  }

  /// Obtener estadísticas de recursos
  static Future<Map<String, dynamic>> getResourceStats() async {
    final completed = await getCompletedResources();
    final progress = await getResourceProgress();
    
    // Contar recursos en progreso (con progreso > 0 pero < 100)
    final inProgress = progress.entries.where((entry) {
      return entry.value > 0 && entry.value < 100 && !completed.contains(entry.key);
    }).length;
    
    return {
      'totalCompleted': completed.length,
      'inProgress': inProgress,
      'completedIds': completed.toList(),
      'progressMap': progress,
    };
  }

  /// Obtener recursos completados en un rango de tiempo
  /// (Nota: Necesitarías guardar timestamp de completado para esta funcionalidad)
  static Future<List<String>> getRecentlyCompletedResources(int days) async {
    // Por ahora retorna todos los completados
    // Podrías extender esto guardando timestamps
    final completed = await getCompletedResources();
    return completed.toList();
  }

  // ============ MÉTODOS GENERALES ============
  
  /// Limpiar todos los datos almacenados
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Exportar datos como JSON (para backup)
  static Future<String> exportData() async {
    final moodEntries = await getMoodEntries();
    final completed = await getCompletedResources();
    final progress = await getResourceProgress();
    
    final data = {
      'moodEntries': moodEntries.map((e) => e.toJson()).toList(),
      'completedResources': completed.toList(),
      'resourceProgress': progress,
      'exportDate': DateTime.now().toIso8601String(),
    };
    
    return jsonEncode(data);
  }

  /// Importar datos desde JSON (para restore)
  static Future<bool> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);
      final prefs = await SharedPreferences.getInstance();
      
      // Importar mood entries
      if (data['moodEntries'] != null) {
        final List<MoodEntry> entries = (data['moodEntries'] as List)
            .map((e) => MoodEntry.fromJson(e))
            .toList();
        await prefs.setString(_moodEntriesKey, MoodEntry.encodeList(entries));
      }
      
      // Importar recursos completados
      if (data['completedResources'] != null) {
        await prefs.setStringList(
          _completedResourcesKey,
          List<String>.from(data['completedResources']),
        );
      }
      
      // Importar progreso de recursos
      if (data['resourceProgress'] != null) {
        await prefs.setString(
          _resourceProgressKey,
          jsonEncode(data['resourceProgress']),
        );
      }
      
      return true;
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }

  /// Obtener tamaño aproximado de datos almacenados (en caracteres)
  static Future<int> getStorageSize() async {
    final prefs = await SharedPreferences.getInstance();
    int totalSize = 0;
    
    final keys = [
      _moodEntriesKey,
      _lastCheckInKey,
      _completedResourcesKey,
      _resourceProgressKey,
    ];
    
    for (final key in keys) {
      final value = prefs.getString(key);
      if (value != null) {
        totalSize += value.length;
      }
    }
    
    return totalSize;
  }
}