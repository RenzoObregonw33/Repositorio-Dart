import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';
import 'package:login/Models/filtro_data.dart';
import 'package:login/screens/diario_lista_screen.dart';
import 'package:login/widgets/selector_fecha_simple.dart';
import 'package:login/widgets/selector_filtros.dart';
import 'package:login/widgets/lumina.dart';

// Pantalla que muestra el detalle diario de empleados con filtros y búsqueda
class DetalleDiarioScreen extends StatefulWidget {
  final String token; // Token de autenticación
  final int organiId; // ID de organización

  const DetalleDiarioScreen({
    super.key,
    required this.token,
    required this.organiId,
  });

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
  DateTime _selectedDate = DateTime.now(); // Rango de fechas seleccionado
  bool _mostrarFiltros = false; // Mostrar/ocultar filtros
  List<GrupoFiltros> _filtrosEmpresariales = []; // Filtros aplicados
  String _tipoBusqueda = 'emple_nDoc'; // Tipo de búsqueda (documento/nombre/apellido)
  String _textoBusqueda = ''; // Texto de búsqueda
  final TextEditingController _busquedaController = TextEditingController(); // Controlador para el campo de búsqueda
  int _start = 0; // Índice de inicio para paginación
  final int _limite = 20; // Límite de resultados por página
  final String _orderColumn = 'nombre'; // Columna para ordenar
  final String _orderDir = 'asc'; // Dirección de orden (asc/desc)
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiGraphicsService(
      token: widget.token,
      organiId: widget.organiId,
    );
    _selectedDate = DateTime.now(); // Fecha actual por defecto
    _cargarDatos();
  }

  @override
    void dispose() {
      _isDisposed = true;
      _busquedaController.dispose(); // Importante: limpiar el controlador
      super.dispose();
    }
  // Método para cargar datos de empleados desde la API
  Future<void> _cargarDatos() async {
    if (_isDisposed) return;

    setState(() {
      _cargando = true;
      _errorMessage = '';
    });

    try {
      // Llamada a la API para obtener datos de empleados
      final response = await _apiService.fetchDetalleDiarioEmpleados(
        fecha: _selectedDate, 
        start: _start,
        limite: _limite,
        orderColumn: _orderColumn,
        orderDir: _orderDir,
        tipo: _tipoBusqueda,
        busq: _textoBusqueda.trim().toUpperCase(),
      );

      if (_isDisposed) return; 

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
      if (mounted) { // <-- Verificar si el widget está montado antes de setState
        setState(() {
          _empleados = response['data'] ?? [];
          _totalEmpleados = response['recordsTotal'] ?? 0;
          _cargando = false;
        });
      }
    } catch (e) {
      //Manejo de errores
      if (!_isDisposed && mounted) { // <-- Verificar antes de manejar errores
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
  }

  void _navegarADetalleEmpleado(Map<String, dynamic> empleado) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que la hoja ocupe casi toda la pantalla
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DiarioEnListaScreen(
          token: widget.token,
          organiId: widget.organiId,
          empleado: empleado,
          fecha: _selectedDate,
        ),
      ),
    );
  }
   // Método para ejecutar la búsqueda
  void _ejecutarBusqueda() {
    if (!mounted) return; 
    setState(() {
      _textoBusqueda = _busquedaController.text;
      _start = 0; // Reiniciar paginación al hacer nueva búsqueda
    });
    _cargarDatos();
  }

  // Método para limpiar la búsqueda
  void _limpiarBusqueda() {
    if (!mounted) return;
    _busquedaController.clear();
    setState(() {
      _textoBusqueda = '';
      _start = 0;
    });
    _cargarDatos();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.05),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Detalle Diario de Empleados", style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF3E2B6A),
        actions: [
          // Botón para recargar datos
          IconButton(
            color: Colors.white ,
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de fechas
          SelectorFechaSimple(
          selectedDate: _selectedDate,
          onDateSelected: (newDate) {
            if (!mounted) return;
            setState(() => _selectedDate = newDate);
            _cargarDatos();
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
                    controller: _busquedaController, // Usamos el controlador
                    decoration: InputDecoration(
                      hintText: 'Buscar empleados...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: _textoBusqueda.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _limpiarBusqueda,
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _ejecutarBusqueda(), // Buscar al presionar enter
                  ),
                ),
                const SizedBox(width: 8),
                // Botón de búsqueda
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7775E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  ),
                  onPressed: _ejecutarBusqueda,
                  child: Text('Buscar', style: TextStyle(color: Colors.white),),
                ),
                const SizedBox(width: 8),
                // Selector de tipo de búsqueda
                DropdownButton<String>(
                  value: _tipoBusqueda,
                  items: const [
                    DropdownMenuItem(
                      value: 'emple_nDoc',
                      child: Text('Documento'),
                    ),
                    DropdownMenuItem(
                      value: 'perso_nombre',
                      child: Text('Nombre'),
                    ),
                    DropdownMenuItem(
                      value: 'apellido',
                      child: Text('Apellido'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null && mounted) {
                      setState(() => _tipoBusqueda = value);
                      if (_textoBusqueda.isNotEmpty) {
                        _ejecutarBusqueda();
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          // Contenido principal (lista de empleados)
          Expanded(
            child: Column(
              children: [
                _buildLeyendaProductividad(),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
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
        color: Color(0xFF7775E2),
        borderRadius: BorderRadius.circular(24),
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
            fontSize: 14,
            color: Colors.white,
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lumina(
              assetPath: 'assets/imagen/luminaos.png', // Ruta a tu imagen de carga
              duracion: const Duration(milliseconds: 1500),
              size: 300,
            ),
          ],
        ),
      );
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
                onPressed: _limpiarBusqueda,        
                child: const Text('Limpiar búsqueda'),
              ),
          ],
        ),
      );
    }

    // Mostrar lista de empleados
    return Column(
      children: [
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

  // Agrega este nuevo método para construir la leyenda
  Widget _buildLeyendaProductividad() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      /*decoration: BoxDecoration(
        color: const Color(0xFF0F2747),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),*/
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildItemLeyenda(
            color: const Color(0xFF64D9C5),
            texto: 'Alta',
          ),
          const SizedBox(width: 16),
          _buildItemLeyenda(
            color: const Color(0xFFFFC066),
            texto: 'Media',
          ),
          const SizedBox(width: 16),
          _buildItemLeyenda(
            color: const Color(0xFFFF625C),
            texto: 'Baja',
          ),
        ],
      ),
    );
  }

  // Método auxiliar simplificado
  Widget _buildItemLeyenda({required Color color, required String texto}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
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
      colorEstado = Color(0xFF64D9C5);
    } else if (division >= 30) {
      estado = 'Media productividad';
      colorEstado = Color(0xFFFFC066);
    } else {
      estado = 'Baja productividad';
      colorEstado = Color(0xFFFF625C);
    }

    // Construir la tarjeta
    return GestureDetector(
      onTap: () {
        _navegarADetalleEmpleado(empleado);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FC), // Fondo claro
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFF8F7FC), width: 1),
          boxShadow: [
            BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            spreadRadius: 2,
            offset: Offset(0, 2)
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila con nombre e ID
            Row(
              children: [
                const Icon(Icons.person, color: Colors.black, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    nombreCompleto,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            //Esta fila es provisional
            Row(
              children: [
                Image.asset(
                  'assets/Icons/objetivo.png',
                  width: 16,
                  height: 16,
                  color: Colors.black, // si quieres cambiar color (solo funciona con imágenes monocromáticas tipo PNG transparente)
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Ejecutivo Comercial",
                    style: const TextStyle(
                      color: Colors.black,    
                      fontSize: 12,
                    ),
                  ),
                  
                ),
              ],
            ),
      
            const Divider(color: Colors.black), // Divisor
      
            // Horario del empleado
            Row(
              children: [
                Image.asset(
                  'assets/Icons/reloj.png',
                  width: 16,
                  height: 16,
                  color: Colors.black, // si quieres cambiar color (solo funciona con imágenes monocromáticas tipo PNG transparente)
                ),
                const SizedBox(width: 8),
                Text(
                  horario,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
      
            // Horas de inicio y última actividad
            Row(
              children: [
                Image.asset(
                  'assets/Icons/cronografo.png',
                  width: 16,
                  height: 16,
                  color: Colors.green, // si quieres cambiar color (solo funciona con imágenes monocromáticas tipo PNG transparente)
                ),
                const SizedBox(width: 6),
                Text("Inicio: $inicio", style: const TextStyle(color: Colors.black)),
                const SizedBox(width: 12),
                Image.asset(
                  'assets/Icons/cronografo.png',
                  width: 16,
                  height: 16,
                  color: Colors.red, // si quieres cambiar color (solo funciona con imágenes monocromáticas tipo PNG transparente)
                ),
                const SizedBox(width: 6),
                Text("Última: $ultima", style: const TextStyle(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 4),
      
            // Horas trabajadas
            Row(
              children: [
                Image.asset(
                  'assets/Icons/calendario.png',
                  width: 16,
                  height: 16,
                  color: Colors.black, // si quieres cambiar color (solo funciona con imágenes monocromáticas tipo PNG transparente)
                ),
                const SizedBox(width: 6),
                Text("Horas trabajadas: $horasTrabajadas",
                    style: const TextStyle(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 4),
      
            // Barra de progreso de eficiencia
            Row(
              children: [
                //const Icon(Icons.bar_chart, color: Colors.white70, size: 18),
                Image.asset(
                  'assets/Icons/inversion.png',
                  width: 16,
                  height: 16,
                  color: Colors.black, // si quieres cambiar color (solo funciona con imágenes monocromáticas tipo PNG transparente)
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: division / 100,
                      minHeight: 8,
                      backgroundColor: Color(0xFFE7E7F3),
                      color: _getProgressColor(division),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${division.toStringAsFixed(1)}%",
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 4),
            
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
      ),
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
    if (porcentaje >= 50) return Color(0xFF64D9C5); // Verde
    if (porcentaje >= 30) return Color(0xFFFFC066); // Naranja
    return Color(0xFFFF625C); // Rojo
  }
}

