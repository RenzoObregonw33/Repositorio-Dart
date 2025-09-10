import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';
import 'package:login/widgets/error_message.dart';
import 'package:login/widgets/grafico_diario_extend.dart';
import 'package:login/widgets/linea_de_tiempo.dart';
import 'package:login/widgets/lumina.dart';

// 👇 Añadir WidgetsBindingObserver al StatefulWidget
class DiarioEnListaScreen extends StatefulWidget with WidgetsBindingObserver {
  final String token;
  final int organiId;
  final Map<String, dynamic> empleado;
  final DateTime fecha;

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
  
  late ApiGraphicsService _apiService;
  late TabController _tabController;
  bool _cargando = true;
  Map<String, dynamic>? _responseData;
  String _errorMessage = '';
  final int _limite = 10;
  int _start = 0;
  int _totalRecords = 0;
  bool _hasMoreData = true;
  ScrollController _scrollController = ScrollController();
  bool _cargandoMas = false;
  bool _isDisposed = false;
  bool _appInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(widget); // 👈 Cambiar 'this' por 'widget'
    
    _apiService = ApiGraphicsService(
      token: widget.token,
      organiId: widget.organiId,
    );
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_scrollListener);
    _cargarDatos();
  }

  // 👇 Mover el método didChangeAppLifecycleState al StatefulWidget
  // Pero necesitamos una forma de comunicar el cambio al State
  // Usaremos un callback approach

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (_hasMoreData && !_cargando && !_cargandoMas) {
        _cargarMasDatos();
      }
    }
  }

  // 👇 Método que será llamado desde el Widget cuando la app vuelva al foreground
  void _onAppResumed() {
    if (_appInBackground) {
      _appInBackground = false;
      
      // Si hay error o estaba cargando, reintentar
      if (_errorMessage.isNotEmpty || (_cargando && _responseData == null)) {
        _reintentarCarga();
      }
    }
  }

  void _reintentarCarga() {
    if (!mounted || _isDisposed) return;
    
    setState(() {
      _errorMessage = '';
      _cargando = true;
    });
    
    _cargarDatos(reset: true);
  }

  Future<void> _cargarDatos({bool reset = false}) async {
    if (!mounted || _isDisposed) return;
    
    setState(() {
      if (reset) {
        _cargando = true;
      } else {
        _cargandoMas = true;
      }
      _errorMessage = '';
    });

    if (reset) {
      _start = 0;
      _hasMoreData = true;
      _responseData = null;
    }

    try {
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

      if (!mounted || _isDisposed) return;
  
      setState(() {
        if (reset || _responseData == null) {
          _responseData = response['data'];
        } else {
          final newData = response['data'];
          
          final currentList = _responseData!['lista']['data'] as List;
          final newList = newData['lista']['data'] as List;
          _responseData!['lista']['data'] = [...currentList, ...newList];
          
          if (newData['linea_tiempo'] != null && 
              newData['linea_tiempo']['data'] != null) {
            final currentTimeline = _responseData!['linea_tiempo']['data'] as List;
            final newTimeline = newData['linea_tiempo']['data'] as List;
            _responseData!['linea_tiempo']['data'] = [...currentTimeline, ...newTimeline];
          }
        }
        
        _totalRecords = response['data']['lista']['recordsTotal'] ?? 0;
        _hasMoreData = _start + _limite < _totalRecords;
        _cargando = false;
        _cargandoMas = false;
      });
    } catch (e) {
      if (!mounted || _isDisposed) return;
      
      setState(() {
        _cargando = false;
        _cargandoMas = false;
        _errorMessage = 'Error al cargar datos: ${e.toString()}';
      });
    }
  }

  Future<void> _cargarMasDatos() async {
    if (!_hasMoreData) return;

    setState(() {
      _start += _limite;
    });

    await _cargarDatos();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(widget); // 👈 Cambiar 'this' por 'widget'
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF3E2B6A),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Diario en Lista',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xFF64D9C5),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black,
              tabs: const [
                Tab(text: 'Diario en Línea'),
                Tab(text: 'Línea de Tiempo'),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cargando && _responseData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lumina(
              assetPath: 'assets/imagen/luminaos.png',
              duracion: const Duration(milliseconds: 1500),
              size: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Cargando datos...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return ErrorMessageWidget(
        mensaje: _errorMessage,
      );
    }


    if (_responseData == null) {
      return Center(
        child: Text(
          'No hay datos disponibles',
          style: TextStyle(color: Colors.black),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildResumenTab(),
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
          if (_hasMoreData && !_cargando && !_cargandoMas) {
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
              if (_cargandoMas)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF3E2B6B))), // Indicador de carga
                ),
              
              // Mensaje cuando no hay más datos
              if (!_hasMoreData && lista.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      '✨ No hay más actividades para mostrar', // Mensaje de fin de datos
                      style: TextStyle(color: Colors.grey), // Color del texto
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
          style: TextStyle(color: Colors.black), // Color del texto
        ),
      );
    }

    final timelineData = _responseData!['linea_tiempo']['data'] ?? []; // Obtiene los datos de la línea de tiempo
    final totalTimelineRecords = _responseData!['linea_tiempo']['recordsTotal'] ?? 0; // Total de registros de la línea de tiempo
    final tieneMasDatosTimeline = timelineData.length < totalTimelineRecords; // Verifica si hay más datos

    return TimelineScreen(
      eventos: timelineData, // Pasa solo los datos de timeline
      tieneMasDatos: tieneMasDatosTimeline,
      cargandoMas: _cargandoMas,
      onCargarMas: _cargarMasDatos, // Este método incrementa _start y llama _cargarDatos
      authToken: widget.token,
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