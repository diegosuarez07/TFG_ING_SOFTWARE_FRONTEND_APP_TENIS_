import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class UserService {
  static const String baseUrl = 'http://192.168.0.173:8080/users';

  // Método existente de registro
  static Future<bool> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Usuario registrado exitosamente');
        return true;
      } else {
        print('Error al registrar usuario: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  // Método existente de login
  static Future<LoginResponse> login(LoginRequest loginRequest) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(loginRequest.toJson()),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return LoginResponse.fromJson(jsonResponse);
      } else {
        return LoginResponse(
          success: false,
          message: 'Error de conexión: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error de conexión: $e');
      return LoginResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  // Método existente de validar token
  static Future<bool> validateToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['valid'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error validando token: $e');
      return false;
    }
  }

  static Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Logout status code: ${response.statusCode}');
      print('Logout response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'] ?? false;
      } else {
        print('Error en logout: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error de conexión en logout: $e');
      return false;
    }
  }
}