import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';
import 'package:login/Models/filtro_data.dart';

class SelectorEmpleado extends StatefulWidget {
  final ApiGraphicsService graphicsService;
  final List<GrupoFiltros> filtrosEmpresariales;
  final Function(String)? onError;
  final Function(List<int>)? onEmpleadosSeleccionados;

  const SelectorEmpleado({
    super.key,
    required this.graphicsService,
    required this.filtrosEmpresariales,
    this.onError, 
    this.onEmpleadosSeleccionados,
  });

  @override
  State<SelectorEmpleado> createState() => _SelectorEmpleadoState();
}

class _SelectorEmpleadoState extends State<SelectorEmpleado> {
  List<Map<String, dynamic>> _empleados = [];
  List<int> _empleadosFiltrados = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final filtrosIds = widget.filtrosEmpresariales
          .expand((g) => g.filtros)
          .where((f) => f.seleccionado)
          .map((f) => f.id)
          .toList();

      final response = await widget.graphicsService.fetchEmpleados(
        filtrosIds: filtrosIds.isNotEmpty ? filtrosIds : null,
      );

      setState(() {
        _empleados = List<Map<String, dynamic>>.from(response['empleado']);
        _empleadosFiltrados = List<int>.from(response['select'] ?? []);
      });
    } catch (e) {
      setState(() => _error = e.toString());
      widget.onError?.call(e.toString());
      debugPrint('Error cargando empleados: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Text('Error: $_error');
    if (_empleados.isEmpty) return const Text('No hay empleados disponibles');

    return Column(
      children: [
        _buildContadorFiltrados(),
        Expanded(child: _buildListaEmpleados()),
      ],
    );
  }

  Widget _buildContadorFiltrados() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Mostrando ${_empleadosFiltrados.length} de ${_empleados.length} empleados',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListaEmpleados() {
    return RefreshIndicator(
      onRefresh: _cargarEmpleados,
      child: ListView.builder(
        itemCount: _empleados.length,
        itemBuilder: (context, index) {
          final emp = _empleados[index];
          final estaFiltrado = _empleadosFiltrados.contains(emp['emple_id']);
          final nombreCompleto = '${emp['perso_nombre']} ${emp['perso_apPaterno']} ${emp['perso_apMaterno']}'.trim();

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: estaFiltrado ? Colors.blue[50] : null,
            child: ListTile(
              title: Text(nombreCompleto),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${emp['emple_id']}'),
                  if (estaFiltrado) 
                    const Text('Coincide con los filtros', 
                      style: TextStyle(color: Colors.green)),
                ],
              ),
              trailing: estaFiltrado 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
          );
        },
      ),
    );
  }
}