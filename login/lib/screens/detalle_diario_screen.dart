import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';


class DetalleDiarioScreen extends StatefulWidget {
  final String token;
  final int organiId;

  const DetalleDiarioScreen({
    Key? key,
    required this.token,
    required this.organiId,
  }) : super(key: key);

  @override
  State<DetalleDiarioScreen> createState() => _DetalleDiarioScreenState();
}

class _DetalleDiarioScreenState extends State<DetalleDiarioScreen> {
  late ApiGraphicsService _apiService;
  bool _cargando = true;
  List<dynamic> _empleados = [];
  String _errorMessage = '';
  int _totalEmpleados = 0;

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
      final response = await _apiService.fetchDetalleDiarioEmpleados(
        fecha: DateTime.now(),
        start: 0,
        limite: 20,
        orderColumn: 'nombre',
        orderDir: 'asc',
        tipo: 'todos',
        busq: "",
      );

      setState(() {
        _empleados = response['data'] ?? [];
        _totalEmpleados = response['recordsTotal'] ?? 0;
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
      backgroundColor: Colors.black.withValues(alpha:  0.05),
      appBar: AppBar(
        title: const Text("Detalle Diario de Empleados"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_empleados.isEmpty) {
      return const Center(
        child: Text(
          'No hay empleados registrados',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        _buildResumen(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _empleados.length,
            itemBuilder: (context, index) {
              final empleado = _empleados[index];
              return _buildEmpleadoCard(empleado);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResumen() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFA528), Color(0xFFF77B09),],
          stops: [0.1, 0.9],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResumenItem('Total', _totalEmpleados.toString()),
          _buildResumenItem('Mostrando', _empleados.length.toString()),
        ],
      ),
    );
  }

  Widget _buildResumenItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpleadoCard(Map<String, dynamic> empleado) {
    final nombreCompleto = '${empleado['nombre']} ${empleado['apPaterno']} ${empleado['apMaterno']}';
    final horasTrabajadas = _convertirSegundosAHorasMinutos(empleado['tiempoT'] ?? 0);
    final division = empleado['division'] is int 
        ? (empleado['division'] as int).toDouble() 
        : empleado['division'] ?? 0.0;

    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nombreCompleto.trim(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID: ${empleado['idEmpleado']}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            _buildInfoRow('Horario', empleado['horario_descripcion'] ?? 'No especificado'),
            
            Row(
              children: [
                Expanded(child: _buildInfoRow('Inicio', empleado['inicioA'] ?? '--:--:--')),
                Expanded(child: _buildInfoRow('Última', empleado['ultimaA'] ?? '--:--:--')),
                Expanded(child: _buildInfoRow('Horas', horasTrabajadas)),
              ],
            ),
            
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: division / 100,
              backgroundColor: Colors.grey[200],
              color: _getProgressColor(division),
              minHeight: 8,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${division.toStringAsFixed(1)}% completado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _convertirSegundosAHorasMinutos(int segundos) {
    final horas = (segundos / 3600).floor();
    final minutos = ((segundos % 3600) / 60).floor();
    return '$horas h $minutos m';
  }

  Color _getProgressColor(double porcentaje) {
    if (porcentaje >= 80) return Colors.green;
    if (porcentaje >= 50) return Colors.blue;
    if (porcentaje >= 30) return Colors.orange;
    return Colors.red;
  }
}