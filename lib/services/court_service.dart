// lib/services/court_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/court.dart';

class CourtService {
  static const String baseUrl = 'http://192.168.0.173:8080/courts';

  static Future<List<Court>> getCourts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('Court response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Court data decoded: $data');
      return data.map((e) => Court.fromJson(e)).toList();
    } else {
      print('Error al obtener canchas: ${response.statusCode}');
      throw Exception('Error al obtener canchas');
    }
  }
}