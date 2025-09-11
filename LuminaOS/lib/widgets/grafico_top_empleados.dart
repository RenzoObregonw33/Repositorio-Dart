import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'dart:convert';

class TopEmpleadoData {
  final String nombre;
  final double porcentaje;

  TopEmpleadoData({required this.nombre, required this.porcentaje});
}

class GraficoTopEmpleados extends StatefulWidget {
  final List<TopEmpleadoData> data;

  const GraficoTopEmpleados({super.key, required this.data});

  @override
  State<GraficoTopEmpleados> createState() => _GraficoTopEmpleadosState();
}

class _GraficoTopEmpleadosState extends State<GraficoTopEmpleados> {
  final ScrollController _scrollController = ScrollController();
  double _scrollPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollIndicator);
    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      final centerOffset = _scrollController.position.maxScrollExtent / 2;
      _scrollController.jumpTo(centerOffset); 
      // Si quieres animado:
      // _scrollController.animateTo(
      //   centerOffset,
      //   duration: const Duration(milliseconds: 500),
      //   curve: Curves.easeInOut,
      // );
    }
  });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicator);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicator() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        setState(() {
          _scrollPercentage = _scrollController.offset / maxScroll;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si hay datos
    if (widget.data.isEmpty) {
      return Card(
        elevation: 4,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFFF8F7FC),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No hay datos disponibles',
                   style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    List<String> labels = [];
    List<Map<String, dynamic>> valoresConEstilo = [];

    for (int i = 0; i < widget.data.length; i++) {
      final nombre = widget.data[i].nombre;
      final porcentaje = widget.data[i].porcentaje;

      labels.add(nombre);

      final bool esTop = i < 3; // Top 3 empleados

      valoresConEstilo.add({
        'value': esTop ? porcentaje : -porcentaje,
        'itemStyle': {
          'color': esTop ? '#C4DEF9' : '#64D9C5',
          'borderRadius': esTop ? [0, 10, 10, 0] : [10, 0, 0, 10],
        },
        'name': nombre,
      });
    }

    final chartWidth = (labels.length * 120).clamp(300, double.infinity).toDouble();
    final maxScrollExtent = chartWidth - MediaQuery.of(context).size.width + 32;
    final showIndicator = maxScrollExtent > 0;

    final option = {
      'tooltip': {
        'trigger': 'axis',
        'axisPointer': {'type': 'shadow'},
        'formatter': '{b}: {c} %',
      },
      'grid': {
        'left': '2%',
        'right': '2%',
        'bottom': '5%',
        'top': '5%',
        'containLabel': true
      },
      'xAxis': {
        'type': 'value',
        'min': -50,
        'max': 100,
        'interval': 25,
        'axisLabel': {
          'formatter': '{value} %',
          'color': '#000000',
          'fontWeight': 'bold',
          'fontSize': 10,
        },
        'axisLine': {
          'lineStyle': {
            'color': '#000000',
          }
        },
        'splitLine': {
          'lineStyle': {
            'color': '#4A5568',
            'opacity': 0.3,
          }
        },
      },
      'yAxis': {
        'type': 'category',
        'inverse': true,
        'axisTick': {'show': false},
        'axisLine': {'show': false},
        'axisLabel': {
          'color': '#000000',
          'fontWeight': 'bold',
          'margin': 6,
          'fontSize': 10,
        },
        'data': labels,
      },
      'series': [
        {
          'type': 'bar',
          'label': {
            'show': true,
            'position': 'inside',
            'formatter': '{c} %',
            'color': '#000000',
            'fontWeight': 'bold',
            'fontSize': 10,
          }
          ,
          'barWidth': '50%',
          'data': valoresConEstilo,
        }
      ]
    };

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
          height: 320,
          child: Column(
            children: [
              // Título con icono
              const Row(
                children: [
                  Icon(Icons.emoji_events, color: Color(0xFF3E2B6B)),
                  SizedBox(width: 8),
                  Text(
                    'Desempeño por nivel de Actividad',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Gráfico con indicador de desplazamiento
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: chartWidth,
                          height: labels.length * 40 + 80,
                          child: Echarts(
                            option: jsonEncode(option),
                          ),
                        ),
                      ),
                    ),
                    
                    // Indicador de desplazamiento interactivo
                    if (showIndicator)
                    Container(
                      height: 16,
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Stack(
                              children: [
                                // Barra de progreso que se mueve con el scroll
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 100),
                                  left: _scrollPercentage * 80, // 80 = 100 - 20 (para que no se salga)
                                  child: Container(
                                    width: 20,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3E2B6B),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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