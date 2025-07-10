import 'package:flutter/material.dart';
import 'package:login/widgets/grafico_embudo.dart';

class CardEmbudo extends StatelessWidget {
  final List<FunnelData>? cumplimientoLaboralData;
  const CardEmbudo({super.key,required this.cumplimientoLaboralData });

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
                Icon(Icons.bar_chart, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Análisis de Cumplimiento Laboral',
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
            cumplimientoLaboralData!.isNotEmpty
            ? GraficoEmbudo(data: cumplimientoLaboralData!)
            : const Text('No hay datos suficientes para mostrar el gráfico.'),
          ],
        ),
      ),
    );
  }
}