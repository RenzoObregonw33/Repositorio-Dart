import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:login/Cards/card_barras_horas.dart';
import 'package:login/Cards/card_donut.dart';
import 'package:login/Cards/card_eficiencia.dart';
import 'package:login/Cards/card_embudo.dart';
import 'package:login/Cards/card_tendencia_hora.dart';

import 'package:login/widgets/grafico_actividad_diaria.dart';
import 'package:login/widgets/grafico_embudo.dart';
import 'package:login/widgets/grafico_tendencia_hora.dart';
import 'package:login/widgets/grafico_top_empleados.dart';

class DashboardScreen extends StatefulWidget {
  final int organiId;
  final String token;

  const DashboardScreen({super.key, required this.organiId, required this.token});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  // Datos para todos los gráficos
  double? eficiencia;
  List<FunnelData>? cumplimientoLaboralData;
  double? horasProductivas;
  double? horasNoProductivas;
  double? programadas;
  double? presencia;
  double? productivas;
  List<TendenciaHoraData>? tendenciaHoras;
  List<ActividadDiariaData> actividadData = [];
  List<TopEmpleadoData> topEmpleadosData = [];

  bool isLoading = true;
  bool esLinea = true;
  DateTime? fechaIni;
  DateTime? fechaFin;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    fechaIni = DateTime(hoy.year, hoy.month, hoy.day);
    fechaFin = DateTime(hoy.year, hoy.month, hoy.day);
    fetchDatosEficiencia();
  }

  Future<void> fetchDatosEficiencia() async {                                     //FUNCION PARA BUSCAR LOS DATOS
    if (fechaIni == null || fechaFin == null) return;

    final formato = DateFormat('yyyy-MM-dd');
    final url = Uri.parse('https://rhnube.com.pe/api/v5/graficsLumina');

    setState(() {
      isLoading = true;
      eficiencia = null;
      cumplimientoLaboralData = null;
      horasProductivas = null;
      horasNoProductivas = null;
    });

    try {
      final token = widget.token;
      if (token.isEmpty) return;                                            //SI NO TENGO EL TOKEN NO SE PODRA VER DATOS

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'fecha_ini': formato.format(fechaIni!),
          'fecha_fin': formato.format(fechaFin!),
          'organi_id': widget.organiId,
        }),
      );

      final body = jsonDecode(response.body);                                     //CONVIERTE JSON EN UN MAPA DE DATOS PARA PODER BUSCAR
      final resultado = body['eficiencia']?['resultado'];
      final comparativo = body['eficiencia']?['comparativo_horas'] ?? body['comparativo_horas'];
      final tendencia = body['tendencia_por_hora'];
      final actividad = body['actividad_ultimos_dias'];

      if (comparativo != null) {
        cumplimientoLaboralData = [                                               //COMPARARTIVO EN HORAS
          FunnelData('Horas programadas', (comparativo['programadas'] ?? 0).toDouble(), Colors.blue),
          FunnelData('Horas de presencia', (comparativo['presencia'] ?? 0).toDouble(), Colors.green),
          FunnelData('Horas productivas', (comparativo['productivas'] ?? 0).toDouble(), Colors.red),
          FunnelData('Horas no productivas', (comparativo['no_productivas'] ?? 0).toDouble(), Colors.yellow),
        ];

        horasProductivas = (comparativo['productivas'] ?? 0).toDouble();
        horasNoProductivas = (comparativo['no_productivas'] ?? 0).toDouble();
        programadas = (comparativo['programadas'] ?? 0).toDouble();
        presencia = (comparativo['presencia'] ?? 0).toDouble();
        productivas = (comparativo['productivas'] ?? 0).toDouble();                   //SI VIENE NULL SE USA 0
      }

      if (tendencia != null) {
        final horas = tendencia['labels'] ?? [];
        final valores = tendencia['series'] ?? [];
        tendenciaHoras = List.generate(
          horas.length,
          (i) => TendenciaHoraData(horas[i], (valores[i] ?? 0).toDouble()),
        );
      }

      if (actividad != null) {
        final dias = List<String>.from(actividad['labels'] ?? []);
        final series = actividad['series']?['Total'] ?? [];

        final int totalDias = dias.length;
        final int desde = totalDias >= 6 ? totalDias - 6 : 0;
        final ultimosDias = dias.sublist(desde);
        final ultimosValores = series.sublist(desde).map((v) {
          if (v == null) return 0.0;
          return double.tryParse(v.toString()) ?? 0.0;
        }).toList();

        setState(() {
          actividadData = List.generate(ultimosDias.length,
              (i) => ActividadDiariaData(ultimosDias[i], ultimosValores[i]));
        });
      }

      final labels = body['top_empleados']['labels'] as List<dynamic>;
      final List<dynamic> positiva = body['top_empleados']['series']['Actividad positiva'];
      final List<dynamic> negativa = body['top_empleados']['series']['Actividad negativa'];

      topEmpleadosData.clear();
      for (int i = 0; i < labels.length; i++) {
        final nombre = labels[i].toString().trim();
        final pos = (i < positiva.length) ? double.tryParse(positiva[i].toString()) ?? 0 : 0;
        final neg = (i < negativa.length) ? double.tryParse(negativa[i].toString()) ?? 0 : 0;
        final porcentajeFinal = pos != 0 ? pos : -neg;
        topEmpleadosData.add(TopEmpleadoData(nombre: nombre, porcentaje: porcentajeFinal.toDouble()),);
      }

      setState(() {
        eficiencia = double.tryParse(resultado.toString()) ?? 0;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('yyyy-MM-dd');
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 136, 135, 135),
      appBar: AppBar(title: const Text('Dashboard de Organización')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    (fechaIni == null || fechaFin == null)
                      ? 'Seleccionar rango de fechas'
                      : 'Rango: ${formato.format(fechaIni!)} - ${formato.format(fechaFin!)}',
                  ),
                  onPressed: () async {
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                      initialDateRange: DateTimeRange(
                        start: fechaIni ?? DateTime.now(),
                        end: fechaFin ?? DateTime.now(),  
                      ),
                    );

                    if (picked != null) {
                      setState(() {
                        fechaIni = picked.start;
                        fechaFin = picked.end;
                      });
                      fetchDatosEficiencia();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFFF3B83C),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                ),
              ),


              const SizedBox(height: 30),
              CardEficiencia(eficiencia: eficiencia, isLoading: isLoading),
              const SizedBox(height: 30),
              
              CardEmbudo(cumplimientoLaboralData: cumplimientoLaboralData,isLoading: isLoading,),
              const SizedBox(height: 30),

              
              CardDonut(horasProductivas: horasProductivas, horasNoProductivas: horasNoProductivas, isLoading: isLoading),
              const SizedBox(height: 20),

              if (programadas != null && presencia != null && productivas != null)
                CardBarrasHoras(programadas: programadas, presencia: presencia, productivas: productivas),
              const SizedBox(height: 20),

              if (tendenciaHoras != null && tendenciaHoras!.isNotEmpty)
                CardTendenciaHora(tendenciaHoras: tendenciaHoras!),
              const SizedBox(height: 20),

              if (actividadData.isNotEmpty)
                Card(
                  color: Color(0xFF474747),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.view_week, color: Colors.green),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Actividad Diaria Últimos 7 Días',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                              ),
                            ),
                            IconButton(
                              icon: Icon(esLinea ? Icons.show_chart : Icons.bar_chart),
                              onPressed: () => setState(() => esLinea = !esLinea),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GraficoActividadDiaria(data: actividadData, esLinea: esLinea),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              if (topEmpleadosData.isNotEmpty)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.leaderboard, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Top empleados con más y menos actividad',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GraficoTopEmpleados(data: topEmpleadosData),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }
}

