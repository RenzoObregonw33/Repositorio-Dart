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
          height: 280,
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.trending_up, color: Color(0xFF3E2B6B)),
                  SizedBox(width: 8),
                  Text(
                    'Engagement Operativo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Expanded(
                child: Center(
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        radiusFactor: 0.9,
                        axisLineStyle: const AxisLineStyle(
                          thickness: 0.08,
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
                            needleLength: 0.9,
                            needleColor: Colors.black.withOpacity(0.5),
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
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
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
                            positionFactor: 0.7, // Cambiado de 0.5 a 0.7 para mayor separación
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