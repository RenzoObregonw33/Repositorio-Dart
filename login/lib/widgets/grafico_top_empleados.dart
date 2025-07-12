import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TopEmpleadoData {
  final String nombre;
  final double actividadPositiva;
  final double actividadNegativa;

  TopEmpleadoData({
    required this.nombre,
    required this.actividadPositiva,
    required this.actividadNegativa,
  });
}

class GraficoTopEmpleados extends StatelessWidget {
  final List<TopEmpleadoData> data;

  const GraficoTopEmpleados({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '📊 Top empleados con más y menos actividad',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.square, color: Colors.green),
            SizedBox(width: 4),
            Text('Actividad positiva'),
            SizedBox(width: 16),
            Icon(Icons.square, color: Colors.redAccent),
            SizedBox(width: 4),
            Text('Actividad negativa'),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: data.length * 40 + 80,
            width: 600,
            child: BarChart(
              BarChartData(
                maxY: 100,
                minY: -100,
                groupsSpace: 12,
                barTouchData: BarTouchData(enabled: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: value == 0 ? Colors.black : Colors.grey[300]!,
                      strokeWidth: value == 0 ? 2 : 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 50,
                      getTitlesWidget: (value, _) => Text('${value.toInt()}%'),
                    ),
                  ),
                ),
                barGroups: List.generate(data.length, (i) {
                  final empleado = data[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: -empleado.actividadNegativa,
                        fromY: 0,
                        width: 10,
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: empleado.actividadPositiva,
                        fromY: 0,
                        width: 10,
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Etiquetas de nombres
        Column(
          children: List.generate(data.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
              child: Row(
                children: [
                  Text(
                    data[i].nombre,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
