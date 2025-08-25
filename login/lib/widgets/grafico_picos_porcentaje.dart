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
      const Color(0xFF0868FB), // Azul
      const Color(0xFF2DC70D), // Verde
      const Color(0xFFFF1A15), // Rojo
      const Color(0xFF7AD6D5), // Cian
      const Color(0xFFDC32F3), // Morado
      const Color(0xFFFE9717), // Naranja
      const Color(0xFFFFA2CD), // Rosa
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
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              // Título con icono (idéntico a tu versión)
              const Row(
                children: [
                  Icon(Icons.pie_chart, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    'ACTIVIDAD POR HORA (%)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                    axisLine: const AxisLine(width: 1.5, color: Colors.blueGrey),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: 100, // Máximo 100% para porcentajes
                    interval: 20,
                    axisLine: const AxisLine(width: 1.5, color: Colors.blueGrey),
                    majorGridLines: MajorGridLines(
                      width: 1,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.white,
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      width: 0.7,
                      spacing: 0.2,
                      borderWidth: 1,
                      animationDuration: 2000,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        labelAlignment: ChartDataLabelAlignment.top,
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