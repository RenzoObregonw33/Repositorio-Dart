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
                GaugeRange(startValue: 0, endValue: 40, color: Colors.red),
                GaugeRange(startValue: 40, endValue: 70, color: Colors.orange),
                GaugeRange(startValue: 70, endValue: 100, color: Colors.green),
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
