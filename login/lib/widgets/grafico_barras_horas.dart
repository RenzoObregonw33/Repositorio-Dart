import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HorasData {
  final String tipo;
  final double horas;
  final Color color;

  HorasData(this.tipo, this.horas, this.color);
}

class GraficoBarrasHoras extends StatelessWidget {
  final double programadas;
  final double presencia;
  final double productivas;

  const GraficoBarrasHoras({
    super.key,
    required this.programadas,
    required this.presencia,
    required this.productivas,
  });

  @override
  Widget build(BuildContext context) {
    final List<HorasData> data = [
      HorasData('H. programadas', programadas, const Color(0xFF0868FB)),
      HorasData('H. de presencia', presencia, const Color(0xFF2DC70D)),
      HorasData('H. productivas', productivas, const Color(0xFFFF1A15)),
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
        child: SizedBox(
          height: 280,
          child: Column(
            children: [
              // Título con icono (igual que en eficiencia)
              const Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.blueAccent),
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
              const SizedBox(height: 8),
              
              // Gráfico de barras (contenido original sin modificar)
              Expanded(
                child: SfCartesianChart(
                  backgroundColor: const Color(0xFF1E293B),
                  primaryXAxis: CategoryAxis(
                    isVisible: true,
                    labelStyle: const TextStyle(color: Colors.white70),
                    axisLine: const AxisLine(color: Colors.white54),
                    majorTickLines: const MajorTickLines(color: Colors.white54),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    labelStyle: const TextStyle(color: Colors.white70),
                    axisLine: const AxisLine(color: Colors.white54),
                    majorTickLines: const MajorTickLines(color: Colors.white54),
                    title: AxisTitle(
                      text: 'Horas',
                      textStyle: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: Colors.blueGrey[800],
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  series: <BarSeries<HorasData, String>>[
                    BarSeries<HorasData, String>(
                      dataSource: data,
                      xValueMapper: (HorasData d, _) => d.tipo,
                      yValueMapper: (HorasData d, _) => d.horas,
                      pointColorMapper: (HorasData d, _) => d.color,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(0),
                        right: Radius.circular(18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}