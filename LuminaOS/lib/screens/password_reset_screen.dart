import 'package:flutter/material.dart';
import 'package:login/Apis/api_services.dart';

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
  void dispose() {                        //Liberar datos del controller
    _emailController.dispose();
    super.dispose();
  }

  // Función asincrónica que se ejecuta al presionar el botón "Enviar"
  Future<void> _enviarSolicitud() async {

    // Obtiene el texto del campo de email y elimina espacios en blanco
    final email = _emailController.text.trim();

    // Verifica si el campo está vacío
    if (email.isEmpty) {
      setState(() => _error = 'Ingresa tu correo electrónico');
    }

    // Verifica si el formato del correo es válido usando una expresión regular
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      _mostrarMensaje('Correo inválido', error: true);
      return;
    }

    final result = await resetPassword(email: email);
    // Muestra el mensaje devuelto por la API, indicando si fue exitoso o no
    _mostrarMensaje(result['message'], error: !result['success']);
  }

  // Función para mostrar un mensaje emergente (SnackBar) en la parte inferior de la pantalla
  void _mostrarMensaje(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(                  //
      SnackBar(
        content: Text(mensaje, style: TextStyle(color: Colors.white),),
        backgroundColor: error ? const Color.fromARGB(255, 4, 4, 4) : const Color.fromARGB(255, 11, 15, 11),
        duration: Duration(seconds: 3),                         //Duracion del mensaje
      ),
    );
  }

  // Método que construye la interfaz de usuario
  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(backgroundColor: Color(0xFF3D2A6A), iconTheme: IconThemeData( color: Colors.white),         //Color de los iconos
        title: Text('Recuperar contraseña', style: TextStyle(color: Colors.white, fontFamily: 'Inter'),)
      ),          //Barra superior
      body: Padding(
        padding: const EdgeInsets.all(20.0),                        //Espacio interno
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Introduce tu dirección de correo electronico:', style: TextStyle(fontFamily: 'Nunito'),),
            SizedBox(height: 20),
            TextField(                                        //Se ingresa el correo
              controller: _emailController,                   //Control
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                labelStyle: TextStyle(fontFamily: '-apple-system',color: Colors.grey),
                prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF3D2A6A),),
                errorText: _error,                            //Mustra un mensaje de error si no existe
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            // Botón para enviar la solicitud de recuperación
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7775E2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                    ),
                    onPressed: _enviarSolicitud,
                    child: Text('Enviar Notificación', style: TextStyle(fontFamily: 'Inter'),),
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