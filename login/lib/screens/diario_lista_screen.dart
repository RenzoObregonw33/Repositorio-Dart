import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';
import 'package:login/widgets/grafico_diario_extend.dart';
import 'package:login/widgets/linea_de_tiempo.dart';
import 'package:login/widgets/lumina.dart';


class DiarioEnListaScreen extends StatefulWidget {
  final String token;
  final int organiId;
  final Map<String, dynamic> empleado;
  final DateTime fecha;

  const DiarioEnListaScreen({
    Key? key,
    required this.token,
    required this.organiId,
    required this.empleado,
    required this.fecha,
  }) : super(key: key);

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
  int _currentPage = 1;
  int _totalRecords = 0;
  bool _hasMoreData = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _apiService = ApiGraphicsService(
      token: widget.token,
      organiId: widget.organiId,
    );
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_scrollListener);
    _cargarDatos();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (_hasMoreData && !_cargando) {
        _cargarMasDatos();
      }
    }
  }

  Future<void> _cargarDatos({bool reset = false}) async {
    if (reset) {
      _start = 0;
      _currentPage = 1;
      _hasMoreData = true;
    }

    setState(() {
      _cargando = true;
      _errorMessage = '';
    });

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

      if (!mounted) return;

      setState(() {
        if (reset || _responseData == null) {
          _responseData = response['data'];
        } else {
          // Concatenar los nuevos datos con los existentes
          _responseData!['lista']['data'].addAll(response['data']['lista']['data']);
          _responseData!['linea_tiempo']['data'].addAll(response['data']['linea_tiempo']['data']);
        }

        _totalRecords = response['data']['lista']['recordsTotal'] ?? 0;
        _hasMoreData = _responseData!['lista']['data'].length < _totalRecords;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _errorMessage = 'Error al cargar datos: ${e.toString()}';
      });
    }
  }

  Future<void> _cargarMasDatos() async {
    if (!_hasMoreData) return;

    setState(() {
      _start += _limite;
      _currentPage++;
    });

    await _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Diario en Lista',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Diario en Línea'),
            Tab(text: 'Línea de Tiempo'),
          ],
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildPaginationControls(),
    );
  }

  Widget _buildPaginationControls() {
    if (_responseData == null || _totalRecords <= _limite) {
      return SizedBox.shrink();
    }

    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _start = (_currentPage - 2) * _limite;
                      _currentPage--;
                    });
                    _cargarDatos(reset: true);
                  }
                : null,
          ),
          Text(
            'Página $_currentPage de ${(_totalRecords / _limite).ceil()}',
            style: TextStyle(color: Colors.white),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: _hasMoreData
                ? () => _cargarMasDatos()
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando && _responseData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lumina(
              assetPath: 'assets/imagen/lumina.png', // Ruta a tu imagen de carga
              duracion: const Duration(milliseconds: 1500),
              size: 300,
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    if (_responseData == null) {
      return Center(
        child: Text(
          'No hay datos disponibles',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // Primer Tab: Resumen (Gráfico + Lista)
        _buildResumenTab(),

        // Segundo Tab: Línea de tiempo
        _buildLineaTiempoTab(),
      ],
    );
  }

  Widget _buildResumenTab() {
    final lista = _responseData!['lista']['data'];
    //final grafico = _responseData!['grafico']['actividad_ultimos_dias'];

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification &&
            _scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent) {
          if (_hasMoreData && !_cargando) {
            _cargarMasDatos();
          }
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información del empleado
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: Colors.black),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${widget.empleado['nombre']} ${widget.empleado['apPaterno']} ${widget.empleado['apMaterno']}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white, size: 18),
                  SizedBox(width: 5),
                  Text(
                    "${widget.fecha.day} de ${_getMonthName(widget.fecha.month)} del ${widget.fecha.year}",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Gráfico de líneas
              GraficoDiarioExtend(
                graficoData: _responseData!['grafico'],
              ),
              
              SizedBox(height: 20),

              // Lista de actividades
              Text(
                'Actividades del día',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              ...lista.map((item) => _buildItemLista(item)).toList(),
              
              // Indicador de carga al final
              if (_cargando && _responseData != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
              
              // Mensaje cuando no hay más datos
              if (!_hasMoreData && lista.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No hay más actividades para mostrar',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemLista(dynamic item) {
    final porcentaje = double.tryParse(item['division'].toString()) ?? 0.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['nombre_actividad'],
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'inter'),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.door_front_door_rounded, size: 20, color: Colors.green),
              Text(item['inicioA'], style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'inter', fontWeight: FontWeight.w600)),
              SizedBox(width: 30),
              Icon(Icons.door_back_door_rounded, size: 20, color: Colors.red),
              Text(item['ultimaA'], style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'inter', fontWeight: FontWeight.w600)),            
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer, size: 20, color: Colors.blue[900],),
                  Text(item['tiempoTranscurrido'], style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'inter', fontWeight: FontWeight.w600)),
                ]
              ),
              Container(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${porcentaje.toStringAsFixed(1)}%",
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 20),
                    ),
                    Container(
                      width: 200,
                      height: 18,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: porcentaje / 100,
                          color: _getColorEficiencia(porcentaje),
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineaTiempoTab() {
    return LineaTiempoWidget(
      eventos: _responseData!['linea_tiempo']['data'],
    );
  }

  Color _getColorEficiencia(double eficiencia) {
    if (eficiencia >= 50) return Color(0xFF2BCA07);
    if (eficiencia >= 30) return Colors.orange;
    return Color(0xFFFF1A15);
  }

  String _getMonthName(int month) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return months[month - 1];
  }
}