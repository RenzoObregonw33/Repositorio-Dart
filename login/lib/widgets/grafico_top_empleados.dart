import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';

// Clase que representa la actividad de un empleado
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
    // Separa nombres, positivos y negativos
    List<String> labels = [];
    List<double> positiva = [];
    List<double> negativa = [];

    for (var empleado in data) {
      final nombre = empleado.nombre;
      final porcentaje = empleado.porcentaje;
      labels.add(nombre);
      if (porcentaje >= 0) {
        positiva.add(porcentaje);
        negativa.add(0);
      } else {
        positiva.add(0);
        negativa.add(-porcentaje); // lo pasamos a positivo
      }
    }

    // Ancho dinámico del gráfico para scroll horizontal
    final chartWidth = labels.length * 100;

    final option = {
      'tooltip': {
        'trigger': 'axis',
        'axisPointer': {'type': 'shadow'},
        // Eliminamos function personalizada para evitar errores
        'formatter': '{b}: {c} %'
      },
      'legend': {
        'data': ['Actividad positiva', 'Actividad negativa']
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
          'name': 'Actividad negativa',
          'type': 'bar',
          'label': {
            'show': true,
            'position': 'inside',
            'formatter': '{c} %'
          },
          'itemStyle': {'color': '#91cc75'},
          'emphasis': {'focus': 'series'},
          'data': negativa.map((e) => -e).toList()
        },
        {
          'name': 'Actividad positiva',
          'type': 'bar',
          'label': {
            'show': true,
            'position': 'inside',
            'formatter': '{c} %'
          },
          'itemStyle': {'color': '#008fcb'},
          'emphasis': {'focus': 'series'},
          'data': positiva
        }
      ]
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: chartWidth.toDouble(),
        height: labels.length * 50 + 100,
        child: Echarts(
          option: jsonEncode(option), // ✅ compatible con tu versión
        ),
      ),
    );
  }
}
