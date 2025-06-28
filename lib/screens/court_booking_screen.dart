import 'package:flutter/material.dart';
import '../models/timeslot_response.dart';
import '../models/court.dart';
import '../services/timeslot_service.dart';
import '../services/court_service.dart';

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
      final courts = await CourtService.getCourts();
      final timeslots = await TimeslotService.getAvailableTimeslots();
      setState(() {
        _courts = courts;
        _allTimeslots = timeslots;
        _isLoading = false;
      });
    } catch (e) {
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

  void _onReserve() {
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
    // Aquí iría la lógica para reservar (POST al backend)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reserva realizada para N°${_selectedCourt!.courtNumber} - ${_selectedCourt!.courtName} (${_selectedCourt!.surfaceType}) de ${_selectedTimeslot!.startTime} a ${_selectedTimeslot!.endTime}',
        ),
      ),
    );
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
                          width: 220, // Ajusta el ancho según tu diseño
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
                    width: 220, // Ajusta el ancho según tu diseño
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