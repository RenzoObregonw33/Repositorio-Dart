

class HomeData {
   //Parametros
  final String nombre;
  final String apellido;
  final String token;
  final List<Map<String, dynamic>> organizaciones;
  final String rolNombre; // Nuevo
  final int rolId; // Nuevo
  final String fotoUrl; // Nuevo

  //Constructor
  const HomeData({
    required this.nombre,
    required this.apellido,
    required this.organizaciones,
    required this.token,
    required this.rolNombre,
    required this.rolId,
    required this.fotoUrl,
  });
}