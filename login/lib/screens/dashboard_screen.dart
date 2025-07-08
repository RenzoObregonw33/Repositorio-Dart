import 'dart:async';
import 'dart:convert';                    // Para convertir datos JSON
import 'package:flutter/material.dart';   // Widgets de Flutter
import 'package:http/http.dart' as http;  // Cliente HTTP para hacer peticiones
import 'package:intl/intl.dart';          // Para formatear fechas
import 'package:login/widgets/grafico_donut.dart';
import 'package:login/widgets/grafico_eficiencia.dart';
import 'package:login/widgets/grafico_embudo.dart'; // Asegúrate de que el archivo se llame así
 // Widget personalizado para mostrar el gráfico
//import 'package:shared_preferences/shared_preferences.dart';


// Define la clase `DashboardScreen` como un `StatefulWidget`.
// Un `StatefulWidget` es un widget que puede cambiar su estado (datos internos) durante la vida de la aplicación.
class DashboardScreen extends StatefulWidget {
  final int organiId;                               //almacenamiento de Id
  final String token;                               //almavenamiento del token
  // Constructor de la clase `DashboardScreen`.
  // Requiere `key`, `organiId` y `token` al ser instanciado.
  const DashboardScreen({super.key, required this.organiId, required this.token});    

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();      // Crea el estado mutable para este widget.
}
 //Se crea la clase en donde se gestiona los cambios de la aplicacion
