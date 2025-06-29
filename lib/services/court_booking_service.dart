import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CourtBookingService {
  static Future<bool> createBooking({
    required int userId,
    required int timeslotId,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) return false;

    final url = Uri.parse('http://192.168.0.173:8080/courtbookings');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'timeslotId': timeslotId,
      }),
    );
    return response.statusCode == 201;
  }
}