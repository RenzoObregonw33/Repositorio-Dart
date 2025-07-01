import 'package:flutter/material.dart';
import 'package:login/api_services.dart';
import 'package:login/screems/home_screem.dart';

class LoginButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Function({String? emailError, String? passwordError})
  onError; // Para mostrar error en el LoginScreen

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
        } else if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$').hasMatch(email)) {
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
          final nombre = data['nombre'] ?? data['usuario']?['nombre'] ?? '';
          final apellido =
              data['apellido'] ?? data['usuario']?['apellido'] ?? '';

          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreem(
                nombre: nombre,
                apellido: apellido,
                ruc: '',
              ),
            ),
          );
          if (resultado == 'logout') {
            emailController.clear();
            passwordController.clear();
          }

        } else {
          onError(
            emailError: result['message'],
            passwordError: result['message'],
          );
        }
      },
      child: const Text(
        'Iniciar Sesión',
        style: TextStyle(fontSize: 16, color: Colors.lightBlue),
      ),
    );
  }
}