class _DashboardScreenState extends State<DashboardScreen> {
  double? eficiencia;     // Variable para almacenar el porcentaje de eficiencia. Es `null` inicialmente, lo que significa que no tiene valor.
  List<FunnelData>? cumplimientoLaboralData; // Variable para almacenar los datos que alimentarán el gráfico de embudo. También es `null` inicialmente.
  double? horasProductivas;
  double? horasNoProductivas;
  bool isLoading = true; // Booleano que indica si los datos están cargándose. Se usa para mostrar un indicador de progreso.
  DateTime? fechaIni; // Variable para almacenar la fecha de inicio seleccionada por el usuario. `null` inicialmente.
  DateTime? fechaFin; // Variable para almacenar la fecha de fin seleccionada por el usuario. `null` inicialmente.
  
// --------- Método para obtener datos de la API ---------
  // Este método es asíncrono (`async`) porque realiza una operación que toma tiempo (una petición de red).
  Future<void> fetchDatosEficiencia() async {
    // Si `fechaIni` o `fechaFin` son nulas, la función se detiene.
    // Esto asegura que solo se haga la llamada a la API si ambas fechas han sido seleccionadas.
    if (fechaIni == null || fechaFin == null) return;

    final formato = DateFormat('yyyy-MM-dd'); // Crea un formateador de fechas para el formato "año-mes-día".
    final url = Uri.parse('https://rhnube.com.pe/api/v5/graficsLumina'); // Define la URL del endpoint de la API.

    setState(() {
      isLoading = true; // Se pone `true` para mostrar el indicador de carga.
      eficiencia = null; // Se resetea la eficiencia a `null` mientras se cargan nuevos datos.
      cumplimientoLaboralData = null; // Se resetean los datos del embudo a `null` también.
    });

     try {
      // Impresiones en consola para depuración, mostrando las fechas que se enviarán.
      print('Enviando a la API: ${formato.format(fechaIni!)} → ${formato.format(fechaFin!)}');
      final token = widget.token; // Accede al token de autenticación que fue pasado al widget.

      // Verifica si el token está vacío.
      if (token.isEmpty) {
        print('⚠️ Token no encontrado. No puedes acceder a la API.'); // Mensaje de advertencia.
        return; // Sale de la función si no hay token.
      }

      print('🔐 Token enviado: ${widget.token}'); // Impresión de depuración del token enviado.

      // Realiza la petición HTTP POST a la URL de la API.
      final response = await http.post(
        url, // La URL a la que se envía la petición.
        headers: {
          'Content-Type': 'application/json', // Indica que el cuerpo de la petición es JSON.
          'Accept': 'application/json', // Indica que se espera una respuesta en formato JSON.
          'Authorization': widget.token, // Envía el token en el encabezado de autorización.
        },
        body: jsonEncode({
          // Codifica el mapa de datos a una cadena JSON para enviarlo como cuerpo de la petición.
          'fecha_ini': formato.format(fechaIni!), // Fecha de inicio formateada.
          'fecha_fin': formato.format(fechaFin!), // Fecha de fin formateada.
          'organi_id': widget.organiId, // ID de la organización.
        }),
      );

      print('Respuesta: ${response.body}'); // Imprime la respuesta completa de la API para depuración.

      final body = jsonDecode(response.body); // Decodifica la cadena de respuesta JSON en un mapa de Dart.
      final resultado = body['eficiencia']?['resultado']; // Intenta extraer el valor 'resultado' del mapa 'eficiencia' en el cuerpo de la respuesta. El '?' evita errores si 'eficiencia' es nulo.
      // Intenta extraer 'comparativo_horas' de 'eficiencia', si no existe, lo busca directamente en la raíz del cuerpo.
      final comparativo = body['eficiencia']?['comparativo_horas'] ?? body['comparativo_horas'];

      print('Contenido de cumplimiento: ${body['comparativo_horas']}'); // Impresión de depuración para los datos de cumplimiento.

      // Si `comparativo` no es nulo, significa que hay datos para el gráfico de embudo.
      if (comparativo != null) {
        print('📊 Datos para embudo encontrados: $comparativo');  // Impresión de depuración.
        // Asigna una lista de objetos (en tu caso, entiendo que `GraficoEmbudo` espera un `List<dynamic>` o un tipo específico).
        // Aquí se asume que los datos serán un mapa o un objeto con `label`, `value`, `color`.
        // **Nota**: Si `GraficoEmbudo` espera una clase específica como `FunnelData`, esta línea necesitaría que `FunnelData` esté definida y sea compatible.
        cumplimientoLaboralData = [
          FunnelData('Horas programadas', (comparativo['programadas'] ?? 0).toDouble(),Colors.blue,),  // Se convierte el valor a `double`. Si es nulo, se usa 0.
          FunnelData('Horas de presencia', (comparativo['presencia'] ?? 0).toDouble(), Colors.orange),
          FunnelData('Horas productivas', (comparativo['productivas'] ?? 0).toDouble(), Colors.red),
          FunnelData('Horas no productivas', (comparativo['no_productivas'] ?? 0).toDouble(),Colors.green),
        ];

        horasProductivas = (comparativo['productivas'] ?? 0).toDouble();
        horasNoProductivas = (comparativo['no_productivas'] ?? 0).toDouble();
        print("✅ Datos para donut: productivas=$horasProductivas | no_productivas=$horasNoProductivas");
        
      } else {
        print('⚠️ No se encontró comparativo_horas en la respuesta');     // Mensaje si no se encuentran los datos esperados.
      }


      print('📊 Datos para embudo: $cumplimientoLaboralData');

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
        eficiencia = 0; // Se asigna 0 a eficiencia en caso de error.
        isLoading = false; // Se oculta el indicador de carga.
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
      initialDate: DateTime.now(), // La fecha que se muestra inicialmente en el selector.
      firstDate: DateTime(2023), // La fecha más temprana que el usuario puede seleccionar.
      lastDate: DateTime.now(), // La fecha más tardía que el usuario puede seleccionar (hoy).
    );

  // Si el usuario seleccionó una fecha (`picked` no es nulo).
    if (picked != null) {
      // Actualiza el estado.
      setState(() {
        if (esInicio) {
          fechaIni = picked; // Si `esInicio` es verdadero, asigna la fecha a `fechaIni`.
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
    super.initState(); // Llama a la implementación del método `initState` de la clase padre.
    // La carga de datos ya no se llama aquí al inicio. Ahora se dispara cuando ambas fechas son seleccionadas.
    // Se inicializa `isLoading` como `false` para que los botones de selección de fecha sean visibles
    // desde el principio, antes de que se haga cualquier petición.
    isLoading = false;
  }

  // --------------- Construcción de la interfaz de usuario -----------------------
  // Este método describe la parte de la interfaz de usuario de este widget.
  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('yyyy-MM-dd');
    return Scaffold(
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
                    child: Text(fechaIni == null
                        ? 'Seleccionar inicio'
                        : 'Inicio: ${formato.format(fechaIni!)}'),
                  ),
                  ElevatedButton(
                    onPressed: () => _seleccionarFecha(esInicio: false),
                    child: Text(fechaFin == null
                        ? 'Seleccionar fin'
                        : 'Fin: ${formato.format(fechaFin!)}'),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // ⬇️ CARD DEL GRÁFICO DE EFICIENCIA
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.speed, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '% Eficiencia en ejecución de actividades',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : eficiencia != null
                                ? GraficoEficiencia(eficiencia: eficiencia!)
                                : const Text('Seleccione fechas para ver el gráfico.'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ⬇️ CARD DEL GRÁFICO DE CUMPLIMIENTO (EMBUDO)
              if (cumplimientoLaboralData != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bar_chart, color: Colors.teal),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Análisis de Cumplimiento Laboral',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        cumplimientoLaboralData!.isNotEmpty
                        ? GraficoEmbudo(data: cumplimientoLaboralData!)
                        : const Text('No hay datos suficientes para mostrar el gráfico.'),
                      ],
                    ),
                  ),
                ),

               const SizedBox(height: 30),

              // 🟣 Gráfico Donut
              if (horasProductivas != null && horasNoProductivas != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.filter_alt, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Distribución de Actividad Laboral',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GraficoDonut(
                          productivas: horasProductivas!,
                          noProductivas: horasNoProductivas!,
                        ),
                      ],
                    ),
                  ),
                ) 
            ],
          ),
        ),
      ),
    );
  }
}
