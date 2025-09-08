import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

// Clase principal de la pantalla de la línea de tiempo
class TimelineScreen extends StatefulWidget {
  final List<dynamic> eventos;
  final bool tieneMasDatos;
  final Function() onCargarMas;
  final bool cargandoMas;
  final String authToken;
  
  const TimelineScreen({
    super.key,
    required this.eventos,
    required this.tieneMasDatos,
    required this.onCargarMas,
    required this.cargandoMas, 
    required this.authToken,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<TimelineItem> items;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _scrollController.addListener(_onScroll);
    _processItems();
  }

  // Método para obtener el color según la eficiencia (igual que en diario_lista_screen)
  Color _getColorEficiencia(double eficiencia) {
    if (eficiencia >= 50) return Color(0xFF64D9C5); // Verde
    if (eficiencia >= 30) return Color(0xFFFFC066); // Naranja
    return Color(0xFFFF625C); // Rojo
  }

  void _processItems() {
    if (!mounted) return;

    items = widget.eventos.map((event) {
      int tiempoEnSegundos = event['tiempoT'];
      String tiempo = _convertirSegundosATiempo(tiempoEnSegundos);

      // Obtener porcentaje y determinar color
      double porcentaje = double.tryParse(event['division']?.toString() ?? '0') ?? 0.0;
      Color colorPorcentaje = _getColorEficiencia(porcentaje);

      // Manejar imágenes en base64
      List<Uint8List> imageBytesList = [];
      if (event['imagen'] != null && 
          event['imagen'] is List && 
          event['imagen'].isNotEmpty) {
        
        for (var imgData in event['imagen']) {
          if (imgData['miniatura'] != null) {
            try {
              String base64String = imgData['miniatura'];
              // Extraer solo la parte base64 (eliminar el prefijo data:image/...)
              if (base64String.contains(',')) {
                base64String = base64String.split(',').last;
              }
              
              Uint8List bytes = base64.decode(base64String);
              imageBytesList.add(bytes);
            } catch (e) {
              debugPrint('Error decodificando base64: $e');
            }
          }
        }
      }

      return TimelineItem(
        title: event['nombre_actividad'],
        time: '${event['inicioA']} - ${event['ultimaA']}',
        imageBytesList: imageBytesList,
        color: Color(0xFFF8F7FC),
        tiempo: tiempo,
        porcentaje: porcentaje.toStringAsFixed(1),
        colorPorcentaje: colorPorcentaje, // Nuevo campo para el color
      );
    }).toList();
  }

  String _convertirSegundosATiempo(int segundos) {
    int horas = segundos ~/ 3600;
    int minutos = (segundos % 3600) ~/ 60;
    int seg = segundos % 60;
    return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${seg.toString().padLeft(2, '0')}';
  }

  void _onScroll() {
    debugPrint('💫 Scroll position: ${_scrollController.position.pixels.toStringAsFixed(1)}');
    debugPrint('📏 Max scroll: ${_scrollController.position.maxScrollExtent.toStringAsFixed(1)}');
    if (!mounted) return;

    // Cargar más datos cuando esté cerca del final
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 100) {
        debugPrint('🚀 ¡Cargando más datos!');
      _cargarMasDatos();
    }
  }

