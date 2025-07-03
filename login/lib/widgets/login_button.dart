import 'package:flutter/material.dart';
import 'package:login/Apis/api_services.dart';
import 'package:login/screens/home_screen.dart';

class LoginButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Function({String? emailError, String? passwordError}) onError;

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
        FocusScope.of(context).unfocus();

        final email = emailController.text.trim();
        final password = passwordController.text;

        bool hasError = false;

        String? emailError;
        String? passwordError;

        if (email.isEmpty) {
          emailError = 'Este campo no debe estar vacío';
          hasError = true;
        } else if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
          emailError = 'Ingrese un email válido';
          hasError = true;
        }


        if (password.isEmpty) {
          passwordError = 'Este campo no debe estar vacío';
          hasError = true;
        }

        if (hasError) {
          onError(emailError: emailError, passwordError: passwordError);
          return;
        }

        final result = await loginUser(
          email: email,
          password: password,
          lumina: 1,
        );

        if (result['success']) {
          final data = result['data'];
          final nombre = data['user']?['perso_nombre'] ?? '';
          final apellido = data['user']?['perso_apPaterno'] ?? '';

          final organizaciones = data['user']?['organizaciones']??[];

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

          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreem(
                nombre: nombre,
                apellido: apellido,
                organizaciones: organizacionDetalles,
              ),
            ),
          );

          if (resultado == 'logout') {
            emailController.clear();
            passwordController.clear();
          }

        } else {
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