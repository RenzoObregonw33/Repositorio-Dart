import 'package:flutter/material.dart';

class TimelineItem {
  final int idEmpleado;
  final String nombre;
  final String apPaterno;
  final String apMaterno;
  final String nombreActividad;
  final int tiempoT;
  final String division;
  final String ultimaA;
  final String inicioA;
  final int totalActividad;
  final List<Imagen> imagenes;
  final Color color;

  TimelineItem({
    required this.idEmpleado,
    required this.nombre,
    required this.apPaterno,
    required this.apMaterno,
    required this.nombreActividad,
    required this.tiempoT,
    required this.division,
    required this.ultimaA,
    required this.inicioA,
    required this.totalActividad,
    required this.imagenes,
    required this.color,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      idEmpleado: json['idEmpleado'],
      nombre: json['nombre'],
      apPaterno: json['apPaterno'],
      apMaterno: json['apMaterno'],
      nombreActividad: json['nombre_actividad'],
      tiempoT: json['tiempoT'],
      division: json['division'],
      ultimaA: json['ultimaA'],
      inicioA: json['inicioA'],
      totalActividad: json['totalActividad'],
      imagenes: (json['imagen'] as List).map((i) => Imagen.fromJson(i)).toList(),
      color: _getRandomColor(),
    );
  }

  static Color _getRandomColor() {
    final colors = [
      Colors.blueAccent,
      Colors.blue,
      Colors.lightBlue,
      Colors.blueGrey,
    ];
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }
}

class Imagen {
  final int idImagen;
  final String miniatura;
  final String imagenGrande;

  Imagen({
    required this.idImagen,
    required this.miniatura,
    required this.imagenGrande,
  });

  factory Imagen.fromJson(Map<String, dynamic> json) {
    return Imagen(
      idImagen: json['idImagen'],
      miniatura: json['miniatura'],
      imagenGrande: json['imagen_grande'],
    );
  }
}