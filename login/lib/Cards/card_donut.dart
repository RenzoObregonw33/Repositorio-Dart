import 'package:flutter/material.dart';
import 'package:login/widgets/grafico_donut.dart';

class CardDonut extends StatelessWidget {
  final double? horasProductivas;
  final double? horasNoProductivas;
  const CardDonut({super.key, this.horasProductivas, this.horasNoProductivas});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Distribución de Actividad Laboral',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GraficoDonut(
              productivas: horasProductivas!,
              noProductivas: horasNoProductivas!,
            ),
          ],
        ),
      ),
    );
  }
}