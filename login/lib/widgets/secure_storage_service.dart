import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static SharedPreferences? _prefs;

  // Inicializar las preferencias (DEBE llamarse primero)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Guardar credenciales
  static Future<void> saveCredentials(String email, String password) async {
    if (_prefs == null) await init();
    await _prefs!.setString('user_email', email);
    await _prefs!.setString('user_password', password);
    print('🔐 Credenciales guardadas: $email');
  }

  // Obtener credenciales guardadas
  static Future<Map<String, String>> getCredentials() async {
    if (_prefs == null) await init();
    String email = _prefs!.getString('user_email') ?? '';
    String password = _prefs!.getString('user_password') ?? '';
    print('🔐 Credenciales recuperadas: $email');
    return {'email': email, 'password': password};
  }

  // Eliminar credenciales
  static Future<void> deleteCredentials() async {
    if (_prefs == null) await init();
    await _prefs!.remove('user_email');
    await _prefs!.remove('user_password');
    print('❌❌❌ CREDENCIALES ELIMINADAS - ESTO NO DEBERÍA PASAR ❌❌❌');
  }

  // Verificar si hay credenciales guardadas
  static Future<bool> hasCredentials() async {
    if (_prefs == null) await init();
    String? email = _prefs!.getString('user_email');
    return email != null && email.isNotEmpty;
    
  }
}