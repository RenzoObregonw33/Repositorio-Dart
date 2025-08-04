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
      return Card(
        elevation: 4,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF1E293B),
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
        'left': '2%',
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
              // Título con icono como los otros gráficos
              const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    'TOP EMPLEADOS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Gráfico con Expanded
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