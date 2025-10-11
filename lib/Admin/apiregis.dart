import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> enviarEvaluacionDesdeUrl({
    required int usuarioId,
    required String nivelRiesgo,
    required String estadoEmocional,
    required String fechaEvaluacion,
    required String observaciones,
  }) async {
    final uri = Uri.parse(
      'https://backendproyecto-production-4a8d.up.railway.app/api/evaluacionip'
      '?usuario_id=$usuarioId'
      '&nivel_riesgo=$nivelRiesgo'
      '&estado_emocional=$estadoEmocional'
      '&fecha_evaluacion=$fechaEvaluacion'
      '&observaciones=$observaciones',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 201) {
        print('✅ Evaluación registrada correctamente');
      } else {
        print('❌ Error al registrar evaluación: ${response.body}');
      }
    } catch (e) {
      print('⚠️ Error de conexión: $e');
    }
  }
}
