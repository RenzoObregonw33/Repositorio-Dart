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
      HorasData('Horas programadas', programadas, Color(0xFF0868FB)),
      HorasData('Horas de presencia', presencia, Color(0xFF2DC70D)),
      HorasData('Horas productivas', productivas, Color(0xFFFF1A15)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔼 Leyenda arriba del gráfico
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: data.map((d) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 12, color: d.color),
                const SizedBox(width: 6),
                Text(d.tipo, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // 📊 Gráfico de barras
        SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(isVisible: false),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'Horas'),
              minimum: 0,
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <BarSeries<HorasData, String>>[
              BarSeries<HorasData, String>(
                dataSource: data,
                xValueMapper: (HorasData d, _) => d.tipo,
                yValueMapper: (HorasData d, _) => d.horas,
                pointColorMapper: (HorasData d, _) => d.color,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(0), right: Radius.circular(18)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
