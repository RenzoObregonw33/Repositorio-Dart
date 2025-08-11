import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';
import 'package:login/Models/filtro_data.dart';
import 'package:login/widgets/selector_fechas.dart';
import 'package:login/widgets/selector_filtros.dart';

// Pantalla que muestra el detalle diario de empleados con filtros y búsqueda
class DetalleDiarioScreen extends StatefulWidget {
  final String token; // Token de autenticación
  final int organiId; // ID de organización

  const DetalleDiarioScreen({
    Key? key,
    required this.token,
    required this.organiId,
  }) : super(key: key);

  @override
  State<DetalleDiarioScreen> createState() => _DetalleDiarioScreenState();
}

class _DetalleDiarioScreenState extends State<DetalleDiarioScreen> {
  // Variables de estado
  late ApiGraphicsService _apiService; // Servicio para llamadas API
  bool _cargando = true; // Indicador de carga
  List<dynamic> _empleados = []; // Lista de empleados
  String _errorMessage = ''; // Mensaje de error
  int _totalEmpleados = 0; // Total de empleados
  DateTimeRange? _dateRange; // Rango de fechas seleccionado
  bool _mostrarFiltros = false; // Mostrar/ocultar filtros
  List<GrupoFiltros> _filtrosEmpresariales = []; // Filtros aplicados
  String _tipoBusqueda = 'documento'; // Tipo de búsqueda (documento/nombre/apellido)
  String _textoBusqueda = ''; // Texto de búsqueda
  int _start = 0; // Índice de inicio para paginación
  final int _limite = 20; // Límite de resultados por página
  String _orderColumn = 'nombre'; // Columna para ordenar
  String _orderDir = 'asc'; // Dirección de orden (asc/desc)

