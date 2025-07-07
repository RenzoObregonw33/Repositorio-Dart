import 'dart:convert';                    // Para convertir datos JSON
import 'package:flutter/material.dart';   // Widgets de Flutter
import 'package:http/http.dart' as http;  // Cliente HTTP para hacer peticiones
import 'package:intl/intl.dart';          // Para formatear fechas
import 'package:login/widgets/grafico_eficiencia.dart'; // Widget personalizado para mostrar el gráfico
//import 'package:shared_preferences/shared_preferences.dart';


class DashboardScreen extends StatefulWidget {
  final int organiId;
  final String token;
  const DashboardScreen({super.key, required this.organiId, required this.token});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double? eficiencia;
  bool isLoading = true;
  DateTime? fechaIni;
  DateTime? fechaFin;


  @override
  void initState() {
    super.initState();
    fetchDatosEficiencia();
  }

  Future<void> fetchDatosEficiencia() async {
    if (fechaIni == null || fechaFin == null) return;

    final formato = DateFormat('yyyy-MM-dd');
    final url = Uri.parse('https://rhnube.com.pe/api/v5/graficsLumina');

    setState(() {
      isLoading = true;
      eficiencia = null;
    });

    try {

      print('Enviando a la API: ${formato.format(fechaIni!)} → ${formato.format(fechaFin!)}');
      final token = widget.token;

      if (token.isEmpty) {
        print('⚠️ Token no encontrado. No puedes acceder a la API.');
        return;
      }

      print('🔐 Token enviado: Bearer ${widget.token}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': widget.token,
        },
        body: jsonEncode({
          'fecha_ini': formato.format(fechaIni!),
          'fecha_fin': formato.format(fechaFin!),
          'organi_id': widget.organiId,
        }),
      );

      print('Respuesta: ${response.body}');

      final body = jsonDecode(response.body);
      final resultado = body['eficiencia']?['resultado'];

      setState(() {
        eficiencia = double.tryParse(resultado.toString()) ?? 0;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        eficiencia = 0;
        isLoading = false;
      });
    }
  }


  Future<void> _seleccionarFecha({required bool esInicio}) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2023),
    lastDate: DateTime.now(),
  );

  if (picked != null) {
    setState(() {
      if (esInicio) {
        fechaIni = picked;
      } else {
        fechaFin = picked;
      }
    });

    if (fechaIni != null && fechaFin != null) {
      setState(() => isLoading = true);
      fetchDatosEficiencia();
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard de Organización')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _seleccionarFecha(esInicio: true),
                  child: Text(fechaIni == null
                      ? 'Seleccionar inicio'
                      : 'Inicio: ${formato.format(fechaIni!)}'),
                ),
                ElevatedButton(
                  onPressed: () => _seleccionarFecha(esInicio: false),
                  child: Text(fechaFin == null
                      ? 'Seleccionar fin'
                      : 'Fin: ${formato.format(fechaFin!)}'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (isLoading)
              CircularProgressIndicator()
            else if (eficiencia != null)
              GraficoEficiencia(eficiencia: eficiencia!)
            else
              Text('Seleccione fechas para ver el gráfico.'),
          ],
        ),
      ),
    );
  }
}
