import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficoDiarioExtend extends StatelessWidget {
  final Map<String, dynamic> graficoData;
  const GraficoDiarioExtend({super.key, required this.graficoData});

  // Calcula el valor máximo del eje Y basado en los datos
  double _calculateMaxY(List<dynamic> values) {
    final doubles = values.map((v) => double.parse(v.toString())).toList();
    final maxValue = doubles.reduce((a, b) => a > b ? a : b);
    // Redondea al siguiente múltiplo de 10 para tener un buen margen
    return (maxValue / 10).ceil() * 10 + 10;
  }

  // Calcula el intervalo entre líneas de la cuadrícula del eje Y
  double _calculateInterval(List<dynamic> values) {
    final maxY = _calculateMaxY(values);
    if (maxY <= 30) return 5;  // Intervalo pequeño para valores bajos
    if (maxY <= 60) return 10; // Intervalo medio
    return 20;                 // Intervalo grande para valores altos
  }

  @override
  Widget build(BuildContext context) {
    // Extrae los datos específicos del gráfico de la estructura principal
    final grafico = graficoData['actividad_ultimos_dias'];
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1E2A38), // Fondo oscuro para el contenedor
        borderRadius: BorderRadius.circular(12), // Bordes redondeados
      ),
      height: 300, // Altura fija para el contenedor del gráfico
      child: Column(
        children: [
          // Título del gráfico
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_rounded, // Ícono que prefieras
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8), // Espacio entre ícono y texto
                Text(
                  "% Porcentaje de Actividad Diaria",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
           // Espacio entre título y gráfico

          SizedBox(height: 10), // Espacio entre el título y el gráfico
          // Gráfico de líneas
          Expanded(
            child: LineChart(
              LineChartData(
                // Configuración de los ejes X e Y
                minX: 0, // Valor mínimo del eje X (primer punto)
                maxX: (grafico['labels'].length - 1).toDouble(), // Valor máximo basado en cantidad de labels
                minY: 0, // Valor mínimo del eje Y
                maxY: _calculateMaxY(grafico['series']['Total']), // Valor máximo calculado
                
                // Configuración de la cuadrícula
                gridData: FlGridData(
                  show: true, // Muestra la cuadrícula
                  drawVerticalLine: false, // Oculta líneas verticales
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1), // Líneas tenues
                      strokeWidth: 1,
                    );
                  },
                ),
                
                // Configuración de los títulos de los ejes
                titlesData: FlTitlesData(
                  show: true,
                  // Ocultar títulos en ejes derecho y superior
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  
                  // Configuración del eje Y izquierdo
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Muestra los valores como porcentajes
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold
                          ),
                        );
                      },
                      reservedSize: 40, // Espacio reservado para los títulos
                      interval: _calculateInterval(grafico['series']['Total']), // Intervalo calculado
                    ),
                  ),
                  
                  // Configuración del eje X inferior
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        // Muestra los labels (días de la semana) solo para índices válidos
                        if (index >= 0 && index < grafico['labels'].length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              grafico['labels'][index].toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          );
                        }
                        return Text(''); // Retorna texto vacío para índices inválidos
                      },
                      interval: 1, // Muestra un título por cada punto
                      reservedSize: 22, // Espacio reservado para los títulos
                    ),
                  ),
                ),
                
                // Configuración del borde del gráfico
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    // Borde inferior sutil
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                    // Borde izquierdo sutil
                    left: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                
                // Configuración de la(s) línea(s) del gráfico
                lineBarsData: [
                  LineChartBarData(
                    // Puntos del gráfico generados dinámicamente
                    spots: List.generate(
                      grafico['labels'].length,
                      (i) => FlSpot(
                        i.toDouble(), // Posición X (índice)
                        double.parse(grafico['series']['Total'][i].toString()) // Valor Y
                      ),
                    ),
                    isCurved: true, // Línea curva suave
                    color: Colors.blueAccent, // Color de la línea
                    barWidth: 4, // Grosor de la línea
                    isStrokeCapRound: true, // Extremos redondeados
                    
                    // Configuración de los puntos en la línea
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white, // Relleno blanco
                          strokeWidth: 2,
                          strokeColor: Colors.blueAccent, // Borde azul
                        );
                      },
                    ),
                    
                    // Área bajo la línea con degradado
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blueAccent.withOpacity(0.3), // Más opaco arriba
                          Colors.blueAccent.withOpacity(0.1), // Más transparente abajo
                        ],
                      ),
                    ),
                    
                    // Sombra para efecto de profundidad
                    shadow: Shadow(
                      color: Colors.blueAccent.withOpacity(0.5),
                      blurRadius: 8,
                      offset: Offset(0, 5),
                    ),
                  ),
                ],
                
                // Configuración de la interacción táctil
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Color(0xFF0F2747), // Fondo del tooltip
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      // Tooltip que muestra el valor exacto al tocar
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}%', // Valor con 1 decimal
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