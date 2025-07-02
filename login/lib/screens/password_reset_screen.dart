import 'package:flutter/material.dart';
import 'package:login/Apis/api_services.dart';

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

  Future<void> _enviarSolicitud() async {

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _error = 'Ingresa tu correo electrónico');
    }
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      _mostrarMensaje('Correo inválido', error: true);
      return;
    }

    final result = await resetPassword(email: email);
    _mostrarMensaje(result['message'], error: !result['success']);
  }

  void _mostrarMensaje(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? const Color.fromARGB(255, 4, 4, 4) : const Color.fromARGB(255, 11, 15, 11),
        duration: Duration(seconds: 3),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFF5F8FC),
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