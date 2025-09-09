// Crea un nuevo archivo models/filtro_data.dart
class FiltroData {
  final String id;
  final String descripcion;
  bool seleccionado;

  FiltroData({
    required this.id,
    required this.descripcion,
    this.seleccionado = false,
  });

  factory FiltroData.fromJson(Map<String, dynamic> json) {
    return FiltroData(
      id: json['id'],
      descripcion: json['descripcion'],
    );
  }
}

class GrupoFiltros {
  final String categoria;
  final List<FiltroData> filtros;
  bool expandido;

  GrupoFiltros({
    required this.categoria,
    required this.filtros,
    this.expandido = false,
  });
}