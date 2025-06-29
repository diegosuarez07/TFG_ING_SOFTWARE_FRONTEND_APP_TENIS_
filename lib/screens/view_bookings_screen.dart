import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import '../utils/jwt_utils.dart';
import '../models/booking_response.dart';

class ViewBookingsScreen extends StatefulWidget {
  @override
  State<ViewBookingsScreen> createState() => _ViewBookingsScreenState();
}

class _ViewBookingsScreenState extends State<ViewBookingsScreen> {
  List<BookingResponse> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    String? token = await AuthService.getToken();
    int? userId = token != null ? JwtUtils.getUserIdFromToken(token) : null;
    if (userId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener el usuario logueado')),
      );
      return;
    }
    final bookings = await BookingService.getUserBookings(userId);
    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  }

  Future<void> _confirmAndCancelBooking(int bookingId) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 32),
          SizedBox(width: 8),
          Text('¿Cancelar reserva?'),
        ],
      ),
      content: Text(
        '¿Estás seguro que deseas cancelar esta reserva?\nEsta acción no se puede deshacer.',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text('Sí, cancelar'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await _cancelBooking(bookingId);
  }
}

  Future<void> _cancelBooking(int bookingId) async {
  String? token = await AuthService.getToken();
  int? userId = token != null ? JwtUtils.getUserIdFromToken(token) : null;
  if (userId == null) return;
  bool success = await BookingService.cancelBooking(bookingId, userId);
  if (success) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('¡Reserva cancelada!'),
          ],
        ),
        content: Text('La reserva fue cancelada exitosamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _fetchBookings();
            },
            child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text('Error al cancelar la reserva. Intente nuevamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Reservas')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(child: Text('No tienes reservas', style: TextStyle(fontSize: 18)))
              : ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          'Cancha: ${booking.courtName} (N°${booking.courtNumber})',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha: ${booking.date}'),
                            Text('Horario: ${booking.startTime} a ${booking.endTime}'),
                            Text('Estado: ${booking.status}'),
                          ],
                        ),
                        trailing: booking.status == 'CONFIRMED'
                            ? IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                tooltip: 'Cancelar reserva',
                                onPressed: () => _cancelBooking(booking.bookingId),
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}