  @override
  void initState() {
    super.initState();
    // Inicializar servicio API con token y organización
    _apiService = ApiGraphicsService(
      token: widget.token,
      organiId: widget.organiId,
    );
    // Establecer rango de fechas por defecto (desde inicio del día hasta ahora)
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: now,
    );
    // Cargar datos iniciales
    _cargarDatos();
  }

  // Método para cargar datos de empleados desde la API
  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _errorMessage = '';
    });

    try {
      // Llamada a la API para obtener datos de empleados
      final response = await _apiService.fetchDetalleDiarioEmpleados(
        fecha: _dateRange?.end ?? DateTime.now(),
        start: _start,
        limite: _limite,
        orderColumn: _orderColumn,
        orderDir: _orderDir,
        tipo: _tipoBusqueda,
        busq: _textoBusqueda.trim().toUpperCase(),
      );

      // Validar respuesta
      if (response == null) {
        throw Exception('Respuesta nula del servidor');
      }

      // Manejar errores de la API
      if (response['error'] != null) {
        throw Exception(response['error']);
      }

      // Manejar códigos de error HTTP
      if (response['statusCode'] != null && response['statusCode'] >= 400) {
        if (response['statusCode'] == 500 && _textoBusqueda.isNotEmpty) {
          // Caso especial: búsqueda sin resultados
          setState(() {
            _empleados = [];
            _totalEmpleados = 0;
            _cargando = false;
          });
          return;
        }
        throw Exception('Error ${response['statusCode']}: ${response['message']}');
      }

      // Actualizar estado con los datos recibidos
      setState(() {
        _empleados = response['data'] ?? [];
        _totalEmpleados = response['recordsTotal'] ?? 0;
        _cargando = false;
      });
    } catch (e) {
      // Manejar errores
      setState(() {
        _cargando = false;
        if (e.toString().contains('500') && _textoBusqueda.isNotEmpty) {
          _empleados = [];
          _errorMessage = '';
        } else {
          _errorMessage = 'Error al cargar datos: ${e.toString().replaceAll('Exception: ', '')}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.05),
      appBar: AppBar(
        title: const Text("Detalle Diario de Empleados"),
        backgroundColor: Colors.transparent,
        actions: [
          // Botón para recargar datos
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de fechas
          if (_dateRange != null)
            SelectorFechas(
              range: _dateRange!,
              onRangeSelected: (newRange) {
                if (newRange != null) {
                  setState(() => _dateRange = newRange);
                  _cargarDatos();
                }
              },
            ),
          
          // Botones de filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildCustomButton(
                    text: 'Datos Empresariales',
                    onPressed: () {
                      setState(() {
                        _mostrarFiltros = !_mostrarFiltros;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Panel de filtros empresariales
          if (_mostrarFiltros)
            SizedBox(
              height: 300,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SelectorFiltros(
                  graphicsService: _apiService,
                  onFiltrosChanged: (filtros) {
                    setState(() => _filtrosEmpresariales = filtros);
                    _cargarDatos();
                  },
                ),
              ),
            ),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar empleados...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _textoBusqueda = value;
                      _cargarDatos();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Selector de tipo de búsqueda
                DropdownButton<String>(
                  value: _tipoBusqueda,
                  items: const [
                    DropdownMenuItem(
                      value: 'documento',
                      child: Text('Documento'),
                    ),
                    DropdownMenuItem(
                      value: 'nombre',
                      child: Text('Nombre'),
                    ),
                    DropdownMenuItem(
                      value: 'apellido',
                      child: Text('Apellido'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _tipoBusqueda = value);
                      _cargarDatos();
                    }
                  },
                ),
              ],
            ),
          ),

          // Contenido principal (lista de empleados)
          Expanded(
            child: _buildBody(),
          ),

          // Controles de paginación
          if (_totalEmpleados > _limite)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botón anterior
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _start > 0
                        ? () {
                            setState(() => _start -= _limite);
                            _cargarDatos();
                          }
                        : null,
                  ),
                  // Indicador de página
                  Text(
                    'Mostrando ${_start + 1}-${_start + _empleados.length} de $_totalEmpleados',
                    style: const TextStyle(fontSize: 14),
                  ),
                  // Botón siguiente
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _start + _limite < _totalEmpleados
                        ? () {
                            setState(() => _start += _limite);
                            _cargarDatos();
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Widget para construir botones personalizados
  Widget _buildCustomButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA528), Color(0xFFF77B09)],
          stops: [0.1, 0.9],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Construir el cuerpo principal de la pantalla
  Widget _buildBody() {
    // Mostrar indicador de carga
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mostrar mensaje de error si existe
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // Mostrar mensaje cuando no hay empleados
    if (_empleados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _textoBusqueda.isEmpty
                  ? 'No hay empleados registrados'
                  : 'No se encontraron resultados para "${_textoBusqueda.toUpperCase()}"',
              style: const TextStyle(fontSize: 16),
            ),
            // Botón para limpiar búsqueda
            if (_textoBusqueda.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _textoBusqueda = '';
                  });
                  _cargarDatos();
                },
                child: const Text('Limpiar búsqueda'),
              ),
          ],
        ),
      );
    }

    // Mostrar lista de empleados
    return Column(
      children: [
        _buildResumen(), // Resumen de resultados
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _empleados.length,
            itemBuilder: (context, index) {
              final empleado = _empleados[index];
              return _buildEmpleadoCard(empleado); // Tarjeta de empleado
            },
          ),
        ),
      ],
    );
  }

  // Widget para el resumen de resultados
  Widget _buildResumen() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BorderSide.strokeAlignCenter, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2747), // Color de fondo azul oscuro
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResumenItem('Total', _totalEmpleados.toString()),
          _buildResumenItem('Mostrando', '${_start + 1}-${_start + _empleados.length}'),
          _buildResumenItem('Búsqueda por', _getTipoBusquedaText()),
        ],
      ),
    );
  }

  // Obtener texto descriptivo del tipo de búsqueda
  String _getTipoBusquedaText() {
    switch (_tipoBusqueda) {
      case 'documento':
        return 'Documento';
      case 'nombre':
        return 'Nombre';
      case 'apellido':
        return 'Apellido';
      default:
        return _tipoBusqueda;
    }
  }

  // Widget para ítems del resumen
  Widget _buildResumenItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Widget para construir la tarjeta de cada empleado
  Widget _buildEmpleadoCard(Map<String, dynamic> empleado) {
    // Extraer datos del empleado
    final nombreCompleto = '${empleado['nombre']} ${empleado['apPaterno']} ${empleado['apMaterno']}';
    final horasTrabajadas = _convertirSegundosAHorasMinutos(empleado['tiempoT'] ?? 0);
    final division = empleado['division'] is int 
        ? (empleado['division'] as int).toDouble() 
        : empleado['division'] ?? 0.0;
    final horario = empleado['horario_descripcion'] ?? 'No especificado';
    final inicio = empleado['inicioA'] ?? '--:--:--';
    final ultima = empleado['ultimaA'] ?? '--:--:--';

    // Determinar estado de productividad según porcentaje
    final String estado;
    final Color colorEstado;
    
    if (division >= 50) {
      estado = 'Alta productividad';
      colorEstado = Colors.greenAccent;
    } else if (division >= 30) {
      estado = 'Media productividad';
      colorEstado = Colors.orangeAccent;
    } else {
      estado = 'Baja productividad';
      colorEstado = Colors.redAccent;
    }

    // Construir la tarjeta
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2747), // Fondo azul oscuro
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila con nombre e ID
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nombreCompleto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          
          const Divider(color: Colors.white24), // Divisor

          // Horario del empleado
          Row(
            children: [
              const Icon(Icons.work_history, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                horario,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Horas de inicio y última actividad
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text("Inicio: $inicio", style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 12),
              Text("Última: $ultima", style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),

          // Horas trabajadas
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text("Horas trabajadas: $horasTrabajadas",
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),

          // Barra de progreso de eficiencia
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: division / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    color: _getProgressColor(division),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${division.toStringAsFixed(1)}%",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Estado de productividad
          Row(
            children: [
              Icon(Icons.check_circle, color: colorEstado, size: 18),
              const SizedBox(width: 6),
              Text(
                "Estado: $estado",
                style: TextStyle(
                  color: colorEstado,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Método auxiliar para construir filas de información
  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Convertir segundos a formato horas:minutos
  String _convertirSegundosAHorasMinutos(int segundos) {
    final horas = (segundos / 3600).floor();
    final minutos = ((segundos % 3600) / 60).floor();
    return '$horas h $minutos m';
  }

  // Obtener color para la barra de progreso según porcentaje
  Color _getProgressColor(double porcentaje) {
    if (porcentaje >= 80) return Colors.blue;
    if (porcentaje >= 50) return Color(0xFF2DC70D); // Verde
    if (porcentaje >= 30) return Color(0xFFFE9717); // Naranja
    return Color(0xFFFF1A15); // Rojo
  }
}