class Evaluacion {
  final int id;
  final int usuarioId;
  final String nivelRiesgo;
  final String estadoEmocional;
  final String fechaEvaluacion;
  final String observaciones;

  Evaluacion({
    required this.id,
    required this.usuarioId,
    required this.nivelRiesgo,
    required this.estadoEmocional,
    required this.fechaEvaluacion,
    required this.observaciones,
  });

  factory Evaluacion.fromJson(Map<String, dynamic> json) {
    return Evaluacion(
      id: json['id'] ?? 0, // Valor por defecto si es null
      usuarioId: json['usuario_id'] ?? 0,
      nivelRiesgo: json['nivel_riesgo'] ?? '',
      estadoEmocional: json['estado_emocional'] ?? '',
      fechaEvaluacion: json['fecha_evaluacion'] ?? '',
      observaciones: json['observaciones'] ?? '',
    );
  }
}
