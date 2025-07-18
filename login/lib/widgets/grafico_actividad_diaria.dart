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
    final double maxY =
        data.map((e) => e.porcentaje).reduce((a, b) => a > b ? a : b) + 10;

    // Determinar el ancho mínimo (por si hay muy pocos días)
    final double chartWidth = (data.length * 80).clamp(240, 600).toDouble();


    // Título dinámico
    final String titulo = data.length >= 7
        ? '% Actividad diaria (últimos 7 días)'
        : '% Actividad diaria seleccionada';

    //colores
    final List<Color> colores = [
      Color(0xFF0868FB), // Azul
      Color(0xFF2DC70D), // Verde
      Color(0xFFFF1A15), // Rojo
      Colors.brown, // Marrón
      Colors.purple, // Morado
      Colors.orange, // Naranja
      Colors.pink, // Rosa
      Colors.teal, // Verde azulado
      Colors.indigo, // Índigo
      Colors.amber, // Ámbar
      Colors.cyan, // Cian
    ];

    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: chartWidth,
          child: SfCartesianChart(
            title: ChartTitle(text: titulo, textStyle: TextStyle(color: Colors.white)),
            primaryXAxis: CategoryAxis(                             //EJE X
              labelStyle: TextStyle(color: Colors.white),
            ),
            primaryYAxis: NumericAxis(                              //EJE Y
              minimum: 0,
              maximum: maxY > 100 ? 100 : maxY,
              interval: 20,
              labelFormat: '{value} %',
              labelStyle: TextStyle(color: Colors.white),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: esLinea
                ? <LineSeries<ActividadDiariaData, String>>[
                    LineSeries<ActividadDiariaData, String>(
                      dataSource: data,
                      xValueMapper: (d, _) => d.dia,
                      yValueMapper: (d, _) => d.porcentaje,
                      markerSettings: const MarkerSettings(isVisible: true, width: 10, height: 10),
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.top,
                        textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      pointColorMapper: (ActividadDiariaData d, int index) {
                        // Asignar colores cíclicamente
                        return colores[index % colores.length];
                      },
                      
                    )
                  ]
                : <ColumnSeries<ActividadDiariaData, String>>[
                    ColumnSeries<ActividadDiariaData, String>(
                      dataSource: data,
                      xValueMapper: (d, _) => d.dia,
                      yValueMapper: (d, _) => d.porcentaje,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.top,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      pointColorMapper: (ActividadDiariaData d, int index) {
                        // Asignar colores cíclicamente
                        return colores[index % colores.length];
                      },
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20))  ,
                    )
                  ],
          ),
        ),
      ),
    );
  }
}
