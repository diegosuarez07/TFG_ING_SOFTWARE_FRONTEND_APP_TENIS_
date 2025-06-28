import 'package:flutter/material.dart';

class CreateMatchRequestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Solicitar Partido')),
      body: Center(
        child: Text('Pantalla de Solicitud de Partido', style: TextStyle(fontSize: 20)),
      ),
    );
  }
} 