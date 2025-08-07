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
  List<int> _empleadosSeleccionados = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Inicializar con los empleados pre-seleccionados si existen
    _empleadosSeleccionados = widget.empleadosSeleccionadosIniciales ?? [];
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Obtener los IDs de los filtros empresariales seleccionados
      final filtrosIds = widget.filtrosEmpresariales
          .expand((g) => g.filtros)
          .where((f) => f.seleccionado)
          .map((f) => f.id.toString())
          .toList();

      // Llamar al servicio para obtener empleados
      final response = await widget.graphicsService.fetchEmpleados(
        filtrosIds: filtrosIds.isNotEmpty ? filtrosIds : null,
      );

      setState(() {
        _empleados = List<Map<String, dynamic>>.from(response['empleado'] ?? []);
        
        // Mantener selección existente si los empleados siguen disponibles
        _empleadosSeleccionados = _empleadosSeleccionados
            .where((id) => _empleados.any((e) => e['emple_id'] == id))
            .toList();
        
        // Notificar la selección actual
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
      _empleadosSeleccionados = _empleados.map((e) => e['emple_id'] as int).toList();
      _notificarSeleccion();
    });
  }

  void _deseleccionarTodos() {
    setState(() {
      _empleadosSeleccionados.clear();
      _notificarSeleccion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de acciones
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
                    tooltip: 'Recargar empleados',
                  ),
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: _seleccionarTodos,
                    tooltip: 'Seleccionar todos',
                  ),
                  IconButton(
                    icon: const Icon(Icons.deselect),
                    onPressed: _deseleccionarTodos,
                    tooltip: 'Deseleccionar todos',
                  ),
                ],
              ),
              Text(
                '${_empleadosSeleccionados.length}/${_empleados.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        
        // Indicador de carga o error
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        
        // Lista de empleados
        Expanded(
          child: _empleados.isEmpty
              ? const Center(child: Text('No hay empleados disponibles'))
              : _buildListaEmpleados(),
        ),
        
        // Botón para aplicar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              _notificarSeleccion();
              Navigator.of(context).pop();
            },
            child: const Text('Aplicar Filtros'),
          ),
        ),
      ],
    );
  }

  Widget _buildListaEmpleados() {
    return ListView.builder(
      itemCount: _empleados.length,
      itemBuilder: (context, index) {
        final empleado = _empleados[index];
        final empleadoId = empleado['emple_id'] as int;
        final nombreCompleto = '${empleado['perso_nombre']} '
            '${empleado['perso_apPaterno']} '
            '${empleado['perso_apMaterno']}'.trim();
        final estaSeleccionado = _empleadosSeleccionados.contains(empleadoId);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: estaSeleccionado 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
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
    );
  }
}