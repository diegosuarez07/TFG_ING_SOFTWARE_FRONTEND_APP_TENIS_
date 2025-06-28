import 'package:shared_preferences/shared_preferences.dart';
import 'user_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userEmailKey = 'user_email';

  // Guardar token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Obtener token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Eliminar token (solo local)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userEmailKey);
  }

  // Verificar si hay token guardado
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Validar token con el servidor
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

  static Future<bool> logout() async {
    try {
      final token = await getToken();
      
      if (token != null) {
        // Llamar al endpoint de logout en el backend
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