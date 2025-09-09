import 'package:flutter/material.dart';

class Lumina extends StatefulWidget {
  final String assetPath;
  final Duration duracion;
  final double size; // Añade este parámetro

  const Lumina({
    super.key, 
    required this.assetPath, 
    required this.duracion,
    this.size = 100.0, // Valor por defecto de 100
  });

  @override
  State<Lumina> createState() => _LuminaState();
}

class _LuminaState extends State<Lumina> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacidad;
  late Animation<double> _escala;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duracion
    );
    
    _opacidad = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeInOut),
      )
    );
    
    _escala = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1, curve: Curves.easeOut),
      )
    );
    
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size, // Usa el tamaño proporcionado
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacidad.value,
            child: Transform.scale(
              scale: _escala.value,
              child: child,
            ),
          );
        },
        child: Image.asset(
          widget.assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const FlutterLogo(size: 100);
          },
        ),
      ),
    );
  }
}