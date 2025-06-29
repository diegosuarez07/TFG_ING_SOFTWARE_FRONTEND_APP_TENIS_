import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tournament_registration.dart';
import '../models/tournament.dart';
import '../services/auth_service.dart';

class TournamentRegistrationService {
  static const String baseUrl = 'http://192.168.0.173:8080/tournament-registrations';

  static Future<List<TournamentRegistration>> getUserRegistrations(int userId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => TournamentRegistration.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener inscripciones del usuario');
    }
  }

  static Future<List<TournamentRegistration>> getTournamentRegistrations(int tournamentId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/tournament/$tournamentId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => TournamentRegistration.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener inscripciones del torneo');
    }
  }

  static Future<bool> isUserRegistered(int tournamentId, int userId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/check?tournamentId=$tournamentId&userId=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as bool;
    } else {
      throw Exception('Error al verificar inscripción');
    }
  }

  static Future<TournamentRegistration> createRegistration({
    required int tournamentId,
    required int userId,
  }) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tournamentId': tournamentId,
        'userId': userId,
      }),
    );
    if (response.statusCode == 201) {
      return TournamentRegistration.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al inscribirse al torneo: ${response.body}');
    }
  }

  static Future<void> cancelRegistration({
    required int registrationId,
    required int userId,
  }) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$registrationId?userId=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error al cancelar inscripción');
    }
  }
} 