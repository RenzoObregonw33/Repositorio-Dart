import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficoDiarioExtend extends StatelessWidget {
  final Map<String, dynamic> graficoData;
  const GraficoDiarioExtend({super.key, required this.graficoData});

  // Calcula el valor máximo del eje Y basado en los datos
  double _calculateMaxY(List<dynamic> values) {
    final doubles = values.map((v) => double.parse(v.toString())).toList();
    final maxValue = doubles.reduce((a, b) => a > b ? a : b);
    return (maxValue / 10).ceil() * 10 + 10;
  }

  // Calcula el intervalo entre líneas de la cuadrícula del eje Y
  double _calculateInterval(List<dynamic> values) {
    final maxY = _calculateMaxY(values);
    if (maxY <= 30) return 5;
    if (maxY <= 60) return 10;
    return 20;
  }

  // Función para formatear el label (divide en dos líneas)
  Widget _buildFormattedLabel(String label) {
    final parts = label.split(' ');
    if (parts.length >= 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            parts[0],
            style: TextStyle(
              color: Colors.black,
              fontSize: 9, // Reducido de 10 a 9
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1), // Reducido de 2 a 1
          Text(
            parts[1],
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontSize: 8, // Reducido de 9 a 8
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    return Text(
      label,
      style: TextStyle(
        color: Colors.black,
        fontSize: 9, // Reducido de 10 a 9
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    final grafico = graficoData['actividad_ultimos_dias'];
    
    return Container(
      padding: EdgeInsets.all(10), // Reducido de 12 a 10
      decoration: BoxDecoration(
        color: Color(0xFFF8F7FC),
        borderRadius: BorderRadius.circular(12),
      ),
      height: 310, // Ajustado de 320 a 310
      child: Column(
        mainAxisSize: MainAxisSize.min, // Añadido para evitar overflow
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del gráfico
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0), // Reducido de 8 a 6
            child: Center(
              child: Text(
                "% Porcentaje de Actividad Diaria",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15, // Reducido de 16 a 15
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          SizedBox(height: 8), // Reducido de 10 a 8
          
          // Gráfico de líneas
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (grafico['labels'].length - 1).toDouble(),
                minY: 0,
                maxY: _calculateMaxY(grafico['series']['Total']),
                
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9, // Reducido de 10 a 9
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        );
                      },
                      reservedSize: 35, // Reducido de 40 a 35
                      interval: _calculateInterval(grafico['series']['Total']),
                    ),
                  ),
                  
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < grafico['labels'].length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 2.0), // Reducido de 4 a 2
                            child: _buildFormattedLabel(grafico['labels'][index].toString()),
                          );
                        }
                        return SizedBox.shrink();
                      },
                      interval: 1,
                      reservedSize: 28, // Reducido de 32 a 28
                    ),
                  ),
                ),
                
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      grafico['labels'].length,
                      (i) => FlSpot(
                        i.toDouble(),
                        double.parse(grafico['series']['Total'][i].toString())
                      ),
                    ),
                    isCurved: true,
                    color: Color(0xFF3E2B6B),
                    barWidth: 3, // Reducido de 4 a 3
                    isStrokeCapRound: true,
                    
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3, // Reducido de 4 a 3
                          color: Color(0xFF64D9C5),
                          strokeWidth: 1.5, // Reducido de 2 a 1.5
                          strokeColor: Color(0xFF3E2B6B),
                        );
                      },
                    ),
                    
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF3E2B6B).withOpacity(0.3),
                          Color(0xFF3E2B6B).withOpacity(0.1),
                        ],
                      ),
                    ),
                    
                    shadow: Shadow(
                      color: Color(0xFF3E2B6B).withOpacity(0.5),
                      blurRadius: 6, // Reducido de 8 a 6
                      offset: Offset(0, 3), // Reducido de 5 a 3
                    ),
                  ),
                ],
                
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Color(0xFF0F2747),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}%',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}