import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DonutData {
  final String categoria;
  final double valor;
  final Color color;

  DonutData(this.categoria, this.valor, this.color);
}

class GraficoDonut extends StatelessWidget {
  final double productivas;
  final double noProductivas;
  
  const GraficoDonut({
    super.key, 
    required this.productivas, 
    required this.noProductivas
  });

  @override
  Widget build(BuildContext context) {
    final total = productivas + noProductivas;
    final data = [
      DonutData('Horas productivas', productivas, const Color(0xFFC909F7)),
      DonutData('Horas no productivas', noProductivas, const Color(0xFF0868FB)),
    ];

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
                Icon(Icons.pie_chart, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  'DISTRIBUCIÓN DE HORAS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Gráfico Donut
            Expanded(
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                  position: LegendPosition.bottom,
                  textStyle: const TextStyle(color: Colors.white),
                ),
                series: <CircularSeries<DonutData, String>>[
                  DoughnutSeries<DonutData, String>(
                    dataSource: data,
                    xValueMapper: (DonutData d, _) => d.categoria,
                    yValueMapper: (DonutData d, _) => d.valor,
                    pointColorMapper: (DonutData d, _) => d.color,
                    dataLabelMapper: (DonutData d, _) => 
                        '${((d.valor / total) * 100).toStringAsFixed(1)}%',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      connectorLineSettings: ConnectorLineSettings(
                        length: '20%',
                        type: ConnectorType.curve,
                        color: Colors.white54,
                      ),
                    ),
                    radius: '75%',
                    innerRadius: '60%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}