import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActividadDiariaData {
  final String dia;
  final double porcentaje;

  ActividadDiariaData(this.dia, this.porcentaje);
}

class GraficoActividadDiaria extends StatefulWidget {
  final Map<String, dynamic> apiResponse;

  const GraficoActividadDiaria({super.key, required this.apiResponse});

  @override
  State<GraficoActividadDiaria> createState() => _GraficoActividadDiariaState();
}

class _GraficoActividadDiariaState extends State<GraficoActividadDiaria> {
  bool _esLinea = false;
  final List<Color> _coloresBarras = [
    Color(0xFF3E2B6B),
    Color(0xFF64D9C5), // Turquesa
  ];

  final List<Color> _coloresLineas = [
    Color(0xFF3E2B6B), // Morado oscuro
    Color(0xFF64D9C5), // Turquesa
  ];

  List<ActividadDiariaData> _procesarDatos() {
    try {
      final labels = List<String>.from(widget.apiResponse['labels'] ?? []);
      final valores = (widget.apiResponse['series']['Total'] as List<dynamic>? ?? [])
          .map((v) => double.tryParse(v.toString()) ?? 0.0)
          .toList();

      // Obtener todos los datos
      List<ActividadDiariaData> todosLosDatos = List.generate(
        labels.length, 
        (index) => ActividadDiariaData(
          labels.length > index ? labels[index] : 'Día ${index + 1}',
          valores.length > index ? valores[index] : 0
        )
      );

      // Tomar solo los últimos 6 días (o menos si hay menos datos)
      int startIndex = todosLosDatos.length > 6 ? todosLosDatos.length - 6 : 0;
      return todosLosDatos.sublist(startIndex);
      
    } catch (e) {
      debugPrint('Error procesando datos: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final datos = _procesarDatos();

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
              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📊 Actividad Semanal ${datos.length} Días',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _esLinea ? Icons.bar_chart : Icons.show_chart,
                      color: Colors.black,
                    ),
                    onPressed: () => setState(() => _esLinea = !_esLinea),
                    tooltip: _esLinea ? 'Ver como barras' : 'Ver como líneas',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Gráfico con Expanded
              Expanded(
                child: datos.isEmpty
                    ? const Center(
                        child: Text('No hay datos disponibles',
                            style: TextStyle(color: Colors.grey)))
                    : _buildChart(datos),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<ActividadDiariaData> datos) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        labelRotation: -45,
        labelStyle: const TextStyle(color: Colors.black),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 1.5, color: Colors.white54),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: _calcularMaxY(datos),
        interval: _calcularIntervalo(datos),
        labelFormat: '{value}%',
        labelStyle: const TextStyle(color: Colors.black),
        axisLine: const AxisLine(width: 1.5, color: Colors.white54),
        majorGridLines: MajorGridLines(
          width: 1,
          color: Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x\n${_esLinea ? 'Actividad' : 'Total'}: point.y%',
        color: Colors.black,
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        borderColor: Colors.grey.shade300,
      ),
      series: _esLinea ? _buildLineSeries(datos) : _buildColumnSeries(datos),
    );
  }

  double _calcularMaxY(List<ActividadDiariaData> datos) {
    if (datos.isEmpty) return 100;
    final maxVal = datos.map((e) => e.porcentaje).reduce((a, b) => a > b ? a : b);
    return (maxVal * 1.2).clamp(0, 100).toDouble();
  }

  double _calcularIntervalo(List<ActividadDiariaData> datos) {
    final maxY = _calcularMaxY(datos);
    return maxY > 50 ? 20 : (maxY > 20 ? 10 : 5);
  }

  List<LineSeries<ActividadDiariaData, String>> _buildLineSeries(List<ActividadDiariaData> datos) {
    return [
      LineSeries<ActividadDiariaData, String>(
        dataSource: datos,
        xValueMapper: (d, _) => d.dia,
        yValueMapper: (d, _) => d.porcentaje,
        color: _coloresLineas[0],
        width: 3,
        markerSettings: MarkerSettings(
          isVisible: true,
          shape: DataMarkerType.circle,
          borderWidth: 2,
          borderColor: Color(0xFF3E2B6B),
          color: _coloresLineas[1],
        ),
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
            return Text(
              '${point.y.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 10,
              ),
            );
          },
        ),
      )
    ];
  }

  List<ColumnSeries<ActividadDiariaData, String>> _buildColumnSeries(List<ActividadDiariaData> datos) {
    return [
      ColumnSeries<ActividadDiariaData, String>(
        dataSource: datos,
        xValueMapper: (d, _) => d.dia,
        yValueMapper: (d, _) => d.porcentaje,
        pointColorMapper: (d, index) => _coloresBarras[index % _coloresBarras.length],
        width: 0.7,
        spacing: 0.2,
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
            return Text(
              '${point.y.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 10,
              ),
            );
          },
        ),
      )
    ];
  }
}