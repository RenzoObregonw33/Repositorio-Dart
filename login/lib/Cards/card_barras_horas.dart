import 'package:flutter/material.dart';
import 'package:login/widgets/grafico_barras_horas.dart';

class CardBarrasHoras extends StatelessWidget {
  final double? programadas;
  final double? presencia;
  final double? productivas;
  const CardBarrasHoras({super.key, this.programadas, this.presencia, this.productivas});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.schedule, color: Colors.indigo),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Grado de Ejecución de Horas Programadas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GraficoBarrasHoras(
              programadas: programadas!,
              presencia: presencia!,
              productivas: productivas!,
            )
          ],
        ),
      ),
    );
  }
}