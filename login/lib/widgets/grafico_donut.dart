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
      DonutData('Horas productivas', productivas, const Color(0xFFC4DEF9)),
      DonutData('Horas no productivas', noProductivas, const Color(0xFF64D9C5)),
    ];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFF8F7FC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título con icono
            const Row(
              children: [
                Icon(Icons.pie_chart, color: Color(0xFF3E2B6B)),
                SizedBox(width: 8),
                Text(
                  'DISTRIBUCIÓN DE HORAS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
                  textStyle: const TextStyle(color: Colors.black),
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
                      overflowMode: OverflowMode.shift,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      connectorLineSettings: ConnectorLineSettings(
                        length: '5%',
                        type: ConnectorType.curve,
                        color: Colors.black,
                      ),
                    ),
                    radius: '65%',
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