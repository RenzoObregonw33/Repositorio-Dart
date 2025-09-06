import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';
import 'package:login/widgets/grafico_diario_extend.dart';
import 'package:login/widgets/linea_de_tiempo.dart';
import 'package:login/widgets/lumina.dart';

// Clase principal para la pantalla de Diario en Lista
class DiarioEnListaScreen extends StatefulWidget {
  final String token; // Token de autenticación
  final int organiId; // ID de la organización
  final Map<String, dynamic> empleado; // Información del empleado
  final DateTime fecha; // Fecha para la consulta

  const DiarioEnListaScreen({
    super.key,
    required this.token,
    required this.organiId,
    required this.empleado,
    required this.fecha,
  });

  @override
  State<DiarioEnListaScreen> createState() => _DiarioEnListaScreenState();
}

class _DiarioEnListaScreenState extends State<DiarioEnListaScreen> 
    with SingleTickerProviderStateMixin {
  
  late ApiGraphicsService _apiService; // Servicio para la API
  late TabController _tabController; // Controlador para las pestañas
  bool _cargando = true; // Estado de carga
  Map<String, dynamic>? _responseData; // Datos de respuesta de la API
  String _errorMessage = ''; // Mensaje de error
  final int _limite = 10; // Límite de registros por página
  int _start = 0; // Índice de inicio para la paginación
  int _currentPage = 1; // Página actual
  int _totalRecords = 0; // Total de registros disponibles
  bool _hasMoreData = true; // Indica si hay más datos para cargar
  ScrollController _scrollController = ScrollController(); // Controlador de desplazamiento

  @override
  void initState() {
    super.initState();
    // Inicializa el servicio de API con el token y el ID de la organización
    _apiService = ApiGraphicsService(
      token: widget.token,
      organiId: widget.organiId,
    );
    // Inicializa el controlador de pestañas
    _tabController = TabController(length: 2, vsync: this);
    // Agrega un listener al controlador de desplazamiento
    _scrollController.addListener(_scrollListener);
    // Carga los datos iniciales
    _cargarDatos();
  }

  // Listener para el desplazamiento
  void _scrollListener() {
    // Verifica si se ha llegado al final de la lista
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Carga más datos si hay más disponibles y no se está cargando
      if (_hasMoreData && !_cargando) {
        _cargarMasDatos();
      }
    }
  }

  // Método para cargar datos desde la API
  Future<void> _cargarDatos({bool reset = false}) async {
    if (!mounted) return; // Verifica si el widget sigue montado
    setState(() {
      _cargando = true; // Indica que se está cargando
      _errorMessage = ''; // Resetea el mensaje de error
    });

    if (reset) {
      // Reinicia la paginación si se solicita
      _start = 0;
      _currentPage = 1;
      _hasMoreData = true;
      _responseData = null; // Resetea los datos de respuesta
    }

    try {
      // Realiza la llamada a la API para obtener datos
      final response = await _apiService.fetchData(
        fecha: widget.fecha,
        organiId: widget.organiId,
        start: _start,
        limite: _limite,
        orderColumn: 'inicioA',
        orderDir: 'asc',
        tipo: 'individual',
        idEmpleado: widget.empleado['idEmpleado'],
      );

      if (!mounted) return; // Verifica si el widget sigue montado
  
      setState(() {
        // SIEMPRE reemplaza los datos en lugar de concatenarlos
        if (reset || _responseData == null) {
          _responseData = response['data'];
        } else {
          // Para navegación con botones: REEMPLAZA los datos
          _responseData = response['data'];
        }
        
        _totalRecords = response['data']['lista']['recordsTotal'] ?? 0;
        _hasMoreData = _start + _limite < _totalRecords; // ← Corrección importante
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return; // Verifica si el widget sigue montado
      setState(() {
        _cargando = false; // Finaliza la carga
        _errorMessage = 'Error al cargar datos: ${e.toString()}'; // Asigna el mensaje de error
      });
    }
  }

  // Método para cargar más datos
  Future<void> _cargarMasDatos() async {
    if (!_hasMoreData) return; // Si no hay más datos, no hace nada

    if (!mounted) return; // Verifica si el widget sigue montado

    setState(() {
      _start += _limite; // Incrementa el índice de inicio
      _currentPage++; // Incrementa la página actual
    });

    await _cargarDatos(); // Carga los nuevos datos

    if (!mounted) return; // Verifica si el widget sigue montado
  }

  @override
  void dispose() {
    _tabController.dispose(); // Libera el controlador de pestañas
    _scrollController.dispose(); // Libera el controlador de desplazamiento
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Color de fondo
      appBar: AppBar(
        backgroundColor: Color(0xFF3E2B6A), // Color de fondo de la AppBar
        iconTheme: IconThemeData(color: Colors.white), // Color de los íconos
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Diario en Lista',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20), // Color del texto
        ),
        centerTitle: true, // Centra el título
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Colors.white, // Fondo blanco para el TabBar
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xFF64D9C5),
              labelColor: Colors.black, // Texto seleccionado en negro sobre fondo blanco
              unselectedLabelColor: Colors.black,
              tabs: const [
                Tab(text: 'Diario en Línea'),
                Tab(text: 'Línea de Tiempo'),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(), // Cuerpo de la pantalla
      bottomNavigationBar: _buildPaginationControls(), // Controles de paginación
    );
  }

  // Método para construir los controles de paginación
  Widget _buildPaginationControls() {
    if (_responseData == null || _totalRecords <= _limite) {
      return SizedBox.shrink(); // Si no hay datos, no muestra controles
    }

    return Container(
      color: Colors.black, // Color de fondo
      padding: EdgeInsets.symmetric(vertical: 8), // Espaciado vertical
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centra los controles
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white), // Botón de retroceso
            onPressed: _currentPage > 1
                ? () async {
                  setState(() {
                    _start = Math.max(0, _start - _limite); // Retrocede correctamente
                    _currentPage--;
                  });
                  await _cargarDatos(); // Llama sin reset: true
                }
              : null,
        ),
          Text(
            'Página $_currentPage de ${(_totalRecords / _limite).ceil()}', // Muestra la página actual
            style: TextStyle(color: Colors.white), // Color del texto
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: _hasMoreData
                ? () async {
                    setState(() {
                      _start += _limite; // Avanza correctamente
                      _currentPage++;
                    });
                    await _cargarDatos(); // Llama sin reset: true
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // Método para construir el cuerpo de la pantalla
  Widget _buildBody() {
    if (_cargando && _responseData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lumina(
              assetPath: 'assets/imagen/luminaos.png', // Ruta a tu imagen de carga
              duracion: const Duration(milliseconds: 1500), // Duración de la animación
              size: 300, // Tamaño de la imagen
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage, // Muestra el mensaje de error
          style: TextStyle(color: Colors.red), // Color del texto
        ),
      );
    }

    if (_responseData == null) {
      return Center(
        child: Text(
          'No hay datos disponibles', // Mensaje cuando no hay datos
          style: TextStyle(color: Colors.black), // Color del texto
        ),
      );
    }

    return TabBarView(
      controller: _tabController, // Controlador de pestañas
      children: [
        // Primer Tab: Resumen (Gráfico + Lista)
        _buildResumenTab(),

        // Segundo Tab: Línea de tiempo
        _buildLineaTiempoTab(),
      ],
    );
  }

  // Método para construir la pestaña de resumen
  Widget _buildResumenTab() {
    final lista = _responseData!['lista']['data']; // Obtiene la lista de actividades

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        // Verifica si se ha llegado al final de la lista
        if (scrollNotification is ScrollEndNotification &&
            _scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent) {
          if (_hasMoreData && !_cargando) {
            _cargarMasDatos(); // Carga más datos
          }
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController, // Asigna el controlador de desplazamiento
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Espaciado
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
            children: [
              // Header con información del empleado
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey, // Color de fondo del avatar
                    child: Icon(Icons.person, size: 30, color: Colors.black), // Icono del avatar
                  ),
                  SizedBox(width: 10), // Espaciado
                  Expanded(
                    child: Text(
                      "${widget.empleado['nombre']} ${widget.empleado['apPaterno']} ${widget.empleado['apMaterno']}", // Nombre del empleado
                      style: TextStyle(
                        color: Colors.black, // Color del texto
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10), // Espaciado
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Color(0xFF3E2B6B), size: 18), // Icono de calendario
                  SizedBox(width: 5), // Espaciado
                  Text(
                    "${widget.fecha.day} de ${_getMonthName(widget.fecha.month)} del ${widget.fecha.year}", // Fecha formateada
                    style: TextStyle(color: Color(0xFF3E2B6B),fontSize: 16), // Color del texto
                  ),
                ],
              ),
              SizedBox(height: 20), // Espaciado

              // Gráfico de líneas
              GraficoDiarioExtend(
                graficoData: _responseData!['grafico'], // Datos del gráfico
              ),
              
              SizedBox(height: 20), // Espaciado

              // Lista de actividades
              Row(
                children: [
                  Icon(Icons.layers, color: Color(0xFF3E2B6B), size: 18), // Icono de actividades
                  SizedBox(width: 5), // Espaciado
                  Text(
                    'Actividades del día',
                    style: TextStyle(
                      color: Colors.black, // Color del texto
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10), // Espaciado
              ...lista.map((item) => _buildItemLista(item)).toList(), // Muestra la lista de actividades
              
              // Indicador de carga al final
              if (_cargando && _responseData != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator(color: Colors.black)), // Indicador de carga
                ),
              
              // Mensaje cuando no hay más datos
              if (!_hasMoreData && lista.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No hay más actividades para mostrar', // Mensaje de fin de datos
                      style: TextStyle(color: Colors.white54), // Color del texto
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir un elemento de la lista
  Widget _buildItemLista(dynamic item) {
    final porcentaje = double.tryParse(item['division'].toString()) ?? 0.0; // Porcentaje de división
    
    return Container(
      margin: EdgeInsets.only(bottom: 10), // Margen inferior
      padding: EdgeInsets.all(12), // Espaciado interno
      decoration: BoxDecoration(
        color: Color(0xFFF8F7FC), // Color de fondo
        borderRadius: BorderRadius.circular(12), // Bordes redondeados
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
        children: [
          Text(
            item['nombre_actividad'], // Nombre de la actividad
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black, fontFamily: 'inter'),
          ),
          SizedBox(height: 5), // Espaciado
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 20, color: Colors.green), // Icono de entrada
              SizedBox(width: 5), 
              Text(item['inicioA'], style: TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'inter', fontWeight: FontWeight.w500)), // Hora de inicio
              SizedBox(width: 30), // Espaciado
              Icon(Icons.schedule_rounded, size: 20, color: Colors.red), // Icono de salida
              SizedBox(width: 5), 
              Text(item['ultimaA'], style: TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'inter', fontWeight: FontWeight.w500)), // Hora de salida
            ],
          ),
          SizedBox(height: 5), // Espaciado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaciado entre elementos
            children: [
              Row(
                children: [
                  Icon(Icons.timer, size: 20, color: Color(0xFF3E2B6B)), // Icono de tiempo transcurrido
                  SizedBox(width: 5), // Espaciado
                  Text(item['tiempoTranscurrido'], style: TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'inter', fontWeight: FontWeight.w600)), // Tiempo transcurrido
                ]
              ),
              Container(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    
                    SizedBox(height: 10), // Espacio entre texto y barra
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(
                            width: 200,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Container(
                            width: 200 * (porcentaje / 100),
                            height: 22,
                            decoration: BoxDecoration(
                              color: _getColorEficiencia(porcentaje),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                "${porcentaje.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // Método para construir la pestaña de línea de tiempo
  Widget _buildLineaTiempoTab() {
    if (_responseData == null || 
        _responseData!['linea_tiempo'] == null || 
        _responseData!['linea_tiempo']['data'] == null) {
      return const Center(
        child: Text(
          'No hay datos de línea de tiempo disponibles', // Mensaje cuando no hay datos
          style: TextStyle(color: Colors.white), // Color del texto
        ),
      );
    }

    final timelineData = _responseData!['linea_tiempo']['data'] ?? []; // Obtiene los datos de la línea de tiempo
    final totalTimelineRecords = _responseData!['linea_tiempo']['recordsTotal'] ?? 0; // Total de registros de la línea de tiempo
    final tieneMasDatosTimeline = timelineData.length < totalTimelineRecords; // Verifica si hay más datos

    return TimelineScreen(
      eventos: _responseData!['linea_tiempo']['data'], // Pasa los eventos a la pantalla de línea de tiempo
      tieneMasDatos: tieneMasDatosTimeline, // Indica si hay más datos
      cargandoMas: _cargando, // Indica si se está cargando más
      onCargarMas: _cargarMasDatos, // Método para cargar más datos
      authToken: widget.token, // Pasa el token de autenticación
    );
  }

  // Método para obtener el color según la eficiencia
  Color _getColorEficiencia(double eficiencia) {
    if (eficiencia >= 50) return Color(0xFF64D9C5); // Verde
    if (eficiencia >= 30) return Color(0xFFFFC066); // Naranja
    return Color(0xFFFF625C); // Rojo
  }

  // Método para obtener el nombre del mes
  String _getMonthName(int month) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return months[month - 1]; // Retorna el nombre del mes correspondiente
  }
}