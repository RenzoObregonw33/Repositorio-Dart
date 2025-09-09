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
      idEmpleado: json['idEmpleado'] ?? 0,
      nombre: json['nombre'] ?? '',
      apPaterno: json['apPaterno'] ?? '',
      apMaterno: json['apMaterno'] ?? '',
      nombreActividad: json['nombre_actividad'] ?? '',
      tiempoT: json['tiempoT'] ?? 0,
      division: json['division']?.toString() ?? '0.00',
      ultimaA: json['ultimaA'] ?? '',
      inicioA: json['inicioA'] ?? '',
      totalActividad: json['totalActividad'] ?? 0,
      imagenes: (json['imagen'] as List<dynamic>?)
          ?.map((i) => Imagen.fromJson(i))
          .toList() ?? [],
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
      idImagen: json['idImagen'] ?? 0,
      miniatura: json['miniatura'] ?? '',
      imagenGrande: json['imagen_grande'] ?? '',
    );
  }
}

enum ItemPosition { left, right }

class EnhancedChainTimelinePainter extends CustomPainter {
  final int itemCount;
  final double itemHeight;

  EnhancedChainTimelinePainter({
    required this.itemCount,
    required this.itemHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double centerX = 200.0;
    const double curveIntensity = 200.0;

    for (int i = 0; i < itemCount - 1; i++) {
      final double y = i * itemHeight + itemHeight / 2;
      final double nextY = (i + 1) * itemHeight + itemHeight / 2;
      
      final gradient = LinearGradient(
        colors: [
          Colors.blueAccent.withOpacity(0.8),
          const Color(0xFF1F3A5F).withOpacity(0.8),
          Colors.blue.withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      
      paint.shader = gradient.createShader(
        Rect.fromLTWH(0, y, size.width, nextY - y),
      );
      
      final path = Path();
      path.moveTo(centerX, y);
      
      if (i % 2 == 0) {
        path.cubicTo(
          centerX + curveIntensity, y + (nextY - y) * 0.01,
          centerX + curveIntensity, y + (nextY - y) * 1,
          centerX, nextY,
        );
      } else {
        path.cubicTo(
          centerX - curveIntensity, y + (nextY - y) * 0.01,
          centerX - curveIntensity, y + (nextY - y) * 1,
          centerX, nextY,
        );
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}