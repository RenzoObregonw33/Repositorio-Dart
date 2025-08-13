/*import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';
import 'package:login/Models/detalle_diario_model.dart';

class LineaTiempoScreen extends StatefulWidget {
  final String token;
  final int organiId;
  final Map<String, dynamic> empleado;
  final DateTime fecha;

  const LineaTiempoScreen({
    Key? key,
    required this.token,
    required this.organiId,
    required this.empleado,
    required this.fecha,
  }) : super(key: key);

  @override
  State<LineaTiempoScreen> createState() => _LineaTiempoScreenState();
}

class _LineaTiempoScreenState extends State<LineaTiempoScreen> {
  late ApiGraphicsService _apiService;
  bool _cargando = true;
  DetalleDiarioResponse? _response;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _apiService = ApiGraphicsService(
      token: widget.token,
      organiId: widget.organiId,
    );
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _errorMessage = '';
    });

    try {
      final response = await _apiService.fetchDetalleDiarioEmpleado(
        fecha: widget.fecha,
        organiId: widget.organiId,
        idEmpleado: widget.empleado['idEmpleado'],
      );

      setState(() {
        _response = response;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
        _errorMessage = 'Error al cargar datos: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Línea de tiempo - ${widget.empleado['nombre']}'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)));
    }

    if (_response == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final eventos = _response!.data.lineaTiempo.data;
    
    return ListView.builder(
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        final evento = eventos[index];
        return _buildEventoCard(evento);
      },
    );
  }

  Widget _buildEventoCard(EventoLineaTiempo evento) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actividad: ${evento.nombreActividad}'),
            Text('Inicio: ${evento.inicioA} - Fin: ${evento.ultimaA}'),
            Text('Eficiencia: ${evento.division.toStringAsFixed(2)}%'),
            const SizedBox(height: 8),
            if (evento.imagenes.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: evento.imagenes.length,
                  itemBuilder: (context, index) {
                    final imagen = evento.imagenes[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => _mostrarImagenGrande(imagen.imagenGrande),
                        child: Image.network(
                          imagen.miniatura,
                          width: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarImagenGrande(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(url),
        ),
      ),
    );
  }
}*/