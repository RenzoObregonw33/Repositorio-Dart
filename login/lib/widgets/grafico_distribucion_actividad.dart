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
    // Tomar máximo 7 días
    final datosMostrar = widget.datos.length > 7 
        ? widget.datos.sublist(0, 7) 
        : widget.datos;
    
    final cantidadDias = datosMostrar.length;
    final anchoDisponible = MediaQuery.of(context).size.width - 40;
    final anchoBarra = cantidadDias <= 3 
        ? (anchoDisponible / cantidadDias * 0.5).clamp(20.0, 80.0) 
        : 22.0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFF8F7FC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Color(0xFF3E2B6B)),
                const SizedBox(width: 8),
                Text(
                  'DISTRIBUCIÓN DE ACTIVIDAD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleLegend(
                      color: Color(0xFF64D9C5),
                      label: 'Con actividad',
                      isActive: mostrarConActividad,
                      onTap: () => setState(() => mostrarConActividad = !mostrarConActividad),
                    ),
                    const SizedBox(width: 24),
                    _buildToggleLegend(
                      color: Color(0xFFC4DEF9),
                      label: 'Sin actividad',
                      isActive: mostrarSinActividad,
                      onTap: () => setState(() => mostrarSinActividad = !mostrarSinActividad),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.center,
                    barGroups: datosMostrar.asMap().entries.map((entry) {
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
                          Color(0xFF64D9C5),
                        ));
                        inicio += dato.conActividad;
                      }
                      if (mostrarSinActividad) {
                        rods.add(BarChartRodStackItem(
                          inicio, 
                          inicio + dato.sinActividad, 
                          Color(0xFFC4DEF9),
                        ));
                      }

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: totalAltura,
                            rodStackItems: rods,
                            width: anchoBarra,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                        ],
                        
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20,
                          getTitlesWidget: (value, _) {
                            final index = value.toInt();
                            if (index >= 0 && index < datosMostrar.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  datosMostrar[index].dia,
                                  style: const TextStyle(fontSize: 10),
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
                          final d = datosMostrar[groupIndex];
                          final conActividad = mostrarConActividad ? d.conActividad : 0;
                          final sinActividad = mostrarSinActividad ? d.sinActividad : 0;
                          final total = conActividad + sinActividad;
                          
                          return BarTooltipItem(
                            '📊 Actividad\n\n'
                            '${mostrarConActividad ? '🟢 Con actividad: ${d.conActividad.toStringAsFixed(1)} hrs\n' : ''}'
                            '${mostrarSinActividad ? '⚪ Sin actividad: ${d.sinActividad.toStringAsFixed(1)} hrs\n' : ''}'
                            '🧮 Total: ${total.toStringAsFixed(1)} hrs',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
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
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey[300]!, width: 1),
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
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
  

  