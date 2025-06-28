import 'package:flutter/material.dart';

class ViewBookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Reservas')),
      body: Center(
        child: Text('Pantalla de Mis Reservas', style: TextStyle(fontSize: 20)),
      ),
    );
  }
} 