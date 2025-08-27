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
    return SizedBox(
      width: double.infinity, // 👉 Igual que los TextField
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF7775E2), // Color igual a tus íconos
          foregroundColor: Colors.white,
          elevation: 0, // Sin sombra (como TextField)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Igual que los TextField
          ),
          padding: const EdgeInsets.symmetric(vertical: 16), // Altura similar al TextField
        ),
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
            final user = data['user'];
            final nombre = user['perso_nombre'] ?? '';
            final apellido = user['perso_apPaterno'] ?? '';
            final organizaciones = user['organizaciones'] ?? [];
            final token = (data['token'] ?? '').toString().trim();
            final fotoUrl = user['foto_url'] ?? 'https://rhnube.com.pe/fotosUser/default.png';

            print('🟢 Token recibido: $token'); print("🟢 Nombre: $nombre"); print("🟢 Apellido: $apellido"); print("🟢 Organizaciones: $organizaciones");

            final organizacionDetalles = organizaciones.map<Map<String, dynamic>>((org) {
              return {
                'razonSocial': org['organi_razonSocial'] ?? 'Sin nombre',
                'ruc': org['organi_ruc'] ?? 'Sin RUC',
                'id': org['organi_id']?.toString() ?? '0',
                'tipo': org['organi_tipo'] ?? 'No especificado',
                'cantidad_empleados_lumina': org['cantidad_empleados_lumina'] ?? 0,
              };
            }).toList();

            final resultado = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreem(
                  nombre: nombre,
                  apellido: apellido,
                  organizaciones: organizacionDetalles,
                  token: token,
                  rolNombre: data['user']['rol_nombre'],
                  rolId: data['user']['rol_id'],
                  fotoUrl: fotoUrl,
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
          style: TextStyle(
            fontSize: 16,
            fontFamily: '-apple-system',
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
