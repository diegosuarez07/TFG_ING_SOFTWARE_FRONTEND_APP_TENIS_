import 'package:flutter/material.dart';

class TournamentRegistrationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscripcion Torneos')),
      body: Center(
        child: Text('Pantalla de Inscripción a Torneos', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
