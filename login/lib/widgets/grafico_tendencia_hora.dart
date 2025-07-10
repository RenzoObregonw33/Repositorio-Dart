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
    // Filtrar solo las horas entre 08:00 y 18:00
    final dataFiltrada = data.where((d) {
      final partes = d.hora.split(':');
      final horaNum = int.tryParse(partes[0]) ?? -1;
      return horaNum >= 8 && horaNum <= 18;
    }).toList();

    // Si no hay datos útiles, no retorna nada
    if (dataFiltrada.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
        width: dataFiltrada.length * 60, // ancho proporcional a la cantidad de datos
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
                dataSource: dataFiltrada,
                xValueMapper: (TendenciaHoraData d, _) => d.hora,
                yValueMapper: (TendenciaHoraData d, _) => d.valor,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.top,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
        
      ),
    );
  }
}
