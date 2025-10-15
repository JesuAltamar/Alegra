import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'evaluacion_model.dart';

Future<List<Evaluacion>> fetchEvaluaciones() async {
  final response = await http.get(
    Uri.parse('https://backendproyecto-production-4a8d.up.railway.app/api/evaluaciones'),
  );

  if (response.statusCode == 200) {
    return compute(procesarEvaluaciones, response.body);
  } else {
    throw Exception('Error al cargar las evaluaciones');
  }
}

List<Evaluacion> procesarEvaluaciones(String body) {
  final List<dynamic> datos = jsonDecode(body);
  return datos.map((e) => Evaluacion.fromJson(e)).toList();
}
