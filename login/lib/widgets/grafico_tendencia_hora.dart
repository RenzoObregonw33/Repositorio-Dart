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

    final List<Color> colores = [
      Color(0xFF0868FB), // Azul
      Color(0xFF2DC70D), // Verde
      Color(0xFFFF1A15), // Rojo
      Color(0xFF7AD6D5), // Cian
      Color(0xFFDC32F3), // Morado
      Color(0xFFFE9717), // Naranja
      Color(0xFFFFA2CD), // Rosa
      Colors.teal, // Verde azulado
      Colors.indigo, // Índigo
      Color(0xFFFDF807), // Ámbar
      Colors.brown, // Marron
    ];
    return SizedBox(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
        width: dataFiltrada.length * 30, // ancho proporcional a la cantidad de datos
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
                  //textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                pointColorMapper: (TendenciaHoraData d, int index) {
                  // Asignar colores cíclicamente
                  return colores[index % colores.length];
                },
                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
        ),
        
      ),
    );
  }
}