  void _cargarMasDatos() {
    if (widget.tieneMasDatos && !widget.cargandoMas && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      
      widget.onCargarMas();
      
      // Resetear el estado de carga después de un tiempo
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(TimelineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!mounted) return;
    
    if (oldWidget.eventos != widget.eventos) {
      _processItems();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFullScreenImage(BuildContext context, Uint8List imageBytes) {
    if (!mounted) return;

    
    final TransformationController _transformationController = 
        TransformationController();

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
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Hero(
                tag: 'imageHero_${DateTime.now().millisecondsSinceEpoch}',
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  panEnabled: true,
                  minScale: 0.1,  // ← Valor mínimo seguro
                  maxScale: 4.0,
                  boundaryMargin: EdgeInsets.all(20),
                  onInteractionEnd: (details) {
                    // Prevenir que la escala llegue a 0
                    final scale = _transformationController.value.getMaxScaleOnAxis();
                    if (scale < 0.1) {
                      _transformationController.value = Matrix4.identity();
                    }
                  },
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return SizedBox.shrink();
    
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // CABECERA BONITA
            const SizedBox(height: 20),
            
            // CONTENEDOR PRINCIPAL CON SCROLL
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // LIENZO DE LA LÍNEA DE TIEMPO (¡Manteniendo tu arte!)
                          SizedBox(
                            height: items.length * 210.0,
                            child: Stack(
                              children: [
                                // LÍNEAS DE CONEXIÓN (Tu diseño original)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: EnhancedChainTimelinePainter(
                                      itemCount: items.length,
                                      itemHeight: 210.0,
                                    ),
                                  ),
                                ),
                                
                                // TARJETAS ANIMADAS
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
                    
                          // INDICADORES DE CARGA (Footer)
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MÉTODO PARA EL FOOTER BONITO
  Widget _buildFooter() {
    return Column(
      children: [
        if (widget.cargandoMas || _isLoadingMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(color: Colors.purpleAccent),
          ),
        
        if (!widget.tieneMasDatos && items.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              '✨ No hay más eventos por ahora',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        
        const SizedBox(height: 40),
      ],
    );
  }
}

// Clase para representar un elemento de la línea de tiempo (MODIFICADA)
class TimelineItem {
  final String title;
  final String time;
  final List<Uint8List> imageBytesList;
  final Color color;
  final String tiempo;
  final String porcentaje;
  final Color colorPorcentaje;

  TimelineItem({
    required this.title,
    required this.time,
    required this.imageBytesList,
    required this.color,
    this.tiempo = '0:00:00',
    this.porcentaje = '0',
    required this.colorPorcentaje,
  });
}

// Clase para dibujar las líneas de la línea de tiempo
class EnhancedChainTimelinePainter extends CustomPainter {
  final int itemCount;
  final double itemHeight;

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

    const double centerX = 200.0;
    const double curveIntensity = 200.0;

    for (int i = 0; i < itemCount - 1; i++) {
      final double y = i * itemHeight + itemHeight / 2;
      final double nextY = (i + 1) * itemHeight + itemHeight / 2;
      
      final gradient = LinearGradient(
        colors: [
          Color(0xFF7956A8).withAlpha(128),
          Color(0xFF3E2B6B).withAlpha(128),
          Color(0xFF7876E1).withAlpha(128),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      
      paint.shader = gradient.createShader(
        Rect.fromLTWH(0, y, size.width, nextY - y),
      );
      
      final path = Path();
      path.moveTo(centerX, y);
      
      if (i % 2 == 0) {
        path.cubicTo(
          centerX + curveIntensity, y + (nextY - y) * 0.01,
          centerX + curveIntensity, y + (nextY - y) * 1,
          centerX, nextY,
        );
      } else {
        path.cubicTo(
          centerX - curveIntensity, y + (nextY - y) * 0.01,
          centerX - curveIntensity, y + (nextY - y) * 1,
          centerX, nextY,
        );
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Enum para la posición de la tarjeta
enum ItemPosition { left, right }

// Clase para la tarjeta de la línea de tiempo (MODIFICADA)
class AnimatedTimelineCard extends StatelessWidget {
  final TimelineItem item;
  final ItemPosition position;
  final Function(BuildContext, Uint8List) onImageTap;
  final Duration delay;
  final double cardWidth;

  const AnimatedTimelineCard({
    super.key,
    required this.item,
    required this.position,
    required this.onImageTap,
    required this.delay,
    this.cardWidth = 280, 
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
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                color: Color(0xFFF8F7FC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: item.color.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // BADGE MODIFICADO - Usa el color según productividad
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.colorPorcentaje.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: item.colorPorcentaje,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${item.porcentaje.isNotEmpty ? item.porcentaje : '0'}%',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),    
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (item.imageBytesList.isNotEmpty)
                          GestureDetector(
                            onTap: () => onImageTap(context, item.imageBytesList[0]),
                            child: Hero(
                              tag: 'imageHero_${item.title}',
                              child: Container(
                                width: 130,
                                height: 80,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: item.color.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.memory(
                                    item.imageBytesList[0],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[800],
                                        child: Icon(
                                          Icons.error,
                                          color: item.color,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          )
                          else
                          Container(
                            width: 130,
                            height: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: item.color.withOpacity(0.3),
                                width: 1,
                              ),
                              color: Colors.grey[800],
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              color: item.color,
                              size: 40,
                            ),
                          ),
                          
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                
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
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon( Icons.timer, 
                                        color: Color(0xFF3E2B6B),
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${item.tiempo.isNotEmpty ? item.tiempo : '0.00'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
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