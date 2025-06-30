import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> loginUser({
  required String email,
  required String password,
  required int lumina,
}) async {
  final url = Uri.parse('https://rhnube.com.pe/api/web_services/login');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'email': email,
      'password': password,
      'lumina': lumina,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("Login exitoso: $data");
  } else {
    print("Error: ${response.statusCode}");
    print("Respuesta: ${response.body}");
  }
}
