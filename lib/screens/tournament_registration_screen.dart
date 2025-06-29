import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';
import '../services/tournament_registration_service.dart';
import '../services/auth_service.dart';

class TournamentRegistrationScreen extends StatefulWidget {
  @override
  _TournamentRegistrationScreenState createState() => _TournamentRegistrationScreenState();
}

class _TournamentRegistrationScreenState extends State<TournamentRegistrationScreen> {
  late Future<List<Tournament>> _futureTournaments;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _futureTournaments = TournamentService().getAvailableTournaments();
  }

  Future<void> _loadUserId() async {
    userId = await AuthService.getUserId();
    setState(() {});
  }

  Future<void> _registerToTournament(Tournament tournament) async {
  try {
    final alreadyRegistered = await TournamentRegistrationService.isUserRegistered(
      tournament.tournamentId!,
      userId!,
    );
    if (alreadyRegistered) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Icon(Icons.info_outline, color: Colors.orange, size: 48),
          content: Text('Ya estás inscripto en este torneo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Aceptar'),
            ),
          ],
        ),
      );
      return;
    }

    await TournamentRegistrationService.createRegistration(
      tournamentId: tournament.tournamentId!,
      userId: userId!,
    );
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Icon(Icons.check_circle, color: Colors.green, size: 48),
        content: Text('¡Inscripción exitosa al torneo "${tournament.name}"!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
    setState(() {
      _futureTournaments = TournamentService().getAvailableTournaments();
    });
  } catch (e) {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Icon(Icons.error, color: Colors.red, size: 48),
        content: Text('Error al inscribirse: $e'),
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
      appBar: AppBar(title: Text('Inscripción a Torneos')),
      body: FutureBuilder<List<Tournament>>(
        future: _futureTournaments,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final tournaments = snapshot.data!;
          if (tournaments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay torneos disponibles para inscripción.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final t = tournaments[index];
              final now = DateTime.now();
              final isRegistrationOpen = now.isAfter(t.registrationStartDate) && now.isBefore(t.registrationEndDate.add(Duration(days: 1)));
              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(t.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Categoría: ${t.category}'),
                      Text('Inscripción: ${t.registrationStartDate.day}/${t.registrationStartDate.month} - ${t.registrationEndDate.day}/${t.registrationEndDate.month}'),
                      Text('Fecha torneo: ${t.tournamentStartDate.day}/${t.tournamentStartDate.month} - ${t.tournamentEndDate.day}/${t.tournamentEndDate.month}'),
                      Text('Cupos máximos: ${t.maxPlayers}'),
                    ],
                  ),
                  trailing: isRegistrationOpen
                      ? ElevatedButton.icon(
                          icon: Icon(Icons.how_to_reg),
                          label: Text('Inscribirse'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[400],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _registerToTournament(t),
                        )
                      : Text('Fuera de plazo', style: TextStyle(color: Colors.red)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
