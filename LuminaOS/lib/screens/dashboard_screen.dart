import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';
import 'package:login/Models/datos_actividad.dart';
import 'package:login/Models/datos_embudo.dart';
import 'package:login/Models/filtro_data.dart';
import 'package:login/widgets/grafico_actividad_semanal.dart';
import 'package:login/widgets/grafico_distribucion_actividad.dart';
import 'package:login/widgets/grafico_donut.dart';
import 'package:login/widgets/grafico_eficiencia.dart';
import 'package:login/widgets/grafico_embudo.dart';
import 'package:login/widgets/grafico_picos_actividad.dart';
import 'package:login/widgets/grafico_picos_porcentaje.dart';
import 'package:login/widgets/grafico_top_empleados.dart';
import 'package:login/widgets/selector_empleados.dart';
import 'package:login/widgets/selector_fechas.dart';
import 'package:login/widgets/selector_filtros.dart';
import 'package:login/widgets/lumina.dart';

class DashboardScreen extends StatefulWidget {
  final String token;
  final int organiId;

  const DashboardScreen({
    super.key,
    required this.token,
    required this.organiId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ApiGraphicsService _graphicsService;
  List<GrupoFiltros> _filtrosEmpresariales = [];
  bool _mostrarFiltros = false;
  bool _mostrarEmpleados = false;
  List<int> _empleadosSeleccionados = [];
  DateTimeRange? _dateRange;
  double? _eficiencia;
  double? _productivas;
  double? _noProductivas;
  List<FunnelData> _funnelData = [];
  bool _isLoading = false;
  String? _error;
  List<DatosActividad> _distribucionActividad = [];
  List<String> _picosLabels = [];
  List<double> _picosValores = [];
  List<HoraActividadPorcentajeData> _picosPorcentajeData = []; 
  Map<String, dynamic> _actividadDiaria = {}; 
  List<TopEmpleadoData> _topEmpleadosData = [];
  bool _isDisposed = false;
  int _intentosRefresh = 0;

  @override
  void initState() {
    super.initState();
    _graphicsService = ApiGraphicsService(token: widget.token, organiId: widget.organiId);
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day),
    );
    _loadData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2B6B),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Dashboard Gráficos', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.refresh),
            onPressed: _dateRange != null ? () {
              if (!mounted) return;
              _loadData();
            } : null,
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Selector de fechas
          SelectorFechas(
            range: _dateRange!,
            onRangeSelected: (newRange) {
              if (newRange != null) {
                if (!mounted) return;
                setState(() => _dateRange = newRange);
                _loadData();
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
                        _mostrarEmpleados = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCustomButton(
                    text: 'Empleados',
                    onPressed: () {
                      setState(() {
                        _mostrarEmpleados = !_mostrarEmpleados;
                        _mostrarFiltros = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Selectores (filtros y empleados)
          if (_mostrarFiltros)
            SizedBox(
              height: 300,
              child: SelectorFiltros(
                graphicsService: _graphicsService,
                onFiltrosChanged: (filtros) { 
                  if (!mounted) return;
                  setState(() {
                    _filtrosEmpresariales = filtros;
                    _mostrarFiltros = false;
                  });
                  _loadData();
                },
                onClose: () {
                  setState(() {
                    _mostrarFiltros = false;
                  });
                },
              ),
            ),

          if (_mostrarEmpleados)
            SizedBox(
              height: 300,
              child: SelectorEmpleado(
                graphicsService: _graphicsService,
                filtrosEmpresariales: _filtrosEmpresariales,
                empleadosSeleccionadosIniciales: _empleadosSeleccionados,
                onError: (error) => setState(() => _error = error),
                onEmpleadosSeleccionados: (empleadosIds) {
                  if (!mounted) return;
                  setState(() => _empleadosSeleccionados = empleadosIds);
                  _loadData();
                },
                onClose: () {
                  setState(() {
                    _mostrarEmpleados = false;
                  });
                },
              ),    
            ),

          // Área principal de gráficos
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Gráficos
          Expanded(
            child: _buildAllGraphs(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomButton({
    required String text,
    required VoidCallback onPressed,
    bool fullWidth = false,
  }) {
    return Container(
      height: 50,
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: const Color(0xFF7876E1),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    if (_isDisposed || !mounted) return; 

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final filtrosSeleccionados = _filtrosEmpresariales
          .expand((g) => g.filtros)
          .where((f) => f.seleccionado)
          .map((f) => f.id)
          .toList();
      
      debugPrint('Filtros seleccionados: $filtrosSeleccionados');
      
      final data = await _graphicsService.fetchGraphicsData(
        fechaIni: _dateRange!.start,
        fechaFin: _dateRange!.end,
        organiId: widget.organiId,
        empleadosIds: _empleadosSeleccionados.isNotEmpty ? _empleadosSeleccionados : null,
      );

      if (_isDisposed || !mounted) return; 

      setState(() {
        _eficiencia = double.parse(data['eficiencia']['resultado'].replaceAll(',', ''));

        final embudoProcesos = data['embudo_procesos'] ?? {};
        _productivas = (embudoProcesos['productivas'] ?? 0).toDouble();
        _noProductivas = (embudoProcesos['no_productivas'] ?? 0).toDouble();
        print('✅ EMBUDO PROCESOS - Productivas: $_productivas');
        print('✅ EMBUDO PROCESOS - No Productivas: $_noProductivas');
        
        final comparativo = data['comparativo_horas'] ?? {};
        _productivas = (comparativo['productivas'] ?? 0).toDouble();
        _noProductivas = (comparativo['no_productivas'] ?? 0).toDouble();

        _funnelData = [
          FunnelData('Horas productivas', (comparativo['productivas'] ?? 0).toDouble(), const Color(0xFF446078)),
          FunnelData('Horas no productivas', (comparativo['no_productivas'] ?? 0).toDouble(), const Color(0xFFC4DEF9)),
          FunnelData('Horas programadas', (comparativo['programadas'] ?? 0).toDouble(), const Color(0xFF232B36)),
          FunnelData('Horas de presencia', (comparativo['presencia'] ?? 0).toDouble(), const Color(0xFF64D9C5)),
        ];

        final actividad = data['sStackUltimos7Dias'];
        final labelsDias = List<String>.from(actividad['labels'] ?? []);
        final horasCon = List<double>.from(actividad['horas_productivas'].map((e) => e.toDouble()));
        final horasSin = List<double>.from(actividad['horas_no_productivas'].map((e) => e.toDouble()));

        _distribucionActividad = List.generate(labelsDias.length, (i) {
          return DatosActividad(
            dia: labelsDias[i],
            conActividad: i < horasCon.length ? horasCon[i] : 0,
            sinActividad: i < horasSin.length ? horasSin[i] : 0,
          );
        });

        final tendenciaHora = data['tendencia_por_hora'] ?? {};
        _picosLabels = List<String>.from(tendenciaHora['labelsGraficoHoras'] ?? []);
        _picosValores = List<double>.from((tendenciaHora['seriesGraficoHora'] ?? []).map((e) => e.toDouble()));

        _picosPorcentajeData = List.generate(
          tendenciaHora['labelsGraficoPorcentajeHora']?.length ?? 0,
          (index) => HoraActividadPorcentajeData(
            hora: tendenciaHora['labelsGraficoPorcentajeHora'][index],
            porcentaje: tendenciaHora['seriesGraficoPorcentajeHora'][index].toDouble(),
          ),
        );

        _actividadDiaria = data['actividad_ultimos_dias'] ?? {};

        final topEmpleados = data['top_empleados'] ?? {
          'labels': [],
          'series': {'Actividad positiva': [], 'Actividad negativa': []}
        };

        final labels = (topEmpleados['labels'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
        final positiva = (topEmpleados['series']['Actividad positiva'] as List<dynamic>? ?? []).map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
        final negativa = (topEmpleados['series']['Actividad negativa'] as List<dynamic>? ?? []).map((e) => double.tryParse(e.toString()) ?? 0.0).toList();

        _topEmpleadosData = [];
        for (int i = 0; i < labels.length; i++) {
          final nombre = labels[i].trim();
          final pos = (i < positiva.length ? positiva[i] : 0).toDouble();
          final neg = (i < negativa.length ? negativa[i] : 0).toDouble();
          final porcentajeFinal = pos != 0 ? pos : -neg;
                
          _topEmpleadosData.add(TopEmpleadoData(
            nombre: nombre,
            porcentaje: porcentajeFinal,
          ));
        }
      });
    } catch (e) {
        if (!_isDisposed && mounted) {
        setState(() {
          _error = 'Error al cargar datos: ${e.toString()}';
        });
      }
    } finally {
        if (!_isDisposed && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildAllGraphs() {
    if (_isLoading) {
      // SOLUCIÓN: Usar Center directamente sin Column para evitar overflow
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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

    // Lista de todos los gráficos
    final List<Widget> todosLosGraficos = [
      if (_eficiencia != null) 
        SizedBox(height: 350, child: GraficoEficiencia(eficiencia: _eficiencia!)),
      
      if (_funnelData.isNotEmpty)
        SizedBox(height: 350, child: GraficoEmbudo(data: _funnelData)),
      
      if (_productivas != null && _noProductivas != null)
        SizedBox(height: 350, child: GraficoDonut(productivas: _productivas!, noProductivas: _noProductivas!)),
      
      if (_distribucionActividad.isNotEmpty)
        SizedBox(height: 350, child: GraficoDistribucionActividad(datos: _distribucionActividad)),
      
      if (_picosLabels.isNotEmpty && _picosValores.isNotEmpty)
        SizedBox(height: 350, child: GraficoPicosActividad(labels: _picosLabels, valores: _picosValores)),
      
      if (_picosPorcentajeData.isNotEmpty)
        SizedBox(height: 350, child: GraficoPicosPorcentaje(datos: _picosPorcentajeData)),
      
      if (_actividadDiaria.isNotEmpty)
        SizedBox(height: 350, child: GraficoActividadDiaria(apiResponse: _actividadDiaria)),
      
      if (_topEmpleadosData.isNotEmpty)
        SizedBox(height: 400, child: GraficoTopEmpleados(data: _topEmpleadosData)),
    ];

    // Si no hay gráficos, mostrar mensaje
    if (todosLosGraficos.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_intentosRefresh < 2) ...[
                Text(
                  'Actualizar Dashboard',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 32, color: Color(0xFF757575)),
                  onPressed: () {
                    if (_intentosRefresh < 2) {
                      setState(() {
                        _intentosRefresh++;
                      });
                      _loadData();
                    }
                  },
                ),
              ] else ...[
                Text(
                  'No hay datos el día de hoy.\nCambia la fecha de tu consulta',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red[600]),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // ListView con todos los gráficos
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: todosLosGraficos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        return todosLosGraficos[index];
      },
    );
  }
}