import 'package:flutter/material.dart';
import 'package:login/widgets/grafico_embudo.dart';

class CardEmbudo extends StatelessWidget {
  final List<FunnelData>? cumplimientoLaboralData;
  final bool isLoading;
  const CardEmbudo({super.key,required this.cumplimientoLaboralData, required this.isLoading });

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
            Center(
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(),
                    )
                  : (cumplimientoLaboralData == null || cumplimientoLaboralData!.isEmpty)
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text('Seleccione fechas para ver el gráfico.'),
                        )
                      : GraficoEmbudo(data: cumplimientoLaboralData!),
            ),
          ],
        ),
      ),
    );
  }
}