import 'dart:async';
import 'dart:convert'; // Para convertir datos JSON
import 'package:flutter/material.dart'; // Widgets de Flutter
import 'package:http/http.dart' as http; // Cliente HTTP para hacer peticiones
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:login/Cards/card_barras_horas.dart';
import 'package:login/Cards/card_donut.dart';
import 'package:login/Cards/card_eficiencia.dart';
import 'package:login/Cards/card_embudo.dart';
import 'package:login/Cards/card_tendencia_hora.dart';
import 'package:login/widgets/grafico_actividad_diaria.dart';
import 'package:login/widgets/grafico_embudo.dart'; // Asegúrate de que el archivo se llame así
import 'package:login/widgets/grafico_tendencia_hora.dart';
import 'package:login/widgets/grafico_top_empleados.dart';

// Widget personalizado para mostrar el gráfico
//import 'package:shared_preferences/shared_preferences.dart';

// Define la clase `DashboardScreen` como un `StatefulWidget`.
// Un `StatefulWidget` es un widget que puede cambiar su estado (datos internos) durante la vida de la aplicación.
class DashboardScreen extends StatefulWidget {
  final int organiId; //almacenamiento de Id
  final String token; //almavenamiento del token
  // Constructor de la clase `DashboardScreen`.
  // Requiere `key`, `organiId` y `token` al ser instanciado.
  const DashboardScreen({
    super.key,
    required this.organiId,
    required this.token,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState(); // Crea el estado mutable para este widget.
}

//Se crea la clase en donde se gestiona los cambios de la aplicacion
class _DashboardScreenState extends State<DashboardScreen> {
  double?
  eficiencia; // Variable para almacenar el porcentaje de eficiencia. Es `null` inicialmente, lo que significa que no tiene valor.
  List<FunnelData>?
  cumplimientoLaboralData; // Variable para almacenar los datos que alimentarán el gráfico de embudo. También es `null` inicialmente.
  double? horasProductivas;
  double? horasNoProductivas;
  double? programadas;
  double? presencia;
  double? productivas;
  List<TendenciaHoraData>? tendenciaHoras;
  bool isLoading =
      true; // Booleano que indica si los datos están cargándose. Se usa para mostrar un indicador de progreso.
  DateTime?
  fechaIni; // Variable para almacenar la fecha de inicio seleccionada por el usuario. `null` inicialmente.
  DateTime?
  fechaFin; // Variable para almacenar la fecha de fin seleccionada por el usuario. `null` inicialmente.

  bool esLinea = true;
  List<ActividadDiariaData> actividadData = [];
  List<TopEmpleadoData> topEmpleadosData = [];


  // --------- Método para obtener datos de la API ---------
  // Este método es asíncrono (`async`) porque realiza una operación que toma tiempo (una petición de red).
  Future<void> fetchDatosEficiencia() async {
    // Si `fechaIni` o `fechaFin` son nulas, la función se detiene.
    // Esto asegura que solo se haga la llamada a la API si ambas fechas han sido seleccionadas.
    if (fechaIni == null || fechaFin == null) return;

    final formato = DateFormat(
      'yyyy-MM-dd',
    ); // Crea un formateador de fechas para el formato "año-mes-día".
    final url = Uri.parse(
      'https://rhnube.com.pe/api/v5/graficsLumina',
    ); // Define la URL del endpoint de la API.

    setState(() {
      isLoading = true; // Se pone `true` para mostrar el indicador de carga.
      eficiencia = null; // Se resetea la eficiencia a `null` mientras se cargan nuevos datos.
      cumplimientoLaboralData = null; // Se resetean los datos del embudo a `null` también.
      horasProductivas = null;
      horasNoProductivas = null;
    });

    try {
      // Impresiones en consola para depuración, mostrando las fechas que se enviarán.
      print(
        'Enviando a la API: ${formato.format(fechaIni!)} → ${formato.format(fechaFin!)}',
      );
      final token = widget
          .token; // Accede al token de autenticación que fue pasado al widget.

      // Verifica si el token está vacío.
      if (token.isEmpty) {
        print(
          '⚠️ Token no encontrado. No puedes acceder a la API.',
        ); // Mensaje de advertencia.
        return; // Sale de la función si no hay token.
      }

      print(
        '🔐 Token enviado: ${widget.token}',
      ); // Impresión de depuración del token enviado.

      // Realiza la petición HTTP POST a la URL de la API.
      final response = await http.post(
        url, // La URL a la que se envía la petición.
        headers: {
          'Content-Type':
              'application/json', // Indica que el cuerpo de la petición es JSON.
          'Accept':
              'application/json', // Indica que se espera una respuesta en formato JSON.
          'Authorization':
              widget.token, // Envía el token en el encabezado de autorización.
        },
        body: jsonEncode({
          // Codifica el mapa de datos a una cadena JSON para enviarlo como cuerpo de la petición.
          'fecha_ini': formato.format(fechaIni!), // Fecha de inicio formateada.
          'fecha_fin': formato.format(fechaFin!), // Fecha de fin formateada.
          'organi_id': widget.organiId, // ID de la organización.
        }),
      );

      print(
        'Respuesta: ${response.body}',
      ); // Imprime la respuesta completa de la API para depuración.

      final body = jsonDecode(
        response.body,
      ); // Decodifica la cadena de respuesta JSON en un mapa de Dart.
      final resultado =
          body['eficiencia']?['resultado']; // Intenta extraer el valor 'resultado' del mapa 'eficiencia' en el cuerpo de la respuesta. El '?' evita errores si 'eficiencia' es nulo.
      // Intenta extraer 'comparativo_horas' de 'eficiencia', si no existe, lo busca directamente en la raíz del cuerpo.
      final comparativo =
          body['eficiencia']?['comparativo_horas'] ?? body['comparativo_horas'];
      final tendencia = body['tendencia_por_hora'];
      final actividad = body['actividad_ultimos_dias'];
      final top = body['top_empleados'];

      print("🔍 top_empleados crudo: $top");

      print(
        'Contenido de cumplimiento: ${body['comparativo_horas']}',
      ); // Impresión de depuración para los datos de cumplimiento.

      // Si `comparativo` no es nulo, significa que hay datos para el gráfico de embudo.
      if (comparativo != null) {
        print(
          '📊 Datos para embudo encontrados: $comparativo',
        ); // Impresión de depuración.
        // Asigna una lista de objetos (en tu caso, entiendo que `GraficoEmbudo` espera un `List<dynamic>` o un tipo específico).
        // Aquí se asume que los datos serán un mapa o un objeto con `label`, `value`, `color`.
        // **Nota**: Si `GraficoEmbudo` espera una clase específica como `FunnelData`, esta línea necesitaría que `FunnelData` esté definida y sea compatible.
        cumplimientoLaboralData = [
          FunnelData(
            'Horas programadas',
            (comparativo['programadas'] ?? 0).toDouble(),
            Color(0xFF1F71F0),
          ), // Se convierte el valor a `double`. Si es nulo, se usa 0.
          FunnelData(
            'Horas de presencia',
            (comparativo['presencia'] ?? 0).toDouble(),
            Color(0xFF08D7D4),
          ),
          FunnelData(
            'Horas productivas',
            (comparativo['productivas'] ?? 0).toDouble(),
            Color(0xFFF7596E),
          ),
          FunnelData(
            'Horas no productivas',
            (comparativo['no_productivas'] ?? 0).toDouble(),
            Color(0xFFFFCC66),
          ),
        ];

        horasProductivas = (comparativo['productivas'] ?? 0).toDouble();
        horasNoProductivas = (comparativo['no_productivas'] ?? 0).toDouble();
        print(
          "✅ Datos para donut: productivas=$horasProductivas | no_productivas=$horasNoProductivas",
        );

        programadas = (comparativo['programadas'] ?? 0).toDouble();
        presencia = (comparativo['presencia'] ?? 0).toDouble();
        productivas = (comparativo['productivas'] ?? 0).toDouble();

        print("✅ Datos para Barra Horas: ");
        print("- Programadas: ${comparativo['programadas']}");
        print("- Presencia: ${comparativo['presencia']}");
        print("- Productivas: ${comparativo['productivas']}");
      }

      if (tendencia != null) {
        final horas = tendencia['labels'] ?? [];
        final valores = tendencia['series'] ?? [];
        tendenciaHoras = List.generate(
          horas.length,
          (i) => TendenciaHoraData(horas[i], (valores[i] ?? 0).toDouble()),
        );
        print(
          "📈 Datos de tendencia por hora cargados: ${tendenciaHoras!.length} items",
        );
      }else {
        print('⚠️ No se encontró tendencia_por_hora en la respuesta');
      }

      if (actividad != null) {
        final dias = List<String>.from(actividad['labels'] ?? []);
        final series = actividad['series']?['Total'] ?? [];

        // Limitar a los últimos 7 días
        final int totalDias = dias.length;
        final int desde = totalDias >= 6 ? totalDias - 6 : 0;
        final ultimosDias = dias.sublist(desde);
        final ultimosValores = series
            .sublist(desde)
            .map((v) => double.tryParse(v.toString()) ?? 0)
            .toList();

        setState(() {
          actividadData = List.generate(
            ultimosDias.length,
            (i) => ActividadDiariaData(ultimosDias[i], ultimosValores[i]),
          );
        });

        for (var dato in actividadData) {
          print("📅 Día: ${dato.dia} → ${dato.porcentaje}%");
        }
      } 

      if (top != null &&
        top is Map<String, dynamic> &&
        top.containsKey('labels') &&
        top.containsKey('series')) {
      final nombres = List<String>.from(top['labels']);
      final positivas = List<double>.from(top['series']['Actividad positiva'].map((e) => (e ?? 0).toDouble()));
      final negativas = List<double>.from(top['series']['Actividad negativa'].map((e) => (e ?? 0).toDouble()));

      final nuevosTop = List.generate(nombres.length, (i) {
        print("👤 Empleado: ${nombres[i]} | +${positivas[i]} | -${negativas[i]}");
        return TopEmpleadoData(
          nombre: nombres[i],
          actividadPositiva: positivas[i],
          actividadNegativa: negativas[i],
        );
      });

      setState(() {
        topEmpleadosData = nuevosTop;
      });

      print("🎯 Total empleados en gráfico top: ${nuevosTop.length}");
    }

      // Actualiza el estado con los nuevos datos.
      setState(() {
        // Convierte el `resultado` de eficiencia a `double`. Si no puede, asigna 0.
        eficiencia = double.tryParse(resultado.toString()) ?? 0;
        isLoading = false; // Se pone `false` para ocultar el indicador de carga.
      });
    } catch (e) {
      // Captura cualquier error que ocurra durante la petición o el procesamiento.
      print('Error al cargar datos: $e'); // Imprime el error para depuración.
      setState(() {
        eficiencia = 0;
        isLoading = false;
      });
    }
  }

  // ---------------------Metodo para seleccionar fechas------------------------------------------------
  // Es asíncrono porque espera la selección del usuario en el DatePicker.
  // `esInicio` (esInicio) es un parámetro booleano para saber si se selecciona la fecha de inicio o fin.
  Future<void> _seleccionarFecha({required bool esInicio}) async {
    // Muestra el selector de fechas (Date Picker).
    final DateTime? picked = await showDatePicker(
      context: context, // El contexto actual del widget.
      initialDate:
          DateTime.now(), // La fecha que se muestra inicialmente en el selector.
      firstDate: DateTime(
        2023,
      ), // La fecha más temprana que el usuario puede seleccionar.
      lastDate:
          DateTime.now(), // La fecha más tardía que el usuario puede seleccionar (hoy).
    );

    // Si el usuario seleccionó una fecha (`picked` no es nulo).
    if (picked != null) {
      // Actualiza el estado.
      setState(() {
        if (esInicio) {
          fechaIni =
              picked; // Si `esInicio` es verdadero, asigna la fecha a `fechaIni`.
        } else {
          fechaFin = picked; // Si no, asigna la fecha a `fechaFin`.
        }
      });

      // Si ambas fechas (`fechaIni` y `fechaFin`) ya han sido seleccionadas,
      // entonces se llama a `fetchDatosEficiencia` para cargar los gráficos.
      if (fechaIni != null && fechaFin != null) {
        fetchDatosEficiencia();
      }
    }
  }

  // --------------------------- Inicialización del estado del widget -----------------------------
  @override
  void initState() {
    super
        .initState(); // Llama a la implementación del método `initState` de la clase padre.
    // La carga de datos ya no se llama aquí al inicio. Ahora se dispara cuando ambas fechas son seleccionadas.
    // Se inicializa `isLoading` como `false` para que los botones de selección de fecha sean visibles
    // desde el principio, antes de que se haga cualquier petición.
    fechaFin = DateTime.now(); // ← Establece la fecha actual por defecto
    //fechaIni = DateTime.now().subtract(const Duration(days: 7)); // 7 días antes
    isLoading = false;
  }

  // --------------- Construcción de la interfaz de usuario -----------------------
  // Este método describe la parte de la interfaz de usuario de este widget.
  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('yyyy-MM-dd');
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(title: Text('Dashboard de Organización')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _seleccionarFecha(esInicio: true),
                    child: Text(
                      fechaIni == null
                          ? 'Seleccionar inicio'
                          : 'Inicio: ${formato.format(fechaIni!)}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _seleccionarFecha(esInicio: false),
                    child: Text(
                      fechaFin == null
                          ? 'Seleccionar fin'
                          : 'Fin: ${formato.format(fechaFin!)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // ⬇️ CARD DEL GRÁFICO DE EFICIENCIA
              CardEficiencia(eficiencia: eficiencia, isLoading: isLoading),

              const SizedBox(height: 30),

              // ⬇️ CARD DEL GRÁFICO DE CUMPLIMIENTO (EMBUDO)
              if (cumplimientoLaboralData != null)
                CardEmbudo(cumplimientoLaboralData: cumplimientoLaboralData!),

              const SizedBox(height: 30),

              // 🟣 GRÁFICO DONUT
              if (horasProductivas != null && horasNoProductivas != null)
                CardDonut(
                  horasProductivas: horasProductivas,
                  horasNoProductivas: horasNoProductivas,
                ),

              const SizedBox(height: 20),

              // 📘 GRÁFICO DE BARRAS HORAS PROGRAMADAS
              if (programadas != null &&
                  presencia != null &&
                  productivas != null)
                CardBarrasHoras(
                  programadas: programadas,
                  presencia: presencia,
                  productivas: productivas,
                ),

              const SizedBox(height: 20),

              // 🔶 GRÁFICO DE TENDENCIA POR HORAS
              if (tendenciaHoras != null && tendenciaHoras!.isNotEmpty)
                CardTendenciaHora(tendenciaHoras: tendenciaHoras!),

              const SizedBox(height: 20),

              if (actividadData != null && actividadData!.isNotEmpty)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.view_week, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Actividad Diaria Últimos 7 Días',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                esLinea ? Icons.show_chart : Icons.bar_chart,
                              ),
                              onPressed: () {
                                setState(() => esLinea = !esLinea);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GraficoActividadDiaria(
                          data: actividadData!,
                          esLinea: esLinea,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              if (topEmpleadosData.isNotEmpty)
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GraficoTopEmpleados(data: topEmpleadosData),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
