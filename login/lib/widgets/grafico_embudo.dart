import 'package:flutter/material.dart';
import 'package:login/Models/datos_embudo.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraficoEmbudo extends StatelessWidget {
  final List<FunnelData> data;

  const GraficoEmbudo({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título con icono
            const Row(
              children: [
                Icon(Icons.filter_alt, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  'CUMPLIMIENTO LABORAL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Gráfico de embudo
            Expanded(
              child: SfFunnelChart(
                tooltipBehavior: TooltipBehavior(enable: true),
                series: FunnelSeries<FunnelData, String>(
                  dataSource: data,
                  xValueMapper: (FunnelData d, _) => d.label,
                  yValueMapper: (FunnelData d, _) => d.value,
                  pointColorMapper: (FunnelData d, _) => d.color,
                  gapRatio: 0.2,
                  neckWidth: '20%',
                  neckHeight: '15%',
                  explode: true,
                  explodeOffset: '5%',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.inside,
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}