import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'menu_block.dart';
import 'create_tournament_screen.dart';
import 'view_registrations_screen.dart';
import 'court_booking_screen.dart';
import 'view_bookings_screen.dart';

class ClubMenuScreen extends StatelessWidget {
  const ClubMenuScreen({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('INICIO'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.grey[700]),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Cerrar sesión'),
                  content: Text('¿Seguro que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Cerrar sesión'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _logout(context);
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  MenuBlock(
                    label: 'CREAR TORNEO',
                    icon: Icons.emoji_events,
                    color: Colors.green[200]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateTournamentScreen()),
                      );
                    },
                  ),
                  SizedBox(width: 16),
                  MenuBlock(
                    label: 'VER INSCRIPCIONES',
                    icon: Icons.assignment,
                    color: Colors.blue[200]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewRegistrationsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  MenuBlock(
                    label: 'CREAR RESERVAS',
                    icon: Icons.sports_tennis,
                    color: Colors.pink[200]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CourtBookingScreen()),
                      );
                    },
                  ),
                  SizedBox(width: 16),
                  MenuBlock(
                    label: 'VER RESERVAS',
                    icon: Icons.calendar_today,
                    color: Colors.amber[200]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewBookingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}