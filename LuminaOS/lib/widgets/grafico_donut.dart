import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'safe_chart_wrapper.dart';

class DonutData {
  final String categoria;
  final double valor;
  final Color color;

  DonutData(this.categoria, this.valor, this.color);
}

class GraficoDonut extends StatefulWidget {
  final double productivas;
  final double noProductivas;
  
  const GraficoDonut({
    super.key, 
    required this.productivas, 
    required this.noProductivas
  });

  @override
  State<GraficoDonut> createState() => _GraficoDonutState();
}

class _GraficoDonutState extends State<GraficoDonut> {
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }
    
    final total = widget.productivas + widget.noProductivas;
    final data = [
      DonutData('Horas productivas', widget.productivas, const Color(0xFFC4DEF9)),
      DonutData('Horas no productivas', widget.noProductivas, const Color(0xFF64D9C5)),
    ];

    return SafeChartWrapper(
      debugLabel: 'GraficoDonut',
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFFF8F7FC),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título con icono
              const Row(
                children: [
                  Icon(Icons.pie_chart, color: Color(0xFF3E2B6B)),
                  SizedBox(width: 8),
                  Text(
                    'Ratio de actividad registrada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Gráfico Donut con animación nativa de Syncfusion y protección
              Expanded(
                child: _isDisposed 
                  ? const SizedBox.shrink()
                  : SfCircularChart(
                      legend: Legend(
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                        position: LegendPosition.bottom,
                        textStyle: const TextStyle(color: Colors.black),
                      ),
                      series: <CircularSeries<DonutData, String>>[
                        DoughnutSeries<DonutData, String>(
                          dataSource: data,
                          xValueMapper: (DonutData d, _) => d.categoria,
                          yValueMapper: (DonutData d, _) => d.valor,
                          pointColorMapper: (DonutData d, _) => d.color,
                          dataLabelMapper: (DonutData d, _) => 
                              '${((d.valor / total) * 100).toStringAsFixed(1)}%',
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            overflowMode: OverflowMode.shift,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Colors.black,
                              fontSize: 12,
                            ),
                            connectorLineSettings: ConnectorLineSettings(
                              length: '5%',
                              type: ConnectorType.curve,
                              color: Colors.black,
                            ),
                          ),
                          radius: '65%',
                          innerRadius: '60%',
                          animationDuration: 0, // Sin animación para evitar crashes
                        ),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}