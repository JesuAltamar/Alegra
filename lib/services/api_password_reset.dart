import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordResetService {
  // ⚠️ CAMBIAR ESTA URL PARA QUE COINCIDA CON TUS OTROS SERVICIOS
  static const String baseUrl = 'https://backendproyecto-producción-4a8d.up.railway.app/api/password';
  
  // Solicitar reset de contraseña
  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      print('📤 Solicitando reset para: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/request-reset'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'correo': email.trim(),
        }),
      ).timeout(const Duration(seconds: 30));

      print('📦 Respuesta status: ${response.statusCode}');
      print('📦 Respuesta body: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "data": data,
        };
      }
    } catch (e) {
      print('❌ Error en requestPasswordReset: $e');
      return {
        "success": false,
        "data": {"message": "Error de conexión: $e"}
      };
    }
  }

  // Verificar token de reset
  static Future<Map<String, dynamic>> verifyResetToken(String token) async {
    try {
      print('🔍 Verificando token: ${token.substring(0, 20)}...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/verify-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'token': token.trim(),
        }),
      ).timeout(const Duration(seconds: 30));

      print('📦 Verificación status: ${response.statusCode}');
      print('📦 Verificación body: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "data": data,
        };
      }
    } catch (e) {
      print('❌ Error en verifyResetToken: $e');
      return {
        "success": false,
        "data": {"message": "Error de conexión: $e"}
      };
    }
  }

  // Restablecer contraseña
  static Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      print('🔄 Restableciendo contraseña con token: ${token.substring(0, 20)}...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/reset'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'token': token.trim(),
          'password': newPassword,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📦 Reset status: ${response.statusCode}');
      print('📦 Reset body: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "data": data,
        };
      }
    } catch (e) {
      print('❌ Error en resetPassword: $e');
      return {
        "success": false,
        "data": {"message": "Error de conexión: $e"}
      };
    }
  }

  // Validar formato de email
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  // Validar fortaleza de contraseña
  static Map<String, dynamic> validatePassword(String password) {
    final result = {
      'isValid': false,
      'errors': <String>[],
      'strength': 0,
    };

    if (password.length < 6) {
      (result['errors'] as List<String>).add('Debe tener al menos 6 caracteres');
    }

    if (password.length >= 6) {
      result['strength'] = 1;
    }

    if (password.length >= 8) {
      result['strength'] = 2;
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      result['strength'] = (result['strength'] as int) + 1;
    } else {
      (result['errors'] as List<String>).add('Incluye al menos una mayúscula');
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      result['strength'] = (result['strength'] as int) + 1;
    } else {
      (result['errors'] as List<String>).add('Incluye al menos un número');
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      result['strength'] = (result['strength'] as int) + 1;
    }

    result['isValid'] = ((result['errors'] as List<String>).isEmpty);
    
    return result;
  }

  // Obtener descripción de fortaleza
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Muy débil';
      case 2:
        return 'Débil';
      case 3:
        return 'Regular';
      case 4:
        return 'Fuerte';
      case 5:
        return 'Muy fuerte';
      default:
        return 'Muy débil';
    }
  }

  // Obtener color de fortaleza
  static int getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 0xFFE53E3E; // Rojo
      case 2:
        return 0xFFFF8A00; // Naranja
      case 3:
        return 0xFFFFD700; // Amarillo
      case 4:
        return 0xFF38A169; // Verde
      case 5:
        return 0xFF00B894; // Verde fuerte
      default:
        return 0xFFE53E3E;
    }
  }
}