import 'package:flutter/material.dart';
import 'package:login/widgets/grafico_tendencia_hora.dart';

class CardTendenciaHora extends StatelessWidget {
  final List<TendenciaHoraData>?  tendenciaHoras;
  const CardTendenciaHora({super.key,required this.tendenciaHoras});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tendencia de Actividad por Hora',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GraficoTendenciaHoras(data: tendenciaHoras!),
          ],
        ),
      ),
    );
  }
}