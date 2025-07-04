import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:login/widgets/grafico_eficiencia.dart';

class DashboardScreen extends StatefulWidget {
  final int organiId;

  const DashboardScreen({super.key, required this.organiId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double? eficiencia;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDatosEficiencia();
  }

  Future<void> fetchDatosEficiencia() async {
    final hoy = DateTime.now();
    final sieteDiasAtras = hoy.subtract(Duration(days: 7));
    final fechaIni = DateFormat('yyyy-MM-dd').format(sieteDiasAtras);
    final fechaFin = DateFormat('yyyy-MM-dd').format(hoy);

    final url = Uri.parse('https://rhnube.com.pe/api/v5/graficsLumina');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fecha_ini': fechaIni,
          'fecha_fin': fechaFin,
          'organi_id': widget.organiId,
        }),
      );

      final body = jsonDecode(response.body);
      final resultado = body['eficiencia']?['resultado'];

      if (resultado != null) {
        setState(() {
          eficiencia = double.tryParse(resultado.toString()) ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          eficiencia = 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        eficiencia = 0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard de Organización')),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : GraficoEficiencia(eficiencia: eficiencia ?? 0),
      ),
    );
  }
}
