import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';
import 'package:login/Models/datos_actividad.dart';
import 'package:login/Models/datos_embudo.dart';
import 'package:login/Models/filtro_data.dart';
import 'package:login/widgets/grafico_actividad_diaria.dart';
import 'package:login/widgets/grafico_barras_horas.dart';
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
  double _eficiencia = 0;
  int _currentGraphIndex = 0;
  double _productivas = 0;
  double _noProductivas = 0;
  List<FunnelData> _funnelData = [];
  bool _isLoading = false;
  String? _error;
  List<DatosActividad> _distribucionActividad = [];
  List<String> _picosLabels = [];
  List<double> _picosValores = [];
  List<HoraActividadPorcentajeData> _picosPorcentajeData = []; 
  Map<String, dynamic> _actividadDiaria = {}; 
  List<TopEmpleadoData> _topEmpleadosData = [];
  final int totalGraficos = 9;

  @override
  void initState() {
    super.initState();
    _graphicsService = ApiGraphicsService(token: widget.token, organiId: widget.organiId);
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Gráficos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _dateRange != null ? _loadData : null,
          ),
        ],
      ),
      body: Column(
        children: [
          SelectorFechas(
            range: _dateRange!,
            onRangeSelected: (newRange) {
              if (newRange != null) {
                setState(() => _dateRange = newRange);
                _loadData();
              }
            },
          ),

          // Botones con nuevo estilo
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

          if (_mostrarFiltros)
            SizedBox(
              height: 300,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SelectorFiltros(
                  graphicsService: _graphicsService,
                  onFiltrosChanged: (filtros) {
                    setState(() => _filtrosEmpresariales = filtros);
                    _loadData();
                  },
                ),
              ),
          ),

          if (_mostrarEmpleados)
            SizedBox(
              height: 300,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SelectorEmpleado(
                  graphicsService: _graphicsService,
                  filtrosEmpresariales: _filtrosEmpresariales,
                  empleadosSeleccionadosIniciales: _empleadosSeleccionados,
                  onError: (error) => setState(() => _error = error),
                  onEmpleadosSeleccionados: (empleadosIds) {
                    setState(() => _empleadosSeleccionados = empleadosIds);
                    _loadData();
                  },
                ),
              ),
            ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          if (_isLoading)
            const LinearProgressIndicator(),

          // Gráfico reducido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 250, // Altura reducida del gráfico
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildCurrentGraph(),
              ),
            ),
          ),

          // Botón de cambio de gráfico con nuevo estilo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCustomButton(
              text: _getNextButtonText(),
              onPressed: _nextGraph,
              fullWidth: true,
            ),
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
        color: Color(0xFFFBB347), // Amarillo medio
        borderRadius: BorderRadius.circular(8),
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
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black, // Texto negro
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentGraph() {
    switch (_currentGraphIndex) {
      case 0: return GraficoEficiencia(eficiencia: _eficiencia);
      case 1: return GraficoEmbudo(data: _funnelData);
      case 2: return GraficoDonut(productivas: _productivas, noProductivas: _noProductivas);
      case 3: return GraficoBarrasHoras(
                programadas: _funnelData[0].value,
                presencia: _funnelData[1].value,
                productivas: _funnelData[2].value);
      case 4: return GraficoDistribucionActividad(datos: _distribucionActividad);
      case 5: return GraficoPicosActividad(labels: _picosLabels, valores: _picosValores);
      case 6: 
        final filteredData = <HoraActividadPorcentajeData>[];
        for (int i = 0; i < _picosLabels.length; i++) {
          final hour = int.parse(_picosLabels[i].split(':')[0]);
          if (hour >= 8 && hour <= 18) {
            filteredData.add(HoraActividadPorcentajeData(
              hora: _picosLabels[i],
              porcentaje: _picosValores[i],
            ));
          }
        }
        return GraficoPicosPorcentaje(datos: _picosPorcentajeData);
      case 7: return GraficoActividadDiaria(apiResponse: _actividadDiaria);
      case 8: return GraficoTopEmpleados(data: _topEmpleadosData);
      default: return const Center(child: Text('Gráfico no disponible'));
    }
  }

  String _getNextButtonText() {
    final texts = [
      'Ver Gráfico de Embudo',
      'Ver Gráfico Donut',
      'Ver Gráfico de Barras Horas',
      'Ver Gráfico de Distribución',
      'Ver Gráfico de Picos',
      'Ver Gráfico de Porcentaje',    
      'Ver Gráfico Diario',
      'Ver Top Empleados',
      'Ver Eficiencia'
    ];
    return texts[_currentGraphIndex % totalGraficos];
  }

  void _nextGraph() {
    setState(() {
      _currentGraphIndex = (_currentGraphIndex + 1) % totalGraficos;
    });
  }

  Future<void> _loadData() async {
    if (_dateRange == null) return;

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
      
      final data = await _graphicsService.fetchGraphicsData(
        fechaIni: _dateRange!.start,
        fechaFin: _dateRange!.end,
        organiId: widget.organiId,
        empleadosIds: _empleadosSeleccionados.isNotEmpty ? _empleadosSeleccionados : null,
      );

      setState(() {
        _eficiencia = double.parse(data['eficiencia']['resultado'].replaceAll(',', ''));
        
        final comparativo = data['comparativo_horas'] ?? {};
        _productivas = (comparativo['productivas'] ?? 0).toDouble();
        _noProductivas = (comparativo['no_productivas'] ?? 0).toDouble();

        _funnelData = [
          FunnelData('Horas productivas', (comparativo['productivas'] ?? 0).toDouble(), const Color(0xFF0868FB)),
          FunnelData('Horas no productivas', (comparativo['no_productivas'] ?? 0).toDouble(), const Color(0xFFFDF807)),
          FunnelData('Horas programadas', (comparativo['programadas'] ?? 0).toDouble(), const Color(0xFFFF1A15)),
          FunnelData('Horas de presencia', (comparativo['presencia'] ?? 0).toDouble(), const Color(0xFF2BCA07)),
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
      setState(() {
        _error = 'Error al cargar datos: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}