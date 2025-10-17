import 'dart:convert';                            //Convierte datos de Json
import 'package:http/http.dart' as http;          //Para hacer peticiones en http
import 'package:shared_preferences/shared_preferences.dart';


// Función asíncrona que intenta iniciar sesión con email, contraseña y lumina
Future<Map<String, dynamic>> loginUser({
  required String email,
  required String password,
  required int lumina,
}) async {
  final url = Uri.parse('https://rhnube.com.pe/api/web_services/login');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'lumina': lumina,
      }),
    );

    print('════════════════ RESPONSE ════════════════');
    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');

    final Map<String, dynamic> responseData = {
      'success': false,
      'message': 'Error desconocido'
    };

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final fotoUrl = data['user']['foto_url'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_photo_url', fotoUrl);
        
        responseData['success'] = true;
        responseData['data'] = data;
        responseData['message'] = 'Login exitoso';
      } catch (e) {
        responseData['message'] = 'Error al procesar respuesta: $e';
      }
    } else if (response.statusCode == 401) {
      responseData['message'] = 'Contraseña Incorrecta';
    } else if (response.statusCode == 422) {
      responseData['message'] = 'Debe ingresar correo y contraseña';
    } else {
      responseData['message'] = 'Error: ${response.statusCode}';
    }

    return responseData;

  } catch (e) {
    return {
      'success': false,
      'message': 'Ups, revisa tu conexión a internet'
    };
  }
}

// Función asíncrona para solicitar el reinicio de contraseña
Future<Map<String, dynamic>> resetPassword({required String email}) async {
  // URL del endpoint para resetear contraseña
  final url = Uri.parse('https://rhnube.com.pe/api/web_services/password-reset');

  try {
    // Se envía una petición POST con el email
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    // Imprime el código de estado y el cuerpo de la respuesta
    print(response.statusCode);
    print(response.body);
    
    // Si el correo fue enviado correctamente
    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Correo enviado correctamente'};

    // Si hubo un error al enviar el correo
    } else if (response.statusCode == 400) {
      return {'success': false, 'message': 'Correo no enviado'};

    // Si hay errores de validación (por ejemplo, email inválido)
    } else if (response.statusCode == 422) {
      final body = jsonDecode(response.body);
      final errors = body['errors'] ?? {};
      final emailError = errors['email']?[0];

      return {
        'success': false,
        'emailError': emailError,
        'message': body['message'] ?? 'Error de validación'
      };
    } else {                                      //otros errores
      return {'success': false, 'message': 'Error: ${response.statusCode}'};
    }
  } catch (e) {                                   //Si ocurre otro error como red
    return {'success': false, 'message': 'Ups, revisa tu conexión a internet'};
  }
}

