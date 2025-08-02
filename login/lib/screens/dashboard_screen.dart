import 'package:flutter/material.dart';
import 'package:login/Apis/api_graphics_services.dart';
import 'package:login/Models/datos_actividad.dart';
import 'package:login/Models/datos_embudo.dart';
import 'package:login/widgets/grafico_actividad_diaria.dart';
import 'package:login/widgets/grafico_barras_horas.dart';
import 'package:login/widgets/grafico_distribucion_actividad.dart';
import 'package:login/widgets/grafico_donut.dart';
import 'package:login/widgets/grafico_eficiencia.dart';
import 'package:login/widgets/grafico_embudo.dart';
import 'package:login/widgets/grafico_picos_actividad.dart';
import 'package:login/widgets/grafico_picos_porcentaje.dart';
import 'package:login/widgets/grafico_top_empleados.dart';
import 'package:login/widgets/selector_fechas.dart';

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
  DateTimeRange? _dateRange;
  double _eficiencia = 0;
  int _currentGraphIndex = 0; // 0: Eficiencia, 1: Embudo, 2: Donut
  double _productivas = 0;
  double _noProductivas = 0;
  List<FunnelData> _funnelData = [];
  bool _isLoading = false;
  String? _error;
  List<DatosActividad> _distribucionActividad = [];
  List<String> _picosLabels = [];
  List<double> _picosValores = [];
  Map<String, dynamic> _actividadDiaria = {}; 
  List<TopEmpleadoData> _topEmpleadosData = [];
  final int totalGraficos = 9; // Total de gráficos disponibles
  

  @override
  void initState() {
    super.initState();
    _graphicsService = ApiGraphicsService(token: widget.token);
    // Establecer rango inicial (últimos 7 días)
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
          // Selector de fechas (usando tu widget)
          SelectorFechas(
            range: _dateRange!,
            onRangeSelected: (newRange) {
              if (newRange != null) {
                setState(() => _dateRange = newRange);
                _loadData();
              }
            },
          ),

          // Mensajes de estado
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

          // Gráfico actual
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    height: constraints.maxHeight * 0.8, // Usa el 80% del espacio disponible
                    child: _buildCurrentGraph(),
                  );
                },
              ),
            ),
          ),

          // Botón para cambiar de gráfico
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue[700],
              ),
              onPressed: _nextGraph,
              child: Text(
                _getNextButtonText(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildCurrentGraph() {
    switch (_currentGraphIndex) {
      case 0:
        return GraficoEficiencia(eficiencia: _eficiencia);
      case 1:
        return GraficoEmbudo(data: _funnelData);
      case 2:
        return GraficoDonut(
          productivas: _productivas,
          noProductivas: _noProductivas,
        );
      case 3:
        return GraficoBarrasHoras(
          programadas: _funnelData[0].value,
          presencia: _funnelData[1].value,
          productivas: _funnelData[2].value,
        );
      case 4:
        return GraficoDistribucionActividad(datos: _distribucionActividad);

      case 5:
        return GraficoPicosActividad(
          labels: _picosLabels,
          valores: _picosValores,
        );
      case 6:
        // Filtrar y convertir a porcentaje
        final filteredData = <HoraActividadPorcentajeData>[];
        
        for (int i = 0; i < _picosLabels.length; i++) {
          final hour = int.parse(_picosLabels[i].split(':')[0]);
          if (hour >= 8 && hour <= 18) {
            filteredData.add(HoraActividadPorcentajeData(
              hora: _picosLabels[i],
              porcentaje: _picosValores[i], // Asume que ya son porcentajes
            ));
          }
        }
        return GraficoPicosPorcentaje(datos: filteredData);

      case 7: // Ajusta el índice según tu secuencia
        return GraficoActividadDiaria(
        apiResponse: _actividadDiaria, // Asegura manejar null
      );
      case 8:
        return GraficoTopEmpleados(data: _topEmpleadosData);
            
      default:
        return const Center(child: Text('Gráfico no disponible'));
    }
  }

  String _getNextButtonText() {
    switch (_currentGraphIndex) {
      case 0:
        return 'Ver Gráfico de Embudo';
      case 1:
        return 'Ver Gráfico Donut';
      case 2:
        return 'Ver Gráfico de Barras Horas';
      case 3:
        return 'Ver Gráfico de Distribución de Actividad';
      case 4:
        return 'Ver Gráfico de Picos de Actividad';
      case 5:
        return 'Ver Gráfico de Picos de Porcentaje';    
      case 6:
        return 'Ver Gráfico de Actividad Diaria';
      case 7:
        return 'Ver Gráfico de Top Empleados';
      case 8:
        return 'Ver Gráfico de Eficiencia';
      default:
        return 'Siguiente Gráfico';
    }
  }

  void _nextGraph() {
    setState(() {
      _currentGraphIndex = (_currentGraphIndex + 1) % totalGraficos; // Cicla entre 0, 1 y 2
    });
  }

  Future<void> _loadData() async {
    if (_dateRange == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    debugPrint('Fecha inicio: ${_dateRange!.start.toIso8601String()}');
    debugPrint('Fecha fin: ${_dateRange!.end.toIso8601String()}');

    try {
      
      final data = await _graphicsService.fetchGraphicsData(
        fechaIni: _dateRange!.start,
        fechaFin: _dateRange!.end,
        organiId: widget.organiId,
      );

      // AGREGAR ESTOS DEBUGPRINT PARA VER LOS DATOS ESPECÍFICOS
      debugPrint('✅ Datos completos de actividad_ultimos_dias: ${data['actividad_ultimos_dias']}');
      debugPrint('✅ Estructura completa de top_empleados: ${data['actividad_ultimos_dias']['top_empleados']}');
      debugPrint('-----------------------------------------------');

      setState(() {
        // Procesar datos de eficiencia
        _eficiencia = double.parse(data['eficiencia']['resultado'].replaceAll(',', ''));
        
        // 2. Procesar datos comparativos
        final comparativo = data['comparativo_horas'] ?? {};
        _productivas = (comparativo['productivas'] ?? 0).toDouble();
        _noProductivas = (comparativo['no_productivas'] ?? 0).toDouble();

        // Procesar datos para el embudo (adaptado a tu modelo FunnelData)
        _funnelData = [
          FunnelData(
            'Horas programadas', 
            (comparativo['programadas'] ?? 0).toDouble(), 
            const Color(0xFF0868FB)
          ),
          FunnelData(
            'Horas de presencia', 
            (comparativo['presencia'] ?? 0).toDouble(), 
            const Color(0xFF2BCA07)
          ),
          FunnelData(
            'Horas productivas', 
            (comparativo['productivas'] ?? 0).toDouble(), 
            const Color(0xFFFF1A15)
          ),
          FunnelData(
            'Horas no productivas', 
            (comparativo['no_productivas'] ?? 0).toDouble(), 
            const Color(0xFFFDF807)
          ),
        ];

        // 5. Procesar datos de distribución de actividad registrada
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

        // 6. Procesar datos de picos de actividad (si es necesario)
        final tendenciaHora = data['tendencia_por_hora'] ?? {};
        _picosLabels = List<String>.from(tendenciaHora['labelsGraficoHoras'] ?? []);
        _picosValores = List<double>.from(
          (tendenciaHora['seriesGraficoHora'] ?? []).map((e) => e.toDouble()));

        debugPrint('Labels picos: $_picosLabels');
        debugPrint('Valores picos: $_picosValores');

        //8. Procesar datos de actividad diaria

        _actividadDiaria = data['actividad_ultimos_dias'] ?? {};
        debugPrint('📊 actividad_ultimos_dias desglosado:');
        debugPrint('Labels: ${_actividadDiaria['labels']}');
        debugPrint('Series - Total: ${_actividadDiaria['series']?['Total']}');

        // 9. Procesar datos de top empleados
        final topEmpleados = data['top_empleados'] ?? {
          'labels': [],
          'series': {
            'Actividad positiva': [],
            'Actividad negativa': []
          }
        };

        debugPrint('Estructura de top_empleados: $topEmpleados');

        final labels = (topEmpleados['labels'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
        final positiva = (topEmpleados['series']['Actividad positiva'] as List<dynamic>? ?? []).map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
        final negativa = (topEmpleados['series']['Actividad negativa'] as List<dynamic>? ?? []).map((e) => double.tryParse(e.toString()) ?? 0.0).toList();

        debugPrint('🏆 top_empleados desglosado:');
        debugPrint('Labels: ${topEmpleados['labels']}');
        debugPrint('Series - Actividad positiva: ${topEmpleados['series']?['Actividad positiva']}');
        debugPrint('Series - Actividad negativa: ${topEmpleados['series']?['Actividad negativa']}');
        debugPrint('-----------------------------------------------');

        _topEmpleadosData = [];

        for (int i = 0; i < labels.length; i++) {
          final nombre = labels[i].trim();
          
          // Conversión segura a double
          final pos = (i < positiva.length ? positiva[i] : 0).toDouble();
          final neg = (i < negativa.length ? negativa[i] : 0).toDouble();
          
          final porcentajeFinal = pos != 0 ? pos : -neg;
                
          _topEmpleadosData.add(TopEmpleadoData(
            nombre: nombre,
            porcentaje: porcentajeFinal,
          ));
        }
        debugPrint('Datos procesados: ${_topEmpleadosData.length} empleados');
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