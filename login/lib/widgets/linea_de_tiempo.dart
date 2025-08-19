import 'package:flutter/material.dart';
import 'package:login/Models/timeline_item.dart';

// Clase principal de la pantalla de la línea de tiempo
class TimelineScreen extends StatefulWidget {
  final List<dynamic> eventos; // Lista de eventos recibidos de la API
  final String baseImageUrl; // URL base para las imágenes

  const TimelineScreen({
    Key? key,
    required this.eventos,
    required this.baseImageUrl,
  }) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> with TickerProviderStateMixin {
  late AnimationController _animationController; // Controlador de animación
  late Animation<double> _fadeAnimation; // Animación de desvanecimiento
  late List<TimelineItem> items; // Lista de TimelineItem

  @override
  void initState() {
    super.initState();
    // Inicializa el controlador de animación
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // Configura la animación de desvanecimiento
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward(); // Inicia la animación

    // Convertir los datos de la API en TimelineItem
    items = widget.eventos.map((event) {
      print('Respuesta del event: $event');
      // Verifica y debuguea la estructura de las imágenes
      print('Estructura de imagen: ${event['imagen']}');
      print('Tipo de imagen: ${event['imagen']?.runtimeType}');
      
      // Obtener el valor de tiempoT y convertirlo a un entero
      int tiempoEnSegundos = event['tiempoT'];

      // Convertir tiempoT a un formato legible (HH:MM:SS)
      String tiempo = _convertirSegundosATiempo(tiempoEnSegundos);

      // CONSTRUCCIÓN SEGURA DE LA URL - PARTE MODIFICADA
      String imageUrl = '';
      if (event['imagen'] != null && 
          event['imagen'] is List && 
          event['imagen'].isNotEmpty &&
          event['imagen'][0]['imagen_grande'] != null) {
        
        String imagePath = event['imagen'][0]['imagen_grande'];
        // Asegurar que la URL se construya correctamente
        if (imagePath.startsWith('/')) {
          imageUrl = '${widget.baseImageUrl}$imagePath';
        } else {
          imageUrl = '${widget.baseImageUrl}/$imagePath';
        }
        
        print('URL de imagen construida: $imageUrl');
      } else {
        print('No se pudo construir la URL de la imagen');
      }

      return TimelineItem(
        title: event['nombre_actividad'], // Título de la actividad
        time: '${event['inicioA']} - ${event['ultimaA']}', // Formato de tiempo
        images: imageUrl.isNotEmpty ? [imageUrl] : [],
        color: Colors.blue, // Color de la tarjeta
        tiempo: tiempo,
        porcentaje: event['division']?.toString() ?? '0',
      );
    }).toList();
  }

  String _convertirSegundosATiempo(int segundos) {
    int horas = segundos ~/ 3600;
    int minutos = (segundos % 3600) ~/ 60;
    int seg = segundos % 60;
    return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${seg.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _animationController.dispose(); // Libera el controlador de animación
    super.dispose();
  }

  // Método para mostrar la imagen en pantalla completa
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context), // Regresa a la pantalla anterior
              ),
            ),
            body: Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl, // URL de la imagen
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child; // Muestra la imagen si ya se cargó
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes! // Progreso de carga
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        transitionDuration: const Duration(milliseconds: 300), // Duración de la transición
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: items.length * 210.0, // Altura total calculada
                child: Stack(
                  children: [
                    // Líneas conectoras
                    Positioned.fill(
                      child: CustomPaint(
                        painter: EnhancedChainTimelinePainter(
                          itemCount: items.length,
                          itemHeight: 210.0,
                        ),
                      ),
                    ),
                    
                    // Tarjetas de la línea de tiempo
                    Column(
                      children: List.generate(items.length, (index) {
                        return Column(
                          children: [
                            AnimatedTimelineCard(
                              item: items[index],
                              position: index % 2 == 0 
                                  ? ItemPosition.left 
                                  : ItemPosition.right,
                              onImageTap: _showFullScreenImage,
                              delay: Duration(milliseconds: index * 200),
                              cardWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            const SizedBox(height: 30),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Clase para representar un elemento de la línea de tiempo
class TimelineItem {
  final String title; // Título de la actividad
  final String time; // Tiempo de la actividad
  final List<String> images; // Lista de imágenes
  final Color color; // Color de la tarjeta
  final String tiempo; // Nuevo campo
  final String porcentaje;

  TimelineItem({
    required this.title,
    required this.time,
    required this.images,
    required this.color,
    this.tiempo = '0:00:00', // Valor por defecto para el nuevo campo
    this.porcentaje = '0', // Valor por defecto para el porcentaje
  });
}

// Clase para dibujar las líneas de la línea de tiempo
class EnhancedChainTimelinePainter extends CustomPainter {
  final int itemCount; // Número de elementos en la línea de tiempo
  final double itemHeight; // Altura de cada elemento

  EnhancedChainTimelinePainter({
    required this.itemCount,
    required this.itemHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double centerX = 200.0; // Posición central de la línea
    const double curveIntensity = 200.0; // Intensidad de la curva

    for (int i = 0; i < itemCount - 1; i++) {
      final double y = i * itemHeight + itemHeight / 2; // Posición Y del elemento
      final double nextY = (i + 1) * itemHeight + itemHeight / 2; // Posición Y del siguiente elemento
      
      final gradient = LinearGradient(
        colors: [
          Colors.blueAccent.withValues(alpha: 0.8),
          Color(0xFF1F3A5F).withValues(alpha: 0.8),
          Colors.blue.withValues(alpha: 0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      
      paint.shader = gradient.createShader(
        Rect.fromLTWH(0, y, size.width, nextY - y),
      );
      
      final path = Path();
      path.moveTo(centerX, y); // Mueve el lápiz a la posición inicial
      
      if (i % 2 == 0) {
        // Curva hacia la derecha
        path.cubicTo(
          centerX + curveIntensity, y + (nextY - y) * 0.01,
          centerX + curveIntensity, y + (nextY - y) * 1,
          centerX, nextY,
        );
      } else {
        // Curva hacia la izquierda
        path.cubicTo(
          centerX - curveIntensity, y + (nextY - y) * 0.01,
          centerX - curveIntensity, y + (nextY - y) * 1,
          centerX, nextY,
        );
      }
      
      canvas.drawPath(path, paint); // Dibuja la línea
      
      // Sombra opcional para profundidad
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      final shadowPath = Path();
      shadowPath.moveTo(centerX + 2, y + 2); // Mueve el lápiz a la posición inicial de la sombra
      
      if (i % 2 == 0) {
        shadowPath.cubicTo(
          centerX + curveIntensity + 2, y + (nextY - y) * 0.2 + 2,
          centerX + curveIntensity + 2, y + (nextY - y) * 0.8 + 2,
          centerX + 2, nextY + 2,
        );
      } else {
        shadowPath.cubicTo(
          centerX - curveIntensity + 2, y + (nextY - y) * 0.2 + 2,
          centerX - curveIntensity + 2, y + (nextY - y) * 0.8 + 2,
          centerX + 2, nextY + 2,
        );
      }
      
      canvas.drawPath(shadowPath, shadowPaint); // Dibuja la sombra
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // Indica si se debe volver a pintar
}

// Clase para la tarjeta de la línea de tiempo
class AnimatedTimelineCard extends StatelessWidget {
  final TimelineItem item; // Elemento de la línea de tiempo
  final ItemPosition position; // Posición de la tarjeta
  final Function(BuildContext, String) onImageTap; // Función para manejar el toque en la imagen
  final Duration delay; // Retraso para la animación
  final double cardWidth; // Ancho de la tarjeta

  const AnimatedTimelineCard({
    super.key,
    required this.item,
    required this.position,
    required this.onImageTap,
    required this.delay,
    this.cardWidth = 300, 
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: position == ItemPosition.left 
              ? MainAxisAlignment.start 
              : MainAxisAlignment.end,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.8, // Ancho de la tarjeta
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1F3A5F),
                    const Color(0xFF2A4A6F),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: item.color.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.title, // Título de la actividad
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2, // Permitir hasta 2 líneas
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Porcentaje
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.brown.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.brown.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${item.porcentaje.isNotEmpty ? item.porcentaje : '0'}%',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),    
                    const SizedBox(height: 12),
                    // Contenido inferior (imagen + tiempos)
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Imagen (lado izquierdo)
                          GestureDetector(
                            onTap: () => onImageTap(context, item.images[0]),
                            child: Container(
                              width: 130,
                              height: 80,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: item.color.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.network(
                                  item.images[0],
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: progress.expectedTotalBytes != null
                                            ? progress.cumulativeBytesLoaded /
                                                progress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                        color: item.color,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    // LOGS DE ERROR MEJORADOS
                                    print('Error cargando imagen: $error');
                                    print('Stack trace: $stackTrace');
                                    print('URL intentada: ${item.images[0]}');
                                    return Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: item.color,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          
                          // Tiempos (lado derecho)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Tiempo de inicio
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.access_time, 
                                        color: Colors.green, 
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.time.split(' - ')[0],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Tiempo de fin
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.access_time, 
                                        color: Colors.red, 
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.time.split(' - ')[1],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // División
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon( Icons.timer, 
                                        color: Colors.purple, 
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${item.tiempo.isNotEmpty ? item.tiempo : '0.00'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ]
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}