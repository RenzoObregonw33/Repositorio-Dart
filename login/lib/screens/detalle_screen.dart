import 'package:flutter/material.dart';

class DetalleScreen extends StatelessWidget {
  const DetalleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8EB),
      body: Center(
        child: Text(
          'Detalles diarios 💡',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
