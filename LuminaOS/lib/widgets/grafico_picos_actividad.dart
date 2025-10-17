import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'safe_chart_wrapper.dart';

class HoraActividadData {
  final String hora;
  final double valor;

  HoraActividadData({
    required this.hora,
    required this.valor,
  });
}

class GraficoPicosActividad extends StatelessWidget {
  final List<String> labels;
  final List<double> valores;

  const GraficoPicosActividad({
    super.key, 
    required this.labels, 
    required this.valores
  });

  @override
  Widget build(BuildContext context) {
    // Paleta de colores vibrantes
    final List<Color> colorPalette = [
      Color(0xFF3E2B6B),
      Color(0xFF64D9C5),
    ];

    // Filtrar datos para mostrar solo de 8:00 a 18:00
    List<HoraActividadData> filteredData = List.generate(
      labels.length,
      (index) => HoraActividadData(hora: labels[index], valor: valores[index]),
    ).where((data) {
      int hour = int.parse(data.hora.split(':')[0]);
      return hour >= 8 && hour <= 18;
    }).toList();

    return SafeChartWrapper(
      debugLabel: 'GraficoPicosActividad',
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFFF8F7FC),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300, // Misma altura que el gráfico de eficiencia
          child: Column(
            children: [
              // Título adaptado al estilo del otro gráfico
              const Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: Color(0xFF3E2B6B)),
                  SizedBox(width: 8),
                  Text(
                    'Analisis de Picos de Actividad',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Gráfico usando Expanded como en el otro widget
              Expanded(
                child: SfCartesianChart(
                  margin: EdgeInsets.zero,
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    labelRotation: -45,
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 1.5, color: Colors.white54),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    axisLine: const AxisLine(width: 1.5, color: Colors.white54),
                    majorGridLines: MajorGridLines(
                      width: 1,
                      color: Colors.grey[100],
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    header: 'Actividad',
                    format: 'point.x\npoint.y hrs',
                    color: Colors.blueGrey[800],
                    textStyle: const TextStyle(color: Colors.white),
                    borderWidth: 0,
                  ),
                  series: <CartesianSeries>[
                    ColumnSeries<HoraActividadData, String>(
                      dataSource: filteredData, 
                      xValueMapper: (d, _) => d.hora,
                      yValueMapper: (d, _) => d.valor,
                      name: 'Actividad',
                      pointColorMapper: (HoraActividadData d, int index) {
                        return colorPalette[index % colorPalette.length];
                      },     
                      width: 0.9,
                      spacing: 0.2,
                      borderWidth: 1,
                      animationDuration: 0, // Deshabilitar animaciones para evitar dispose errors
                      enableTooltip: true,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        labelAlignment: ChartDataLabelAlignment.outer,
                        // Añade esta propiedad para formatear con 1 decimal
                        builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                          return Text(
                            '${point.y.toStringAsFixed(1)}', // Muestra con 1 decimal
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      )
    ); // Cierre de SafeChartWrapper
  }
}