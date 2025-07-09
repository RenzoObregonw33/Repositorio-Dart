// ✅ FILE: widgets/grafico_barras_horas.dart

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
      HorasData('Horas programadas', programadas, const Color(0xFF4D68E6)),
      HorasData('Horas de presencia', presencia, const Color(0xFF92D384)),
      HorasData('Horas productivas', productivas, const Color(0xFFF3B644)),
    ];

    return SfCartesianChart(
      title: ChartTitle(text: 'Horas Programadas', 
        textStyle: TextStyle(
          fontSize: 12,
          )
      ),
      primaryXAxis: CategoryAxis(), // ← este debe ser Category
      primaryYAxis: NumericAxis(     // ← este debe ser Numeric
        title: AxisTitle(text: 'Horas'),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
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
        )
      ],
    );
  }
}
