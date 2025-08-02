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
    // Paleta de colores vibrantes (misma que en GraficoPicosActividad)
    final List<Color> colorPalette = [
      const Color(0xFF0868FB), // Azul
      const Color(0xFF2DC70D), // Verde
      const Color(0xFFFF1A15), // Rojo
      const Color(0xFF7AD6D5), // Cian
      const Color(0xFFDC32F3), // Morado
      const Color(0xFFFE9717), // Naranja
      const Color(0xFFFFA2CD), // Rosa
    ];

    // Filtrar datos para mostrar solo de 8:00 a 18:00
    final filteredData = datos.where((data) {
      final hour = int.parse(data.hora.split(':')[0]);
      return hour >= 8 && hour <= 18;
    }).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 Picos de Actividad por Hora (%)',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24), // Espacio consistente
              SizedBox(
                height: 300, // Mismo tamaño que el otro gráfico
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    labelRotation: -45,
                    title: AxisTitle(
                      text: 'Horario del día (8:00-18:00)',
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 1.5, color: Colors.blueGrey),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(
                      text: 'Porcentaje de actividad',
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    minimum: 0,
                    maximum: 100,
                    interval: 20,
                    axisLine: const AxisLine(width: 1.5, color: Colors.blueGrey),
                    majorGridLines: MajorGridLines(
                      width: 1,
                      color: Colors.grey.withOpacity(0.3),
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
                      name: 'Porcentaje',
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
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        labelAlignment: ChartDataLabelAlignment.top,
                      ),
                    )
                  ],
                ),
              ),
              // Se eliminó la leyenda como solicitaste
            ],
          ),
        ),
      ),
    );
  }
}