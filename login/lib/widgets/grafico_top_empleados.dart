import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';

class TopEmpleadoData {
  final String nombre;
  final double porcentaje;

  TopEmpleadoData({required this.nombre, required this.porcentaje});
}

class GraficoTopEmpleados extends StatelessWidget {
  final List<TopEmpleadoData> data;

  const GraficoTopEmpleados({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<String> labels = [];
    List<Map<String, dynamic>> valoresConEstilo = [];

    for (var empleado in data) {
      final nombre = empleado.nombre;
      final porcentaje = empleado.porcentaje;

      final bool esNegativo = porcentaje < 30;

      labels.add(nombre);

      valoresConEstilo.add({
        'value': esNegativo ? -porcentaje : porcentaje, // ⬅️ Lo hacemos negativo si < 30%
        'itemStyle': {
          'color': esNegativo ? '#91cc75' : '#008fcb', // Verde o azul
        }
      });
    }

    final chartWidth = labels.length * 100;

    final option = {
      'tooltip': {
        'trigger': 'axis',
        'axisPointer': {'type': 'shadow'},
        'formatter': '{b}: {c} %',
      },
      'grid': {
        'left': '3%',
        'right': '4%',
        'bottom': '3%',
        'containLabel': true
      },
      'xAxis': [
        {
          'type': 'value',
          'min': -100,
          'max': 100,
          'axisLabel': {'formatter': '{value} %'}
        }
      ],
      'yAxis': [
        {
          'type': 'category',
          'inverse': true,
          'axisTick': {'show': false},
          'data': labels
        }
      ],
      'series': [
        {
          'type': 'bar',
          'label': {
            'show': true,
            'position': 'inside',
            'formatter': (r'{c} %'),
          },
          'data': valoresConEstilo,
        }
      ]
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: chartWidth.toDouble(),
        height: labels.length * 50 + 100,
        child: Echarts(
          option: jsonEncode(option),
        ),
      ),
    );
  }
}
