import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tournament.dart';

class TournamentService {
  static const String baseUrl = 'http://192.168.0.173:8080/tournaments'; 

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Tournament> createTournament(Tournament tournament) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No se encontró el token de autenticación');
    }

    print('Enviando petición a: $baseUrl');
    print('Datos del torneo: ${jsonEncode(tournament.toJson())}');
    print('Token: ${token.substring(0, 20)}...');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(tournament.toJson()),
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('Response headers: ${response.headers}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('El servidor devolvió una respuesta vacía');
      }
      
      try {
        final jsonResponse = jsonDecode(response.body);
        return Tournament.fromJson(jsonResponse);
      } catch (e) {
        print('Error al parsear JSON: $e');
        print('Response body: ${response.body}');
        throw Exception('Error al procesar la respuesta del servidor: $e');
      }
    } else {
      String errorMessage = 'Error ${response.statusCode}';
      
      if (response.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorBody['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Error ${response.statusCode}: ${response.body}';
        }
      }
      
      throw Exception(errorMessage);
    }
  }

  Future<List<Tournament>> getAvailableTournaments() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No se encontró el token de autenticación');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/available'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return [];
      }
      
      try {
        final List<dynamic> tournamentsJson = jsonDecode(response.body);
        return tournamentsJson.map((json) => Tournament.fromJson(json)).toList();
      } catch (e) {
        throw Exception('Error al procesar la respuesta del servidor: $e');
      }
    } else {
      String errorMessage = 'Error ${response.statusCode}';
      
      if (response.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorBody['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Error ${response.statusCode}: ${response.body}';
        }
      }
      
      throw Exception(errorMessage);
    }
  }

  Future<Tournament> getTournamentById(int tournamentId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No se encontró el token de autenticación');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$tournamentId'), // URL correcta: http://192.168.0.173:8080/tournaments/{id}
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('El servidor devolvió una respuesta vacía');
      }
      
      try {
        final jsonResponse = jsonDecode(response.body);
        return Tournament.fromJson(jsonResponse);
      } catch (e) {
        throw Exception('Error al procesar la respuesta del servidor: $e');
      }
    } else {
      String errorMessage = 'Error ${response.statusCode}';
      
      if (response.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorBody['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Error ${response.statusCode}: ${response.body}';
        }
      }
      
      throw Exception(errorMessage);
    }
  }

  Future<List<Tournament>> getAllTournaments() async {
  final token = await _getToken();
  if (token == null) {
    throw Exception('No se encontró el token de autenticación');
  }
  final response = await http.get(
    Uri.parse(baseUrl),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    final List<dynamic> tournamentsJson = jsonDecode(response.body);
    return tournamentsJson.map((json) => Tournament.fromJson(json)).toList();
  } else {
    throw Exception('Error al obtener torneos');
  }
}
} 