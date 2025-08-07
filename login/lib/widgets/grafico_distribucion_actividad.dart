import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../Models/datos_actividad.dart';

class GraficoDistribucionActividad extends StatefulWidget {
  final List<DatosActividad> datos;

  const GraficoDistribucionActividad({super.key, required this.datos});

  @override
  State<GraficoDistribucionActividad> createState() => _GraficoDistribucionActividadState();
}

class _GraficoDistribucionActividadState extends State<GraficoDistribucionActividad> {
  bool mostrarConActividad = true;
  bool mostrarSinActividad = true;

  @override
  Widget build(BuildContext context) {
    final datos = widget.datos;
    final cantidadDias = datos.length;
    final anchoDisponible = MediaQuery.of(context).size.width - 40;
    final anchoBarra = cantidadDias <= 2 ? (anchoDisponible / cantidadDias * 0.4).clamp(20.0, 80.0) : 22.0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del gráfico con icono en la misma línea
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  'DISTRIBUCIÓN DE ACTIVIDAD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Leyenda interactiva (ya centrada)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleLegend(
                      color: Colors.green,
                      label: 'Con actividad',
                      isActive: mostrarConActividad,
                      onTap: () => setState(() => mostrarConActividad = !mostrarConActividad),
                    ),
                    const SizedBox(width: 24),
                    _buildToggleLegend(
                      color: Colors.orange,
                      label: 'Sin actividad',
                      isActive: mostrarSinActividad,
                      onTap: () => setState(() => mostrarSinActividad = !mostrarSinActividad),
                    ),
                  ],
                ),
              ),
            ),
            
            // Gráfico de barras con ajustes para centrado
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0), // Ajuste fino de espacio superior
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.center, // Cambiado a center para mejor centrado
                    barGroups: datos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final dato = entry.value;

                      final double totalAltura = (mostrarConActividad ? dato.conActividad : 0) +
                          (mostrarSinActividad ? dato.sinActividad : 0);

                      final rods = <BarChartRodStackItem>[];
                      double inicio = 0;

                      if (mostrarConActividad) {
                        rods.add(BarChartRodStackItem(
                          inicio, 
                          inicio + dato.conActividad, 
                          Colors.green,
                        ));
                        inicio += dato.conActividad;
                      }
                      if (mostrarSinActividad) {
                        rods.add(BarChartRodStackItem(
                          inicio, 
                          inicio + dato.sinActividad, 
                          Colors.orange,
                        ));
                      }

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: totalAltura,
                            rodStackItems: rods,
                            width: anchoBarra,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28, // Reducido para optimizar espacio
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10), // Tamaño reducido
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20, // Reducido para optimizar espacio
                          getTitlesWidget: (value, _) {
                            final index = value.toInt();
                            if (index >= 0 && index < datos.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0), // Padding reducido
                                child: Text(
                                  datos[index].dia,
                                  style: const TextStyle(fontSize: 10), // Tamaño reducido
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.blueGrey[800]!,
                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final d = datos[groupIndex];
                          final conActividad = mostrarConActividad ? d.conActividad : 0;
                          final sinActividad = mostrarSinActividad ? d.sinActividad : 0;
                          final total = conActividad + sinActividad;
                          
                          return BarTooltipItem(
                            'Actividad\n\n'  // Cambiado de d.dia a "Actividad"
                            '${mostrarConActividad ? 'Con actividad: ${d.conActividad.toStringAsFixed(1)} hrs\n' : ''}'
                            '${mostrarSinActividad ? 'Sin actividad: ${d.sinActividad.toStringAsFixed(1)} hrs\n' : ''}'
                            'Total: ${total.toStringAsFixed(1)} hrs',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.left,
                          );
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleLegend({
    required Color color,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isActive ? color : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}