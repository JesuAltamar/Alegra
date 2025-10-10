import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// 🌐 URL base del backend
const String baseUrl = "https://backendproyecto-producción-4a8d.up.railway.app/api/usuarios";

/// 📌 Obtener todos los usuarios
Future<List<Usuario>> buscarUsuarios() async {
  final respuesta = await http.get(Uri.parse(baseUrl));

  if (respuesta.statusCode == 200) {
    return compute(procesarInfo, respuesta.body);
  } else {
    throw Exception('Error al obtener usuarios');
  }
}

/// 📌 Procesar lista de usuarios en paralelo (Isolate)
List<Usuario> procesarInfo(String respuesta) {
  final datos = json.decode(respuesta).cast<Map<String, dynamic>>();
  return datos.map<Usuario>((json) => Usuario.fromJson(json)).toList();
}

/// 📌 Editar un usuario
Future<void> editarUsuario(Usuario usuario) async {
  final url = Uri.parse("$baseUrl/${usuario.id}");

  final respuesta = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "nombre": usuario.nombre,
      "genero": usuario.genero,
      "fecha_nacimiento": usuario.fechaNacimiento,
      "telefono": usuario.telefono,
      "correo": usuario.correo,
    }),
  );

  if (respuesta.statusCode != 200) {
    throw Exception("Error al actualizar usuario: ${respuesta.body}");
  }
}

/// 📌 Eliminar un usuario
Future<void> eliminarUsuario(int id) async {
  final url = Uri.parse("$baseUrl/$id");

  final respuesta = await http.delete(url);

  if (respuesta.statusCode != 200) {
    throw Exception("Error al eliminar usuario: ${respuesta.body}");
  }
}

/// 📌 Modelo Usuario
class Usuario {
  final int id;
  final String nombre;
  // Campos que permiten NULL en la BD, ahora son String?
  final String? genero;          // <-- Antes String
  final String? fechaNacimiento; // <-- Antes String
  final String? telefono;        // <-- Antes String
  // El correo y otros campos NO NULL siguen siendo String
  final String correo;
  
  // Incluir el rol si lo usas en el futuro, por ahora no está en esta clase.

  Usuario({
    required this.id,
    required this.nombre,
    this.genero,               // Ya no es 'required'
    this.fechaNacimiento,      // Ya no es 'required'
    this.telefono,             // Ya no es 'required'
    required this.correo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json["id"] as int,
      nombre: json["nombre"] as String,
      
      // 💡 SOLUCIÓN: Usar as String? para campos que pueden ser null
      genero: json["genero"] as String?, 
      fechaNacimiento: json["fecha_nacimiento"] as String?,
      telefono: json["telefono"] as String?,
      
      correo: json["correo"] as String,
      
      // Nota: Es mejor usar `as Type` para asegurar el tipo, y `as Type?` para anulables.
    );
  }
}
