import 'package:flutter/material.dart';

class ViewRegistrationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Inscripciones')),
      body: Center(
        child: Text('Pantalla de Mis Inscripciones', style: TextStyle(fontSize: 20)),
      ),
    );
  }
} 