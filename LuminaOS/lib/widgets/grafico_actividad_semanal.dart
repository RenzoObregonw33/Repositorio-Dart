import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'safe_chart_wrapper.dart';

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
  bool _esLinea = true; // Por defecto mostrar gráfico de líneas
  final List<Color> _coloresBarras = [
    Color(0xFF3E2B6B),
    Color(0xFF64D9C5),
  ];

  final List<Color> _coloresLineas = [
    Color(0xFF3E2B6B),
    Color(0xFF64D9C5),
  ];

  // Función para formatear el label en dos líneas
  String _formatearLabel(String label) {
    final parts = label.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]}\n${parts[1]}'; // "Mar.\n01/07"
    }
    return label;
  }

  List<ActividadDiariaData> _procesarDatos() {
    try {
      final labels = List<String>.from(widget.apiResponse['labels'] ?? []);
      final valores = (widget.apiResponse['series']['Total'] as List<dynamic>? ?? [])
          .map((v) => double.tryParse(v.toString()) ?? 0.0)
          .toList();

      // Normalizamos ambas listas al mismo tamaño
      int length = labels.length;
      if (valores.length < length) {
        valores.addAll(List.filled(length - valores.length, 0.0));
      }

      List<ActividadDiariaData> todosLosDatos = [];
      
      for (int i = 0; i < length; i++) {
        String dia = i < labels.length ? _formatearLabel(labels[i]) : 'Día ${i + 1}';
        double valor = i < valores.length ? valores[i] : 0.0;
        todosLosDatos.add(ActividadDiariaData(dia, valor));
      }

      // Tomar EXACTAMENTE los últimos 6 días
      int startIndex = todosLosDatos.length > 6 ? todosLosDatos.length - 6 : 0;
      final resultado = todosLosDatos.sublist(startIndex);

      return resultado;

    } catch (e) {
      debugPrint('Error procesando datos: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final datos = _procesarDatos();

    return SafeChartWrapper(
      debugLabel: 'GraficoActividadSemanal',
      child: Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFF8F7FC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              // Aumentar altura para acomodar labels de dos líneas
              height: constraints.maxWidth > 350 ? 350 : 380,
              child: Column(
                children: [
                  // Título
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Intensidad de trabajo en el tiempo',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
                        : _buildChart(datos, constraints.maxWidth),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    )
    ); // Cierre de SafeChartWrapper
  }

  Widget _buildChart(List<ActividadDiariaData> datos, double availableWidth) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: 5 // Más espacio para etiquetas de dos líneas 
      ),
      primaryXAxis: CategoryAxis(
        labelRotation: -45,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 10, // Reducido de 12 a 10
          height: 1.2, // Ajustar altura de línea
        ),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 1.5, color: Colors.white54),
        interval: 1,
        desiredIntervals: 6,
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: _calcularMaxY(datos),
        interval: _calcularIntervalo(datos),
        labelFormat: '{value}%',
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 10,
        ),
        axisLine: const AxisLine(width: 1.5, color: Colors.white54),
        majorGridLines: MajorGridLines(
          width: 1,
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x\n${_esLinea ? 'Actividad' : 'Total'}: point.y%',
        color: Colors.black,
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
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
        width: 2,
        animationDuration: 0, // Sin animaciones para evitar errors
        markerSettings: MarkerSettings(
          isVisible: true,
          shape: DataMarkerType.circle,
          borderWidth: 1,
          borderColor: Color(0xFF3E2B6B),
          color: _coloresLineas[1],
          width: 6,
          height: 6,
        ),
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 8,
          ),
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
            return Text(
              '${point.y.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 8,
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
        width: 0.5,
        spacing: 0.05,
        animationDuration: 0, // Sin animaciones para evitar errors
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 8,
          ),
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
            return Text(
              '${point.y.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 8,
              ),
            );
          },
        ),
      )
    ];
  }
}