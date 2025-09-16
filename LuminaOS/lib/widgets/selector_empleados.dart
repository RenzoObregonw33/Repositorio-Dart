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
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _todosSeleccionados = false;

  @override
  void initState() {
    super.initState();
    _empleadosSeleccionados = widget.empleadosSeleccionadosIniciales ?? [];
    _searchController = TextEditingController();
    _cargarEmpleados();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarEmpleados() async {
    if (!mounted) return;
    
    setState(() {
      _loading = true;
      _error = null;
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

        _actualizarEstadoTodosSeleccionados();
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
      _actualizarEstadoTodosSeleccionados();
      _notificarSeleccion();
    });
  }

  void _toggleSeleccionTodos() {
    if (!mounted) return;
    
    setState(() {
      final empleadosVisibles = _obtenerEmpleadosVisibles();
      if (_todosSeleccionados) {
        _empleadosSeleccionados.clear();
      } else {
        _empleadosSeleccionados =
            empleadosVisibles.map((e) => e['emple_id'] as int).toList();
      }
      _todosSeleccionados = !_todosSeleccionados;
      _notificarSeleccion();
    });
  }

  void _actualizarEstadoTodosSeleccionados() {
    final empleadosVisibles = _obtenerEmpleadosVisibles();
    _todosSeleccionados = empleadosVisibles.isNotEmpty &&
        _empleadosSeleccionados.length == empleadosVisibles.length;
  }

  List<Map<String, dynamic>> _obtenerEmpleadosVisibles() {
    // Siempre mostrar todos los empleados (eliminada la opción de filtrar)
    List<Map<String, dynamic>> empleadosVisibles = _empleados;
    
    // Aplicar filtro de búsqueda por apellidos
    if (_searchQuery.isNotEmpty) {
      empleadosVisibles = empleadosVisibles.where((empleado) {
        final nombre = empleado['perso_nombre']?.toString().toLowerCase() ?? '';
        final apPaterno = empleado['perso_apPaterno']?.toString().toLowerCase() ?? '';
        final apMaterno = empleado['perso_apMaterno']?.toString().toLowerCase() ?? '';
        
        // Buscar en nombre y apellidos
        return nombre.contains(_searchQuery.toLowerCase()) ||
               apPaterno.contains(_searchQuery.toLowerCase()) ||
               apMaterno.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return empleadosVisibles;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;
    
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
          'No fue posible cargar la información de empleados en este momento.',
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_empleados.isEmpty) {
      return const Center(child: Text('No hay empleados disponibles'));
    }

    final empleadosAMostrar = _obtenerEmpleadosVisibles();

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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado compacto
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: isSmallScreen ? 10 : 12),
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
                Text(
                  'EMPLEADOS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3E2B6B),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${empleadosAMostrar.length}/${_empleados.length}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF3E2B6B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.close, size: 18, color: Color(0xFF3E2B6B)),
                      onPressed: widget.onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Barra de búsqueda con icono de seleccionar todos al costado
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey[50],
            child: Row(
              children: [
                // Buscador
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o apellidos...',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      prefixIcon: Icon(Icons.search, size: 18),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 16),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                              padding: EdgeInsets.zero,
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                      constraints: BoxConstraints(
                        maxHeight: 40,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _actualizarEstadoTodosSeleccionados();
                      });
                    },
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Icono para seleccionar/deseleccionar todos
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      _todosSeleccionados ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 24,
                      color: _todosSeleccionados ? Color(0xFF7876E1) : Colors.grey,
                    ),
                    onPressed: _toggleSeleccionTodos,
                    tooltip: _todosSeleccionados ? 'Deseleccionar todos' : 'Seleccionar todos',
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ],
            ),
          ),

         

          // Lista de empleados optimizada para espacio
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: isSmallScreen ? screenHeight * 0.4 : screenHeight * 0.5,
              ),
              child: empleadosAMostrar.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: isSmallScreen ? 32 : 40, color: Colors.grey),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          Text(
                            'No se encontraron empleados',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: empleadosAMostrar.length,
                      itemBuilder: (context, index) {
                        final empleado = empleadosAMostrar[index];
                        final empleadoId = empleado['emple_id'] as int;
                        final nombreCompleto =
                            '${empleado['perso_nombre']} ${empleado['perso_apPaterno']} ${empleado['perso_apMaterno']}'.trim();
                        final estaFiltrado = _empleadosFiltrados.contains(empleadoId);
                        final estaSeleccionado = _empleadosSeleccionados.contains(empleadoId);

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: estaSeleccionado
                                ? const Color(0xFFE8E6F9)
                                : estaFiltrado
                                    ? const Color(0xFFE6F4EA)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: estaSeleccionado 
                                  ? const Color(0xFF7876E1) 
                                  : Colors.grey.withOpacity(0.2),
                              width: estaSeleccionado ? 1.0 : 0.5,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 12,
                              vertical: isSmallScreen ? 0 : 4,
                            ),
                            leading: Container(
                              width: isSmallScreen ? 32 : 36,
                              height: isSmallScreen ? 32 : 36,
                              decoration: BoxDecoration(
                                color: estaSeleccionado 
                                    ? const Color(0xFF7876E1) 
                                    : const Color(0xFF3E2B6B),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: isSmallScreen ? 16 : 18,
                              ),
                            ),
                            title: Text(
                              nombreCompleto,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 15,
                                fontWeight: FontWeight.w500,
                                color: estaSeleccionado 
                                    ? const Color(0xFF3E2B6B) 
                                    : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            trailing: Checkbox(
                              value: estaSeleccionado,
                              onChanged: (_) => _toggleSeleccionEmpleado(empleadoId),
                              activeColor: const Color(0xFF7876E1),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            onTap: () => _toggleSeleccionEmpleado(empleadoId),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Botón de aplicar compacto
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
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
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 1,
              ),
              child: Text(
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