import 'package:flutter/material.dart';

class HomeScreem extends StatelessWidget {
  final String username;

  const HomeScreem({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido')),
      body: Center(
        child: Text('Hola, $username', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}