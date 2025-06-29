import 'package:jwt_decoder/jwt_decoder.dart';

class JwtUtils {
  static int? getUserIdFromToken(String token) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      if (decodedToken.containsKey('userId')) {
        final userId = decodedToken['userId'];
        if (userId is int) return userId;
        return int.tryParse(userId.toString());
      }
      return null;
    } catch (e) {
      print('Error decodificando el token: $e');
      return null;
    }
  }

  static String? getUserTypeFromToken(String token) {
  try {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    if (decodedToken.containsKey('userType')) {
      return decodedToken['userType'].toString();
    }
    return null;
  } catch (e) {
    print('Error decodificando el token: $e');
    return null;
  }
}

}