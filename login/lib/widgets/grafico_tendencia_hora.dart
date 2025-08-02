import 'dart:math';

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
    // Verificar si hay datos válidos (mayores a 0)
    final hasValidData = data.isNotEmpty && data.any((d) => d.valor > 0);

    if (!hasValidData) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bar_chart, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                data.isEmpty ? 'No hay datos disponibles' : 'Todos los valores son cero',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelRotation: -45,
          labelStyle: const TextStyle(fontSize: 10),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: data.map((e) => e.valor).reduce(max) * 1.2,
        ),
        series: <CartesianSeries<TendenciaHoraData, String>>[
          ColumnSeries<TendenciaHoraData, String>(
            dataSource: data,
            xValueMapper: (d, _) => d.hora,
            yValueMapper: (d, _) => d.valor,
            color: Colors.blue[400],
            width: 0.6,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.top,
              textStyle: TextStyle(fontSize: 10),
            ),
          ),
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x : point.y hrs',
        ),
      ),
    );
  }
}