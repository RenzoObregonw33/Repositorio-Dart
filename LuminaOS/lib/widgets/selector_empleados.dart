import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';
import 'package:login/Models/filtro_data.dart';

class SelectorEmpleado extends StatefulWidget {
  final ApiGraphicsService graphicsService;
  final List<GrupoFiltros> filtrosEmpresariales;
  final Function(String)? onError;
  final Function(List<int>)? onEmpleadosSeleccionados;
  final List<int>? empleadosSeleccionadosIniciales;
  final VoidCallback? onClose; 

  const SelectorEmpleado({
    super.key,
    required this.graphicsService,
    required this.filtrosEmpresariales,
    this.onError,
    this.onEmpleadosSeleccionados,
    this.empleadosSeleccionadosIniciales,
    this.onClose,
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
  bool _mostrarTodos = false;
  bool _mostrarSelector = true;

  @override
  void initState() {
    super.initState();
    _empleadosSeleccionados = widget.empleadosSeleccionadosIniciales ?? [];
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    if (!mounted) return;
    
    setState(() {
      _loading = true;
      _error = null;
      _mostrarTodos = false;
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

      if (!mounted) return;
      
      setState(() {
        _empleados = List<Map<String, dynamic>>.from(response['empleado'] ?? []);
        _empleadosFiltrados = List<int>.from(response['select'] ?? []);

        _empleadosSeleccionados = _empleadosSeleccionados
            .where((id) => _empleados.any((e) => e['emple_id'] == id))
            .toList();

        _notificarSeleccion();
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _error = e.toString());
      widget.onError?.call('Error al cargar empleados: $e');
      debugPrint('Error cargando empleados: $e');
    } finally {
      if (!mounted) return;
      
      setState(() => _loading = false);
    }
  }

  void _notificarSeleccion() {
    widget.onEmpleadosSeleccionados?.call(_empleadosSeleccionados);
  }

  void _toggleSeleccionEmpleado(int empleadoId) {
    if (!mounted) return;
    
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
    if (!mounted) return;
    
    setState(() {
      final empleadosVisibles = _mostrarTodos
          ? _empleados
          : _empleados.where((e) => _empleadosFiltrados.contains(e['emple_id'])).toList();

      _empleadosSeleccionados =
          empleadosVisibles.map((e) => e['emple_id'] as int).toList();
      _notificarSeleccion();
    });
  }

  void _deseleccionarTodos() {
    if (!mounted) return;
    
    setState(() {
      _empleadosSeleccionados.clear();
      _notificarSeleccion();
    });
  }

  void _toggleMostrarTodos() {
    if (!mounted) return;
    
    setState(() {
      _mostrarTodos = !_mostrarTodos;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7876E1)),
          strokeWidth: 3,
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_empleados.isEmpty) {
      return const Center(child: Text('No hay empleados disponibles'));
    }

    final empleadosAMostrar = _mostrarTodos
        ? _empleados
        : _empleados.where((e) => _empleadosFiltrados.contains(e['emple_id'])).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SELECCIÓN DE EMPLEADOS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3E2B6B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Color(0xFF3E2B6B)),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF3E2B6B)),
                      onPressed: _cargarEmpleados,
                      tooltip: 'Recargar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.select_all, color: Color(0xFF3E2B6B)),
                      onPressed: _seleccionarTodos,
                      tooltip: 'Seleccionar todos',
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear_all, color: Color(0xFF3E2B6B)),
                      onPressed: _deseleccionarTodos,
                      tooltip: 'Deseleccionar todos',
                    ),
                    IconButton(
                      icon: Icon(
                        _mostrarTodos ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF3E2B6B),
                      ),
                      onPressed: _toggleMostrarTodos,
                      tooltip: _mostrarTodos ? 'Ocultar no filtrados' : 'Mostrar todos',
                    ),
                  ],
                ),
                Text(
                  'Mostrando: ${empleadosAMostrar.length}/${_empleados.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: empleadosAMostrar.length,
              itemBuilder: (context, index) {
                final empleado = empleadosAMostrar[index];
                final empleadoId = empleado['emple_id'] as int;
                final nombreCompleto =
                    '${empleado['perso_nombre']} ${empleado['perso_apPaterno']} ${empleado['perso_apMaterno']}'.trim();
                final estaFiltrado = _empleadosFiltrados.contains(empleadoId);
                final estaSeleccionado = _empleadosSeleccionados.contains(empleadoId);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: estaSeleccionado
                        ? Colors.blue[100]
                        : estaFiltrado
                            ? Colors.green[50]
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(
                      nombreCompleto,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('ID: $empleadoId'),
                    value: estaSeleccionado,
                    onChanged: (_) => _toggleSeleccionEmpleado(empleadoId),
                    activeColor: const Color(0xFF7956A8),
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                _notificarSeleccion();
                widget.onClose?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7876E1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 1,
              ),
              child: const Text(
                'Aplicar Filtros',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}