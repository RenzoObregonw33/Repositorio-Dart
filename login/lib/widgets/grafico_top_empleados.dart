import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'dart:convert';

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
    // Verificar si hay datos
    if (data.isEmpty) {
      return const Center(
        child: Text('No hay datos disponibles', 
               style: TextStyle(color: Colors.grey)),
      );
    }

    List<String> labels = [];
    List<Map<String, dynamic>> valoresConEstilo = [];

    for (int i = 0; i < data.length; i++) {
      final nombre = data[i].nombre;
      final porcentaje = data[i].porcentaje;

      labels.add(nombre);

      final bool esTop = i < 3; // Top 3 empleados

      valoresConEstilo.add({
        'value': esTop ? porcentaje : -porcentaje,
        'itemStyle': {
          'color': esTop ? '#0868FB' : '#2BCA07',
          'borderRadius': esTop ? [0, 10, 10, 0] : [10, 0, 0, 10],
        },
        'name': nombre,
      });
    }

    final chartWidth = (labels.length * 120).clamp(300, double.infinity).toDouble();

    final option = {
      'tooltip': {
        'trigger': 'axis',
        'axisPointer': {'type': 'shadow'},
        'formatter': '{b}: {c} %',
      },
      'grid': {
        'left': '3%', // Más espacio para labels largos
        'right': '5%',
        'bottom': '5%',
        'top': '5%',
        'containLabel': true
      },
      'xAxis': {
        'type': 'value',
        'min': -100,
        'max': 100,
        'axisLabel': {
          'formatter': '{value} %',
          'color': '#FFFFFF',
        },
        'axisLine': {
          'lineStyle': {
            'color': '#FFFFFF',
          }
        },
        'splitLine': {
          'lineStyle': {
            'color': '#4A5568',
          }
        },
      },
      'yAxis': {
        'type': 'category',
        'inverse': true,
        'axisTick': {'show': false},
        'axisLine': {'show': false},
        'axisLabel': {
          'color': '#FFFFFF',
          'fontWeight': 'bold',
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
            'color': '#FFFFFF',
            'fontWeight': 'bold',
          },
          'barWidth': '60%',
          'data': valoresConEstilo,
        }
      ]
    };

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🏆 Top Empleados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    height: labels.length * 50 + 100,
                    child: Echarts(
                      option: jsonEncode(option),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}