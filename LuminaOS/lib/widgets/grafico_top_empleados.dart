import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'dart:convert';

/// Modelo que representa un empleado y su porcentaje de actividad
class TopEmpleadoData {
  final String nombre;
  final double porcentaje;

  TopEmpleadoData({required this.nombre, required this.porcentaje});
}

/// Widget principal que dibuja el gráfico de Top Empleados
class GraficoTopEmpleados extends StatefulWidget {
  final List<TopEmpleadoData> data; // Lista de empleados con sus porcentajes

  const GraficoTopEmpleados({super.key, required this.data});

  @override
  State<GraficoTopEmpleados> createState() => _GraficoTopEmpleadosState();
}

class _GraficoTopEmpleadosState extends State<GraficoTopEmpleados> {
  final ScrollController _scrollController = ScrollController(); // Controla el scroll horizontal
  double _scrollPercentage = 0.0; // Para mostrar el indicador de cuánto se ha desplazado

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollIndicator);

    // Opcional: centrar el scroll en el medio al cargar por primera vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          final centerOffset = maxScroll / 2;
          _scrollController.jumpTo(centerOffset);
        }
      }
    });
  }

  @override
  void dispose() {
    // Limpieza: quitamos listener y cerramos controlador
    _scrollController.removeListener(_updateScrollIndicator);
    _scrollController.dispose();
    super.dispose();
  }

  /// Actualiza el porcentaje del scroll para mostrar el LinearProgressIndicator
  void _updateScrollIndicator() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        setState(() {
          _scrollPercentage = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
        });
      } else {
        setState(() {
          _scrollPercentage = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Caso cuando no hay datos
    if (widget.data.isEmpty) {
      return Card(
        elevation: 4,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFFF8F7FC),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No hay datos disponibles',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // Construimos listas de nombres y series de valores
    final List<String> labels = [];   // Nombres de empleados
    final List<double> positiva = []; // Actividad hacia la derecha
    final List<double> negativa = []; // Actividad hacia la izquierda

    for (int i = 0; i < widget.data.length; i++) {
      final d = widget.data[i];
      labels.add(d.nombre);

      // 🔴 Forzar que los 3 últimos vayan siempre a la izquierda
      // Solo forzar a la izquierda si hay más de 3 empleados
      if (widget.data.length > 3 && i >= widget.data.length - 3) {
        positiva.add(0);
        negativa.add(-d.porcentaje.abs()); // lo pasamos como negativo
      } else {
        // Caso normal: según el signo
        if (d.porcentaje >= 0) {
          positiva.add(d.porcentaje);
          negativa.add(0);
        } else {
          positiva.add(0);
          negativa.add(d.porcentaje);
        }
      }
    }

    // Ajustamos tamaño del gráfico para que se vea bien con scroll
    final double chartWidth = (labels.length * 120).clamp(300.0, double.infinity).toDouble();
    final double chartHeight = labels.length * 40.0 + 80.0;

    // Configuración de ECharts en formato JSON
    final String option = '''
{
  tooltip: {
    trigger: 'axis',
    axisPointer: { type: 'shadow' },
    formatter: function(params) {
      // Quitar signo negativo en el tooltip
      return params.map(function(p) {
        var value = Math.abs(p.value);
        return p.marker + ' ' + p.seriesName + ': ' + value + ' %';
      }).join('<br/>');
    }
  },
  legend: {
    data: ['Actividad negativa', 'Actividad positiva']
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '3%',
    containLabel: true
  },
  xAxis: [
    {
      type: 'value',
      min: -100,
      max: 100,
      axisLabel: { formatter: '{value} %' }
    }
  ],
  yAxis: [
    {
      type: 'category',
      inverse: true,
      axisTick: { show: false },
      data: ${jsonEncode(labels)}
    }
  ],
  series: [
    {
      name: 'Actividad negativa',
      type: 'bar',
      label: {
        show: true,
        position: 'inside',
        formatter: function(params) { return Math.abs(params.value) + ' %'; }
      },
      itemStyle: {
        color: '#FF625C',
        borderRadius: [6, 0, 0, 6] // redondeado hacia la izquierda
      },
      data: ${jsonEncode(negativa)}
    },
    {
      name: 'Actividad positiva',
      type: 'bar',
      label: {
        show: true,
        position: 'inside',
        formatter: function(params) { return Math.abs(params.value) + ' %'; }
      },
      itemStyle: {
        color: '#64D9C5',
        borderRadius: [0, 6, 6, 0] // redondeado hacia la derecha
      },
      data: ${jsonEncode(positiva)}
    }
  ]
}
''';

    // Tarjeta que contiene el gráfico
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF8F7FC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 320,
          child: Column(
            children: [
              // Título del gráfico
              const Row(
                children: [
                  Icon(Icons.emoji_events, color: Color(0xFF3E2B6B)),
                  SizedBox(width: 8),
                  Text(
                    'Desempeño por nivel de Actividad',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Contenedor del gráfico con scroll horizontal
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: chartWidth,
                          height: chartHeight,
                          child: Echarts(option: option),
                        ),
                      ),
                    ),

                    // Barra de progreso para mostrar scroll
                    if (chartWidth > MediaQuery.of(context).size.width)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(
                          value: _scrollPercentage,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          color: const Color(0xFF3E2B6B),
                          minHeight: 4,
                        ),
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
