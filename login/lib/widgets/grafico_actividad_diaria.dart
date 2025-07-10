// ✅ FILE: widgets/grafico_actividad_diaria.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActividadDiariaData {
  final String dia;
  final double porcentaje;

  ActividadDiariaData(this.dia, this.porcentaje);
}

class GraficoActividadDiaria extends StatelessWidget {
  final List<ActividadDiariaData> data;
  final bool esLinea;

  const GraficoActividadDiaria({super.key, required this.data, required this.esLinea});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: '% Actividad diaria (últimos 7 días)'),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 100,
        interval: 20,
        labelFormat: '{value} %',
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: esLinea
          ? <LineSeries<ActividadDiariaData, String>>[
              LineSeries<ActividadDiariaData, String>(
                dataSource: data,
                xValueMapper: (d, _) => d.dia,
                yValueMapper: (d, _) => d.porcentaje,
                markerSettings: const MarkerSettings(isVisible: true),
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                color: Colors.blue,
              )
            ]
          : <ColumnSeries<ActividadDiariaData, String>>[
              ColumnSeries<ActividadDiariaData, String>(
                dataSource: data,
                xValueMapper: (d, _) => d.dia,
                yValueMapper: (d, _) => d.porcentaje,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                color: Colors.blue,
              )
            ],
    );
  }
}
