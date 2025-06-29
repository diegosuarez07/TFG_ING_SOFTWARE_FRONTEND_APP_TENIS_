import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/tournament_registration.dart';
import '../services/tournament_service.dart';
import '../services/tournament_registration_service.dart';
import '../services/auth_service.dart';

class ViewRegistrationsScreen extends StatefulWidget {
  @override
  _ViewRegistrationsScreenState createState() => _ViewRegistrationsScreenState();
}

class _ViewRegistrationsScreenState extends State<ViewRegistrationsScreen> {
  String? userType;
  int? userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserTypeAndId();
  }

  Future<void> _loadUserTypeAndId() async {
    userType = await AuthService.getUserType();
    userId = await AuthService.getUserId();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (userType == 'JUGADOR') {
      return ViewRegistrationsScreenJugador(userId: userId!);
    } else if (userType == 'CLUB') {
      return ViewRegistrationsScreenClub();
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Tipo de usuario no válido: "$userType"',
                style: TextStyle(fontSize: 18, color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'userId: $userId',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
  }
}

// =================== JUGADOR ===================
class ViewRegistrationsScreenJugador extends StatelessWidget {
  final int userId;
  const ViewRegistrationsScreenJugador({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Inscripciones')),
      body: FutureBuilder<List<TournamentRegistration>>(
        future: TournamentRegistrationService.getUserRegistrations(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error al cargar inscripciones: ${snapshot.error}',
                    style: TextStyle(fontSize: 18, color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          final registrations = snapshot.data ?? [];
          if (registrations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes inscripciones activas.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: registrations.length,
            itemBuilder: (context, i) {
              final reg = registrations[i];
              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(reg.tournamentName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('Fecha de inscripción: ${reg.registrationDate.day}/${reg.registrationDate.month}/${reg.registrationDate.year}'),
                  trailing: ElevatedButton.icon(
                    icon: Icon(Icons.cancel),
                    label: Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      try {
                        await TournamentRegistrationService.cancelRegistration(
                          registrationId: reg.registrationId,
                          userId: userId,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Inscripción cancelada exitosamente')),
                        );
                        // Fuerza la recarga de la pantalla
                        (context as Element).reassemble();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al cancelar inscripción: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// =================== CLUB ===================
class ViewRegistrationsScreenClub extends StatefulWidget {
  @override
  _ViewRegistrationsScreenClubState createState() => _ViewRegistrationsScreenClubState();
}

class _ViewRegistrationsScreenClubState extends State<ViewRegistrationsScreenClub> {
  Tournament? _selectedTournament;
  List<Tournament> _tournaments = [];
  List<TournamentRegistration> _registrations = [];
  bool _loading = true;
  bool _loadingRegistrations = false;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    try {
      _tournaments = await TournamentService().getAllTournaments();
    } catch (e) {
      print('Error loading tournaments: $e');
      _tournaments = [];
    }
    setState(() => _loading = false);
  }

  Future<void> _loadRegistrations(int tournamentId) async {
    setState(() {
      _loadingRegistrations = true;
      _registrations = [];
    });
    try {
      _registrations = await TournamentRegistrationService.getTournamentRegistrations(tournamentId);
    } catch (e) {
      print('Error loading registrations: $e');
      _registrations = [];
    }
    setState(() => _loadingRegistrations = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (_tournaments.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Inscripciones por Torneo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No hay torneos disponibles.',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('Inscripciones por Torneo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<Tournament>(
              decoration: InputDecoration(
                labelText: 'Selecciona un torneo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: _selectedTournament,
              items: _tournaments.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t.name),
                );
              }).toList(),
              onChanged: (t) {
                setState(() {
                  _selectedTournament = t;
                  _registrations = [];
                });
                if (t != null) {
                  _loadRegistrations(t.tournamentId!);
                }
              },
            ),
          ),
          Expanded(
            child: _selectedTournament == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Selecciona un torneo para ver inscriptos.',
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _loadingRegistrations
                    ? Center(child: CircularProgressIndicator())
                    : _registrations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, size: 48, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No hay inscriptos en este torneo.',
                                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _registrations.length,
                            itemBuilder: (context, index) {
                              final reg = _registrations[index];
                              return Card(
                                elevation: 4,
                                margin: EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  title: Text(reg.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  subtitle: Text('Fecha de inscripción: ${reg.registrationDate.day}/${reg.registrationDate.month}/${reg.registrationDate.year}'),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}