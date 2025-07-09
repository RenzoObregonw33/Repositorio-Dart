// ✅ FILE: widgets/grafico_tendencia_horas.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TendenciaHoraData {
  final String hora;
  final double valor;

  TendenciaHoraData(this.hora, this.valor);
}

class GraficoTendenciaHoras extends StatelessWidget {
  final List<TendenciaHoraData> data;

  const GraficoTendenciaHoras({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: SfCartesianChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Tiempo de actividad (horas)'),
          minimum: 0,
        ),
        series: <ColumnSeries<TendenciaHoraData, String>>[
          ColumnSeries<TendenciaHoraData, String>(
            dataSource: data,
            xValueMapper: (TendenciaHoraData d, _) => d.hora,
            yValueMapper: (TendenciaHoraData d, _) => d.valor,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.top,
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            color: Colors.blueAccent,
          ),
        ]
      ),
    );
  }
}
