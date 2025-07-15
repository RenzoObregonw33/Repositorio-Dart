import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GraficoEficiencia extends StatelessWidget {
  final double eficiencia;

  const GraficoEficiencia({super.key, required this.eficiencia});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Eficiencia',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 100,
              ranges: <GaugeRange>[
                GaugeRange(startValue: 0, endValue: 40, color: Color(0xFFEA5160)),
                GaugeRange(startValue: 40, endValue: 70, color: Color(0xFFFFCD1C)),
                GaugeRange(startValue: 70, endValue: 100, color: Color(0xFF41C2C5)),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(value: eficiencia),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    '${eficiencia.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  angle: 90,
                  positionFactor: 0.8,
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
