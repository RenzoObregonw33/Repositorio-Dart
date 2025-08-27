import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GraficoEficiencia extends StatelessWidget {
  final double eficiencia;

  const GraficoEficiencia({super.key, required this.eficiencia});

  @override
  Widget build(BuildContext context) {
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
          height: 280, // Altura aumentada para contener el gráfico más grande
          child: Column(
            children: [
              // Título (se mantiene igual)
              const Row(
                children: [
                  Icon(Icons.auto_graph, color: Color(0xFF3E2B6B)),
                  SizedBox(width: 8),
                  Text(
                    'EFICIENCIA GENERAL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Espacio reducido entre título y gráfico
              
              // Gráfico ampliado y centrado
              Expanded(
                child: Center( // Envuelto en Center para asegurar centrado
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        radiusFactor: 0.9, // Gráfico más grande (90% del espacio)
                        axisLineStyle: const AxisLineStyle(
                          thickness: 0.08, // Ancho de barras reducido
                          color: Colors.white54,
                        ),
                        ranges: <GaugeRange>[
                          GaugeRange(
                            startValue: 0,
                            endValue: 40,
                            color: const Color(0xFFFF625C),
                            sizeUnit: GaugeSizeUnit.factor,
                            startWidth: 0.08,
                            endWidth: 0.08,
                          ),
                          GaugeRange(
                            startValue: 40,
                            endValue: 70,
                            color: const Color(0xFFFFC066),
                            sizeUnit: GaugeSizeUnit.factor,
                            startWidth: 0.08,
                            endWidth: 0.08,
                          ),
                          GaugeRange(
                            startValue: 70,
                            endValue: 100,
                            color: const Color(0xFF64D9C5),
                            sizeUnit: GaugeSizeUnit.factor,
                            startWidth: 0.08,
                            endWidth: 0.08,
                          ),
                        ],
                        pointers: <GaugePointer>[
                          NeedlePointer(
                            value: eficiencia,
                            needleLength: 0.9, // Aguja ligeramente más larga
                            needleColor: Colors.black,
                            knobStyle: const KnobStyle(
                              color: Colors.black,
                              knobRadius: 0.08,
                            ),
                          ),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${eficiencia.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 26, // Texto un poco más grande
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  _getEficienciaText(eficiencia),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            angle: 90,
                            positionFactor: 0.5,
                          ),
                        ],
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

  String _getEficienciaText(double value) {
    if (value < 40) return 'Eficiencia baja';
    if (value < 70) return 'Eficiencia media';
    return 'Eficiencia alta';
  }
}