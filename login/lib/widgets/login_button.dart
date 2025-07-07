import 'package:flutter/material.dart';
import 'package:login/Apis/api_services.dart';
import 'package:login/screens/home_screen.dart';

class LoginButton extends StatelessWidget {
  // Controladores para obtener el texto de los campos de email y contraseña
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Function({String? emailError, String? passwordError}) onError;      //Fun q llama errores de validacion

  // Constructor
  const LoginButton({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        FocusScope.of(context).unfocus();                       //oculta el teclado

        final email = emailController.text.trim();              //Limpieza al ingresar los valores
        final password = passwordController.text;

        //Variables q se utilizara para los errores
        bool hasError = false;
        String? emailError;
        String? passwordError;

        // Validación del campo email
        if (email.isEmpty) {
          emailError = 'Este campo no debe estar vacío';
          hasError = true;
        } else if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
          emailError = 'Ingrese un email válido';
          hasError = true;
        }

        // Validación de la contraseña
        if (password.isEmpty) {
          passwordError = 'Este campo no debe estar vacío';
          hasError = true;
        }

        // Si hay errores, se notifica al widget padre y se detiene la ejecución
        if (hasError) {
          onError(emailError: emailError, passwordError: passwordError);
          return;
        }

        // Llama a la función loginUser para hacer la petición al servidor
        final result = await loginUser(
          email: email,
          password: password,
          lumina: 1,
        );

        //Condicional login exitoso
        if (result['success']) {
          final data = result['data'];
          final user = data['user'];
          final nombre = user['perso_nombre'] ?? '';
          final apellido = user['perso_apPaterno'] ?? '';
          final organizaciones = user['organizaciones'] ?? [];
          final token = (data['token'] ?? '').toString().trim(); // ✅ con .trim() y .toString() por seguridad
          print('🟢 Token recibido: $token');

          print("🟢 Nombre: $nombre");
          print("🟢 Apellido: $apellido");
          print("🟢 Organizaciones: $organizaciones");


          // Aquí guardamos el nombre, RUC y ID en una variable
          final organizacionDetalles = organizaciones.map<Map<String, dynamic>>((org) {
            final razonSocial = org['organi_razonSocial'] ?? 'Sin nombre';
            final ruc = org['organi_ruc'] ?? 'Sin RUC';
            final id = org['organi_id'] ?? 'Sin ID';
            return {
              'razonSocial': razonSocial,
              'ruc': ruc,
              'id': id,
            };
          }).toList();

          // Navega a la pantalla principal (HomeScreem) y espera un resultado
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreem(
                nombre: nombre,
                apellido: apellido,
                organizaciones: organizacionDetalles,
                token: token,
              ),
            ),
          );

          // Si el usuario cerró sesión desde la pantalla principal
          if (resultado == 'logout') {
            emailController.clear();
            passwordController.clear();
          }

        } else {        // Si el login falló, muestra el mensaje de error correspondiente
          final message = result['message'] ?? 'Error desconocido';

          if (message.toLowerCase().contains('correo')) {
            onError(emailError: message);
          } else {
            onError(passwordError: message);
          }
        }
      },
      child: const Text(
        'Iniciar Sesión',
        style: TextStyle(fontSize: 16, color: Colors.lightBlue),
      ),
    );
  }
}