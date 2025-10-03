// models/streak_models.dart

class StreakStats {
  final int rachaActual;
  final int rachaMaxima;
  final DateTime? ultimaActividad;

  StreakStats({
    required this.rachaActual,
    required this.rachaMaxima,
    this.ultimaActividad,
  });

  factory StreakStats.fromJson(Map<String, dynamic> json) {
    return StreakStats(
      rachaActual: json['racha_actual'] ?? 0,
      rachaMaxima: json['racha_maxima'] ?? 0,
      ultimaActividad: json['ultima_actividad'] != null
          ? DateTime.parse(json['ultima_actividad'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'racha_actual': rachaActual,
      'racha_maxima': rachaMaxima,
      'ultima_actividad': ultimaActividad?.toIso8601String().split('T')[0],
    };
  }
}

class StreakHistorialItem {
  final DateTime fecha;
  final bool tareaCompletada;

  StreakHistorialItem({
    required this.fecha,
    required this.tareaCompletada,
  });

  factory StreakHistorialItem.fromJson(Map<String, dynamic> json) {
    return StreakHistorialItem(
      fecha: DateTime.parse(json['fecha']),
      tareaCompletada: json['tarea_completada'] ?? false,
    );
  }
}