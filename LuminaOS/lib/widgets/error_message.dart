import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String mensaje;

  const ErrorMessageWidget({
    super.key,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: Color(0xFF3E2B6B),
            ),
            const SizedBox(height: 16),
            Text(
              "No se pudo cargar los datos",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
