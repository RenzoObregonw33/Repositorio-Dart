import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';
import 'package:login/Models/filtro_data.dart';

class SelectorEmpleado extends StatefulWidget {
  final ApiGraphicsService graphicsService;
  final List<GrupoFiltros> filtrosEmpresariales;
  final Function(String)? onError;
  final Function(List<int>)? onEmpleadosSeleccionados;
  final List<int>? empleadosSeleccionadosIniciales;

  const SelectorEmpleado({
    super.key,
    required this.graphicsService,
    required this.filtrosEmpresariales,
    this.onError, 
    this.onEmpleadosSeleccionados,
    this.empleadosSeleccionadosIniciales,
  });

  @override
  State<SelectorEmpleado> createState() => _SelectorEmpleadoState();
}

class _SelectorEmpleadoState extends State<SelectorEmpleado> {
  List<Map<String, dynamic>> _empleados = [];
  List<int> _empleadosFiltrados = [];
  List<int> _empleadosSeleccionados = [];
  bool _loading = false;
  String? _error;
  bool _mostrarTodos = false; // Nuevo estado para controlar qué mostrar

  @override
  void initState() {
    super.initState();
    _empleadosSeleccionados = widget.empleadosSeleccionadosIniciales ?? [];
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    setState(() {
      _loading = true;
      _error = null;
      _mostrarTodos = false; // Resetear a solo mostrar filtrados al recargar
    });

    try {
      final filtrosIds = widget.filtrosEmpresariales
          .expand((g) => g.filtros)
          .where((f) => f.seleccionado)
          .map((f) => f.id.toString())
          .toList();

      final response = await widget.graphicsService.fetchEmpleados(
        filtrosIds: filtrosIds.isNotEmpty ? filtrosIds : null,
      );

      setState(() {
        _empleados = List<Map<String, dynamic>>.from(response['empleado'] ?? []);
        _empleadosFiltrados = List<int>.from(response['select'] ?? []);
        
        _empleadosSeleccionados = _empleadosSeleccionados
            .where((id) => _empleados.any((e) => e['emple_id'] == id))
            .toList();
        
        _notificarSeleccion();
      });
    } catch (e) {
      setState(() => _error = e.toString());
      widget.onError?.call('Error al cargar empleados: $e');
      debugPrint('Error cargando empleados: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _notificarSeleccion() {
    widget.onEmpleadosSeleccionados?.call(_empleadosSeleccionados);
  }

  void _toggleSeleccionEmpleado(int empleadoId) {
    setState(() {
      if (_empleadosSeleccionados.contains(empleadoId)) {
        _empleadosSeleccionados.remove(empleadoId);
      } else {
        _empleadosSeleccionados.add(empleadoId);
      }
      _notificarSeleccion();
    });
  }

  void _seleccionarTodos() {
    setState(() {
      // Solo seleccionar los empleados visibles
      final empleadosVisibles = _mostrarTodos 
          ? _empleados 
          : _empleados.where((e) => _empleadosFiltrados.contains(e['emple_id'])).toList();
          
      _empleadosSeleccionados = empleadosVisibles.map((e) => e['emple_id'] as int).toList();
      _notificarSeleccion();
    });
  }

  void _deseleccionarTodos() {
    setState(() {
      _empleadosSeleccionados.clear();
      _notificarSeleccion();
    });
  }

  void _toggleMostrarTodos() {
    setState(() {
      _mostrarTodos = !_mostrarTodos;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));
    if (_empleados.isEmpty) return const Center(child: Text('No hay empleados disponibles'));

    // Filtrar empleados a mostrar según el estado
    final empleadosAMostrar = _mostrarTodos
        ? _empleados
        : _empleados.where((e) => _empleadosFiltrados.contains(e['emple_id'])).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _cargarEmpleados,
                    tooltip: 'Recargar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: _seleccionarTodos,
                    tooltip: 'Seleccionar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.deselect),
                    onPressed: _deseleccionarTodos,
                    tooltip: 'Deseleccionar',
                  ),
                  IconButton(
                    icon: Icon(_mostrarTodos ? Icons.visibility_off : Icons.visibility),
                    onPressed: _toggleMostrarTodos,
                    tooltip: _mostrarTodos ? 'Ocultar no filtrados' : 'Mostrar todos',
                  ),
                ],
              ),
              Text(
                'Mostrando: ${empleadosAMostrar.length}/${_empleados.length}',  //| ' 'Selección: ${_empleadosSeleccionados.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: RefreshIndicator(
            onRefresh: _cargarEmpleados,
            child: ListView.builder(
              itemCount: empleadosAMostrar.length,
              itemBuilder: (context, index) {
                final empleado = empleadosAMostrar[index];
                final empleadoId = empleado['emple_id'] as int;
                final nombreCompleto = '${empleado['perso_nombre']} '
                    '${empleado['perso_apPaterno']} '
                    '${empleado['perso_apMaterno']}'.trim();
                final estaFiltrado = _empleadosFiltrados.contains(empleadoId);
                final estaSeleccionado = _empleadosSeleccionados.contains(empleadoId);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  color: estaSeleccionado 
                      ? Colors.blue[300] 
                      : estaFiltrado 
                          ? Colors.green[500] 
                          : null,
                  child: ListTile(
                    title: Text(nombreCompleto),
                    subtitle: Text('ID: $empleadoId'),
                    trailing: Checkbox(
                      value: estaSeleccionado,
                      onChanged: (_) => _toggleSeleccionEmpleado(empleadoId),
                    ),
                    onTap: () => _toggleSeleccionEmpleado(empleadoId),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}