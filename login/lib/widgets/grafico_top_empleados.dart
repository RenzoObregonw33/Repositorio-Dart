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

    for (int i = 0; i < data.length; i++) {
      final nombre = data[i].nombre;
      final porcentaje = data[i].porcentaje;

      labels.add(nombre);

      final bool esTop = i<3;

      valoresConEstilo.add({
        'value': esTop? porcentaje : -porcentaje, // Siempre positivo
        'itemStyle': {
          'color': esTop ? '#748FC9' : '#41C2C5', // Azul o verde
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
