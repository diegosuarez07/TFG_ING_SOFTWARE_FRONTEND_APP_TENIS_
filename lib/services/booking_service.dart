import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/booking_response.dart';

class BookingService {
  static Future<List<BookingResponse>> getUserBookings(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) return [];

    final url = Uri.parse('http://192.168.0.173:8080/courtbookings/user/$userId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BookingResponse.fromJson(json)).toList();
    } else {
      print('Error al obtener reservas: ${response.body}');
      return [];
    }
  }

  static Future<bool> cancelBooking(int bookingId, int userId) async {
    final token = await AuthService.getToken();
    if (token == null) return false;

    final url = Uri.parse('http://192.168.0.173:8080/courtbookings/$bookingId/cancel?userId=$userId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }
}