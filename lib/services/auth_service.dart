import 'package:shared_preferences/shared_preferences.dart';
import 'user_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../utils/jwt_utils.dart'; 

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userEmailKey = 'user_email';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }


  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUserType() async {
  final token = await getToken();
  if (token == null) return null;
  return JwtUtils.getUserTypeFromToken(token);
}

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userEmailKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;
    
    return await UserService.validateToken(token);
  }

  // Login completo
  static Future<LoginResponse> login(String email, String password) async {
    final loginRequest = LoginRequest(email: email, password: password);
    final response = await UserService.login(loginRequest);
    
    if (response.success && response.token != null) {
      await saveToken(response.token!);
    }
    
    return response;
  }

  static Future<int?> getUserId() async {
    final token = await getToken();
    if (token == null) return null;
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['userId'] is int
        ? decodedToken['userId']
        : int.tryParse(decodedToken['userId'].toString());
  }

  static Future<bool> logout() async {
    try {
      final token = await getToken();
      
      if (token != null) {
        final backendSuccess = await UserService.logout(token);
        
        if (backendSuccess) {
          print('Logout exitoso en backend');
        } else {
          print('Error en logout del backend, pero continuando...');
        }
      }
      
      // Siempre eliminar token localmente (incluso si falla el backend)
      await removeToken();
      print('Token eliminado localmente');
      
      return true;
      
    } catch (e) {
      print('Error en logout: $e');
      // Aún así eliminar token localmente
      await removeToken();
      return false;
    }
  }
}