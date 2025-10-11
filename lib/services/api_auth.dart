import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> loginUsuario(String correo, String password) async {
  final url = Uri.parse("https://backendproyecto-produccion-4a8d.up.railway.app/api/login");

  final response = await http.post(
    url,
    headers: {"Content-Type":"application/json"},
    body: jsonEncode({
      "correo": correo,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // Guardar token en almacenamiento local
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", data["token"]);

    return {"success": true, "data": data};
  } else {
    return {"success": false, "data": jsonDecode(response.body)};
  }
}
