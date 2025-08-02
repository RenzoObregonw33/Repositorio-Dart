import 'package:flutter/material.dart';
import 'package:login/Models/datos_embudo.dart';
import 'package:syncfusion_flutter_charts/charts.dart';



class GraficoEmbudo extends StatelessWidget {
  final List<FunnelData> data;

  const GraficoEmbudo({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SfFunnelChart(
      title: ChartTitle(
        text: 'Cumplimiento Laboral',
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: FunnelSeries<FunnelData, String>(
        dataSource: data,
        xValueMapper: (FunnelData d, _) => d.label,
        yValueMapper: (FunnelData d, _) => d.value,
        pointColorMapper: (FunnelData d, _) => d.color,
        gapRatio: 0.2,  // Aumenta este valor para más separación entre segmentos
        neckWidth: '20%', // Ajusta el ancho del cuello
        neckHeight: '15%', // Ajusta la altura del cuello
        explode: true,  // Separa ligeramente los segmentos
        explodeOffset: '5%',  // Controla la cantidad de separación
        dataLabelSettings: DataLabelSettings(
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