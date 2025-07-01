import 'package:flutter/material.dart';

class PasswordResetScreen extends StatefulWidget {
  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _enviarSolicitud() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Ingresa tu correo electrónico');
    } else if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$').hasMatch(email)) {
      setState(() => _error = 'Correo inválido');
    } else {
      setState(() => _error = null);
      // Aquí llamas a tu función para enviar la solicitud de recuperación
      // Ejemplo: await enviarSolicitudReset(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se ha enviado un correo de recuperación.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                errorText: _error,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enviarSolicitud,
              child: Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
