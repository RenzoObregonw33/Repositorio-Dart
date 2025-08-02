import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
      Color(0xFF0868FB), // Azul
      Color(0xFF2DC70D), // Verde
      Color(0xFFFF1A15), // Rojo
      Color(0xFF7AD6D5), // Cian
      Color(0xFFDC32F3), // Morado
      Color(0xFFFE9717), // Naranja
      Color(0xFFFFA2CD), // Rosa
    ];

    // Filtrar datos para mostrar solo de 8:00 a 18:00
    List<HoraActividadData> filteredData = List.generate(
      labels.length,
      (index) => HoraActividadData(hora: labels[index], valor: valores[index]),
    ).where((data) {
      // Extraer la hora como número entero (ej: "08:00" → 8)
      int hour = int.parse(data.hora.split(':')[0]);
      return hour >= 8 && hour <= 18; // Solo horas entre 8 y 18
    }).toList();

    return Container(
      margin: const EdgeInsets.all(16), // Margen movido aquí
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
                '📊 Picos de Actividad por Hora',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(
                    labelRotation: -45,
                    title: AxisTitle(
                      text: 'Horario del día',
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 1.5, color: Colors.blueGrey),
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(
                      text: 'Horas de actividad',
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    axisLine: const AxisLine(width: 1.5, color: Colors.blueGrey),
                    majorGridLines: MajorGridLines(
                      width: 1,
                      color: Colors.grey[200]!,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.white,
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
                        return colorPalette[index % colorPalette.length].withOpacity(0.9); // Más opacidad
                      },
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      width: 0.7,
                      spacing: 0.2,
                      borderWidth: 1,
                      //borderColor: Colors.white, Borde blanco para mejor contraste
                      animationDuration: 2000,
                      enableTooltip: true,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          color: Colors.black, // Texto negro para mejor legibilidad
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        labelAlignment: ChartDataLabelAlignment.top,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: List.generate(
                  colorPalette.length,
                  (index) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorPalette[index],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Nivel ${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}