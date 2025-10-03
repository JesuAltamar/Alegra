import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> registrarDatos({
  required String nombre,
  required String fechaNacimiento,
  required String telefono,
  required String correo,
  required String password,
  String genero = "No especificado", // Campo por defecto
}) async {
  final url = Uri.parse("http://localhost:5000/api/usuariosip");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "nombre": nombre,
      "genero": genero, // ✅ Agregado
      "fecha_nacimiento": fechaNacimiento,
      "telefono": telefono,
      "correo": correo,
      "password": password,
    }),
  );

  if (response.statusCode == 201) {
    return {"success": true, "data": jsonDecode(response.body)};
  } else {
    return {"success": false, "data": jsonDecode(response.body)};
  }
}
