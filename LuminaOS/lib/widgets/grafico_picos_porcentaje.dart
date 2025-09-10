import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HoraActividadPorcentajeData {
  final String hora;
  final double porcentaje;

  HoraActividadPorcentajeData({
    required this.hora,
    required this.porcentaje,
  });
}

class GraficoPicosPorcentaje extends StatelessWidget {
  final List<HoraActividadPorcentajeData> datos;

  const GraficoPicosPorcentaje({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    // Paleta de colores original (igual que tu versión)
    final List<Color> colorPalette = [
      Color(0xFF3E2B6B),
      Color(0xFF64D9C5),
    ];

    // Filtramos solo horas de 8:00 a 18:00 como en tu versión original
    final filteredData = datos.where((data) {
      final hour = int.parse(data.hora.split(':')[0]);
      return hour >= 8 && hour <= 18;
    }).toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFF8F7FC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              // Título con icono (idéntico a tu versión)
              const Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: Color(0xFF3E2B6B)),
                  SizedBox(width: 8),
                  Text(
                    'Analisis de Picos de Actividad (%)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Gráfico (configuración original sin cambios)
              Expanded(
                child: SfCartesianChart(
                  margin: EdgeInsets.zero,
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    labelRotation: -45,
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 1.5, color: Colors.white54),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: 100, // Máximo 100% para porcentajes
                    interval: 20,
                    axisLine: const AxisLine(width: 1.5, color: Colors.white54),
                    majorGridLines: MajorGridLines(
                      width: 1,
                      color: Colors.grey[100],
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    header: 'Porcentaje',
                    format: 'point.x\npoint.y%',
                    color: Colors.blueGrey[800],
                    textStyle: const TextStyle(color: Colors.white),
                    borderWidth: 0,
                  ),
                  series: <CartesianSeries>[
                    ColumnSeries<HoraActividadPorcentajeData, String>(
                      dataSource: filteredData,
                      xValueMapper: (d, _) => d.hora,
                      yValueMapper: (d, _) => d.porcentaje,
                      pointColorMapper: (d, index) => 
                          colorPalette[index % colorPalette.length],       
                      width: 0.8,
                      spacing: 0.2,
                      borderWidth: 1,
                      animationDuration: 2000,
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
    );
  }
}