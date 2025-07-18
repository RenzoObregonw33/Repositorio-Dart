import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class DonutData{
  final String categoria;
  final double valor;
  final Color color;

  DonutData(this.categoria, this.valor, this.color);
}

class GraficoDonut extends StatelessWidget {

  final double productivas;
  final double noProductivas;
  const GraficoDonut({super.key, required this.productivas, required this.noProductivas});

  @override
  Widget build(BuildContext context) {
    final total = productivas + noProductivas;
    final data = [
      DonutData('Horas productivas', productivas, Color(0xFFC909F7)),
      DonutData('Horas no productivas', noProductivas, Color(0xFF0868FB)),
    ];
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.top,
      ),
      series: <CircularSeries<DonutData, String>>[
        DoughnutSeries<DonutData, String>(
          dataSource: data,
          xValueMapper: (DonutData d, _) => d.categoria,
          yValueMapper: (DonutData d, _) => d.valor,
          pointColorMapper: (DonutData d, _) => d.color,
          dataLabelMapper: (DonutData d, _) =>
              '${((d.valor / total) * 100).toStringAsFixed(2)}%',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          radius: '80%',
          innerRadius: '65%',
        ),
      ],
    );
  }
}