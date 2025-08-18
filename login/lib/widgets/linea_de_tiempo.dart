import 'package:flutter/material.dart';

class LineaTiempoWidget extends StatelessWidget {
  final List<dynamic> eventos;
  
  const LineaTiempoWidget({
    super.key,
    required this.eventos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        final evento = eventos[index];
        return _buildEventoLineaTiempo(evento);
      },
    );
  }

  Widget _buildEventoLineaTiempo(dynamic evento) {
    final porcentaje = double.tryParse(evento['division'].toString()) ?? 0.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1E2A38),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                '${evento['inicioA']} - ${evento['ultimaA']}',
                style: TextStyle(color: Colors.white),
              ),
              Spacer(),
              Chip(
                label: Text(
                  '${porcentaje.toStringAsFixed(1)}%',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: _getColorEficiencia(porcentaje),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            evento['nombre_actividad'],
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'inter'
            ),
          ),
          if (evento['imagen'] != null && evento['imagen'].isNotEmpty) ...[
            SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: evento['imagen'].length,
                itemBuilder: (context, index) {
                  final imagen = evento['imagen'][index];
                  return _buildImagenEvento(imagen);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagenEvento(dynamic imagen) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          'https://rhnube.com.pe${imagen['miniatura']}',
          width: 100,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 100,
              height: 100,
              color: Colors.grey[800],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / 
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100,
              height: 100,
              color: Colors.grey[800],
              child: Icon(Icons.error, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  Color _getColorEficiencia(double eficiencia) {
    if (eficiencia >= 50) return Color(0xFF2BCA07);
    if (eficiencia >= 30) return Colors.orange;
    return Color(0xFFFF1A15);
  }
}