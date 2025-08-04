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
    const Color(0xFF0868FB), // Azul
    const Color(0xFF2DC70D), // Verde
    const Color(0xFFFF1A15), // Rojo
    const Color(0xFF7AD6D5), // Cian
    const Color(0xFFFE9717), // Naranja
    const Color(0xFFDC32F3), // Morado   
  ];

  final List<Color> _coloresLineas = [
    const Color(0xFFFF1A15), // Rojo
    const Color(0xFF2DC70D), // Verde
    const Color(0xFF0868FB), // Azul
  ];

  List<ActividadDiariaData> _procesarDatos() {
    try {
      final labels = List<String>.from(widget.apiResponse['labels'] ?? []);
      final valores = (widget.apiResponse['series']['Total'] as List<dynamic>? ?? [])
          .map((v) => double.tryParse(v.toString()) ?? 0.0)
          .toList();

      return List.generate(labels.length, (index) => 
        ActividadDiariaData(
          labels.length > index ? labels[index] : 'Día ${index + 1}',
          valores.length > index ? valores[index] : 0
        )
      );
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
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 280, // Misma altura que los otros gráficos
          child: Column(
            children: [
              // Título manteniendo tu formato original
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📊 ${datos.length >= 7 ? 'Actividad Semanal' : 'Actividad Reciente'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _esLinea ? Icons.bar_chart : Icons.show_chart,
                      color: Colors.white,
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
        labelStyle: const TextStyle(color: Colors.white),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 1.5, color: Colors.blueGrey),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: _calcularMaxY(datos),
        interval: _calcularIntervalo(datos),
        labelFormat: '{value}%',
        labelStyle: const TextStyle(color: Colors.white),
        axisLine: const AxisLine(width: 1.5, color: Colors.blueGrey),
        majorGridLines: MajorGridLines(
          width: 1,
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x\n${_esLinea ? 'Actividad' : 'Total'}: point.y%',
        color: Colors.white,
        textStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        borderColor: Colors.blueGrey.shade300,
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
          borderColor: Colors.white,
          color: _coloresLineas[1],
        ),
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        width: 0.7,
        spacing: 0.2,
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      )
    ];
  }
}