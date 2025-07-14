import 'package:flutter/material.dart';
import 'package:login/widgets/grafico_eficiencia.dart';

class CardEficiencia extends StatelessWidget {
  final double? eficiencia;
  final bool isLoading;
  const CardEficiencia({super.key, this.eficiencia, required this.isLoading});

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
                Icon(Icons.speed, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '% Eficiencia en ejecución de actividades',
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
            Center(
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(),
                    )
                  : eficiencia != null
                      ? GraficoEficiencia(eficiencia: eficiencia!)
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'Seleccione fechas para ver el gráfico.',
                          ),
                        ),
            ),
          ],
        ),
      ),
    );   
  }
}