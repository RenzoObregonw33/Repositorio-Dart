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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🟩🟧 Leyenda interactiva centrada (cambiado de Wrap a Row con MainAxisAlignment.center)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 👈 esto centra la leyenda horizontalmente
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    mostrarConActividad = !mostrarConActividad;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: mostrarConActividad ? Colors.green : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('Con actividad'),
                  ],
                ),
              ),
              const SizedBox(width: 24), // espacio entre botones
              GestureDetector(
                onTap: () {
                  setState(() {
                    mostrarSinActividad = !mostrarSinActividad;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: mostrarSinActividad ? Colors.orange : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('Sin actividad'),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              barGroups: datos.asMap().entries.map((entry) {
                final index = entry.key;
                final dato = entry.value;

                final double totalAltura = (mostrarConActividad ? dato.conActividad : 0) +
                    (mostrarSinActividad ? dato.sinActividad : 0);

                final rods = <BarChartRodStackItem>[];
                double inicio = 0;

                if (mostrarConActividad) {
                  rods.add(BarChartRodStackItem(inicio, inicio + dato.conActividad, Colors.green));
                  inicio += dato.conActividad;
                }
                if (mostrarSinActividad) {
                  rods.add(BarChartRodStackItem(inicio, inicio + dato.sinActividad, Colors.orange));
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
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index >= 0 && index < datos.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(datos[index].dia, style: const TextStyle(fontSize: 12)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final d = datos[groupIndex];
                    return BarTooltipItem(
                      '${d.dia}\n'
                      '${mostrarConActividad ? 'Con actividad: ${d.conActividad.toStringAsFixed(1)} h\n' : ''}'
                      '${mostrarSinActividad ? 'Sin actividad: ${d.sinActividad.toStringAsFixed(1)} h' : ''}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
