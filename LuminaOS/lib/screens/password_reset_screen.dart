import 'package:flutter/material.dart';
import 'package:luminaos/Apis/api_services.dart';

//Widget con estado
class PasswordResetScreen extends StatefulWidget {
  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

// Estado asociado al widget PasswordResetScreen
class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _error;
  bool _enviado = false; // 🔹 Nueva bandera para controlar el botón

  @override
  void initState() {
    super.initState();

    // Enfocar automáticamente al iniciar
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  // Método que se llama cuando el widget se elimina de la pantalla
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Función asincrónica que se ejecuta al presionar el botón "Enviar"
  Future<void> _enviarSolicitud() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _error = 'Ingresa tu correo electrónico');
      return;
    }

    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      _mostrarMensaje('Correo inválido', error: true);
      return;
    }

    final result = await resetPassword(email: email);

    // Si la API responde éxito, bloqueamos el botón
    if (result['success'] == true) {
      setState(() => _enviado = true); // 🔹 Deshabilitar botón
    }

    _mostrarMensaje(result['message'], error: !result['success']);
  }

  // Función para mostrar un mensaje emergente
  void _mostrarMensaje(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF3D2A6A),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3D2A6A),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Recuperar contraseña',
          style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Introduce tu dirección de correo electronico:',
              style: TextStyle(fontFamily: 'Nunito'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                labelStyle: TextStyle(
                  fontFamily: '-apple-system',
                  color: Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Color(0xFF3D2A6A),
                ),
                errorText: _error,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            // Botón para enviar la solicitud
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _enviado
                          ? Colors.grey
                          : Color(
                              0xFF7775E2,
                            ), // 🔹 Cambia a gris cuando está deshabilitado
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _enviado
                        ? null
                        : _enviarSolicitud, // 🔹 Bloqueo del botón
                    child: Text(
                      'Enviar notificación',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
