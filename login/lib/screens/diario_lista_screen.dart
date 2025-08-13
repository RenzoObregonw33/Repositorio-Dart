import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:login/Apis/api_graphics_services.dart';

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
          'Detalle Diario',
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
      return Center(child: CircularProgressIndicator(color: Colors.white));
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
    final grafico = _responseData!['grafico']['actividad_ultimos_dias'];

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
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1E2A38),
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                grafico['labels'][index],
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            );
                          },
                          interval: 1,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          grafico['labels'].length,
                          (i) => FlSpot(
                            i.toDouble(), 
                            double.parse(grafico['series']['Total'][i])
                          ),
                        ),
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.play_arrow, size: 16, color: Colors.green),
              Text(item['inicioA'], style: TextStyle(fontSize: 12, color: Colors.black)),
              SizedBox(width: 10),
              Icon(Icons.stop, size: 16, color: Colors.red),
              Text(item['ultimaA'], style: TextStyle(fontSize: 12, color: Colors.black)),
              SizedBox(width: 10),
              Icon(Icons.access_time, size: 16, color: Colors.purple ,),
              Text(item['tiempoTranscurrido'], style: TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: porcentaje / 100,
            color: _getColorEficiencia(porcentaje),
            backgroundColor: Colors.grey[300],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${porcentaje.toStringAsFixed(1)}%",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineaTiempoTab() {
    final eventos = _responseData!['linea_tiempo']['data'];
    
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        final evento = eventos[index];
        return _buildEventoLineaTiempo(evento);
      },
    );
  }

  Widget _buildEventoLineaTiempo(dynamic evento) {
    final porcentaje = double.tryParse(evento['division'].toString()) ?? 0.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1E2A38),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                '${evento['inicioA']} - ${evento['ultimaA']}',
                style: TextStyle(color: Colors.white),
              ),
              Spacer(),
              Chip(
                label: Text(
                  '${porcentaje.toStringAsFixed(1)}%',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: _getColorEficiencia(porcentaje),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            evento['nombre_actividad'],
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (evento['imagen'] != null && evento['imagen'].isNotEmpty) ...[
            SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: evento['imagen'].length,
                itemBuilder: (context, index) {
                  final imagen = evento['imagen'][index];
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://rhnube.com.pe${imagen['miniatura']}',
                        width: 100,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[800],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / 
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[800],
                            child: Icon(Icons.error, color: Colors.white),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColorEficiencia(double eficiencia) {
    if (eficiencia >= 50) return Colors.green;
    if (eficiencia >= 30) return Colors.orange;
    return Colors.red;
  }

  String _getMonthName(int month) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return months[month - 1];
  }
}