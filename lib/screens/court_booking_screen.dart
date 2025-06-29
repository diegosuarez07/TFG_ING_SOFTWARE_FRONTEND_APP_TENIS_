import 'package:flutter/material.dart';
import '../models/timeslot_response.dart';
import '../models/court.dart';
import '../services/timeslot_service.dart';
import '../services/court_service.dart';
import '../services/auth_service.dart';
import '../services/court_booking_service.dart';
import '../utils/jwt_utils.dart';

class CourtBookingScreen extends StatefulWidget {
  @override
  State<CourtBookingScreen> createState() => _CourtBookingScreenState();
}

class _CourtBookingScreenState extends State<CourtBookingScreen> {
  List<Court> _courts = [];
  Court? _selectedCourt;

  List<TimeslotResponse> _allTimeslots = [];
  List<TimeslotResponse> _filteredTimeslots = [];
  TimeslotResponse? _selectedTimeslot;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourtsAndTimeslots();
  }

  Future<void> _fetchCourtsAndTimeslots() async {
  try {
    print('Cargando canchas...');
    final courts = await CourtService.getCourts();
    print('Canchas cargadas: ${courts.length}');
    print('Cargando timeslots...');
    final timeslots = await TimeslotService.getAvailableTimeslots();
    print('Timeslots cargados: ${timeslots.length}');
    setState(() {
      _courts = courts;
      _allTimeslots = timeslots;
      _isLoading = false;
    });
  } catch (e) {
    print('Error al cargar datos: $e');
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar datos')),
    );
  }
}

  void _onCourtSelected(Court? court) {
    setState(() {
      _selectedCourt = court;
      _filteredTimeslots = court == null
          ? []
          : _allTimeslots.where((ts) => ts.courtName == court.courtName).toList();
      _selectedTimeslot = null;
    });
  }

  Future<void> _onReserve() async {
    if (_selectedCourt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccione una cancha')),
      );
      return;
    }
    if (_selectedTimeslot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccione un horario')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Recupera el token y el userId
    String? token = await AuthService.getToken();
    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró token de sesión')),
      );
      return;
    }
    int? userId = JwtUtils.getUserIdFromToken(token);
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener el usuario logueado')),
      );
      return;
    }

    bool success = await CourtBookingService.createBooking(
      userId: userId,
      timeslotId: int.parse(_selectedTimeslot!.timeslotId.toString()),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 8),
              Text('¡Reserva exitosa!'),
            ],
          ),
          content: Text(
            'Reserva realizada para:\n'
            'N°${_selectedCourt!.courtNumber} - ${_selectedCourt!.courtName} (${_selectedCourt!.surfaceType})\n'
            'Horario: ${_selectedTimeslot!.date} de ${_selectedTimeslot!.startTime} a ${_selectedTimeslot!.endTime}',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedCourt = null;
                  _selectedTimeslot = null;
                  _filteredTimeslots = [];
                });
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
          content: Text('Error al realizar la reserva. Intente nuevamente.'),
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
      appBar: AppBar(title: Text('Reservar Cancha')),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reservar Alquiler de Cancha',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 32),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<Court>(
                    decoration: InputDecoration(
                      labelText: 'Selecciona una cancha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: _selectedCourt,
                    items: _courts.map((court) {
                      return DropdownMenuItem<Court>(
                        value: court,
                        child: Container(
                          width: 220,
                          child: Text(
                            'N°${court.courtNumber} - ${court.courtName} (${court.surfaceType}) [${court.status}]',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: court.status.toLowerCase() == 'available'
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _onCourtSelected,
                  ),
            SizedBox(height: 24),
            DropdownButtonFormField<TimeslotResponse>(
              decoration: InputDecoration(
                labelText: 'Selecciona un horario disponible',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              value: _selectedTimeslot,
              items: _filteredTimeslots.map((ts) {
                return DropdownMenuItem<TimeslotResponse>(
                  value: ts,
                  child: Container(
                    width: 220,
                    child: Text(
                      '${ts.date} - ${ts.startTime} a ${ts.endTime}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTimeslot = value;
                });
              },
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _onReserve,
                icon: Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(
                  'RESERVAR ALQUILER',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}