// lib/services/timeslot_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timeslot_response.dart';

class TimeslotService {
  static const String baseUrl = 'http://192.168.0.173:8080/timeslots';

  static Future<List<TimeslotResponse>> getAvailableTimeslots() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse('$baseUrl/available'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('Timeslot response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Timeslot data decoded: $data');
      return data.map((e) => TimeslotResponse.fromJson(e)).toList();
    } else {
      print('Error al obtener horarios: ${response.statusCode}');
      throw Exception('Error al obtener horarios');
    }
  }
}