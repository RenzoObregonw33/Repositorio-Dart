import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FunnelData {
  final String label;
  final double value;
  final Color color;

  FunnelData(this.label, this.value, this.color);
}

class GraficoEmbudo extends StatelessWidget {
  final List<FunnelData> data;

  const GraficoEmbudo({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SfFunnelChart(
      backgroundColor: Color(0xFF776F6C),
      title: ChartTitle(text: 'Cumplimiento Laboral', textStyle: TextStyle(fontWeight: FontWeight.bold)),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: FunnelSeries<FunnelData, String>(
        dataSource: data,
        xValueMapper: (FunnelData d, _) => d.label,
        yValueMapper: (FunnelData d, _) => d.value,
        pointColorMapper: (FunnelData d, _) => d.color,
        gapRatio: 0.03,
        neckWidth: '15%',
        neckHeight: '0%',
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.inside,
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
