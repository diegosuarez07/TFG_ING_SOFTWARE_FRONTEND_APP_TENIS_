import 'package:flutter/material.dart';

class CreateTournamentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Torneo')),
      body: Center(
        child: Text('Pantalla de Crear Torneo', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
