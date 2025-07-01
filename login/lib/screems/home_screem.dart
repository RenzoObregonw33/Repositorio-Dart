import 'package:flutter/material.dart';

class HomeScreem extends StatelessWidget {
  final String nombre;
  final String apellido;
  final String ruc;

  const HomeScreem({super.key, required this.nombre, required this.apellido, required this.ruc});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, 'logout');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context, 'logout');
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Hola, $nombre $apellido $ruc',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}