import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:login/widgets/image_viewer_centrado.dart';
import 'package:login/widgets/lumina.dart';

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
  bool _isInitialLoading = true; // Nuevo estado para carga inicial

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
    
    // Simular carga inicial
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    });
  }

  Color _getColorEficiencia(double eficiencia) {
    if (eficiencia >= 50) return Color(0xFF64D9C5);
    if (eficiencia >= 30) return Color(0xFFFFC066);
    return Color(0xFFFF625C);
  }

  void _processItems() {
    if (!mounted) return;

    items = widget.eventos.map((event) {
      int tiempoEnSegundos = event['tiempoT'];
      String tiempo = _convertirSegundosATiempo(tiempoEnSegundos);

      double porcentaje = double.tryParse(event['division']?.toString() ?? '0') ?? 0.0;
      Color colorPorcentaje = _getColorEficiencia(porcentaje);

      List<Uint8List> imageBytesList = [];
      if (event['imagen'] != null && event['imagen'] is List && event['imagen'].isNotEmpty) {
        for (var imgData in event['imagen']) {
          if (imgData['miniatura'] != null) {
            try {
              String base64String = imgData['miniatura'];
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
        colorPorcentaje: colorPorcentaje,
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
    if (!mounted) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {     
      _cargarMasDatos();
    }
  }

  void _cargarMasDatos() {
    if (widget.tieneMasDatos && !widget.cargandoMas && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      
      widget.onCargarMas();
      
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

  @override
  Widget build(BuildContext context) {
    if (!mounted) return SizedBox.shrink();
    
    // Si está cargando inicialmente, mostrar pantalla completa de carga
    if (_isInitialLoading) {
      return _buildFullScreenLoader();
    }
    
    return Scaffold(
      body: Stack(
        children: [
          // Contenido principal
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: 2, // Solo 2 items: timeline completo + footer
                    cacheExtent: 500.0,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Item principal: toda la línea + todo el contenido
                        return RepaintBoundary(
                          key: const ValueKey('full_timeline'),
                          child: Stack(
                            children: [
                              // Línea curva completa - scrollea con todo
                              Positioned.fill(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Calculamos la altura real basada en el contenido
                                    double totalHeight = constraints.maxHeight;
                                    double calculatedItemHeight = items.length > 1 
                                        ? totalHeight / items.length 
                                        : 300.0; // altura por defecto si solo hay 1 item
                                    
                                    return CustomPaint(
                                      painter: EnhancedChainTimelinePainter(
                                        itemCount: items.length,
                                        itemHeight: calculatedItemHeight,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Todo el contenido del timeline
                              Column(
                                children: List.generate(items.length, (itemIndex) {
                                  return RepaintBoundary(
                                    key: ValueKey('timeline_card_$itemIndex'),
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: itemIndex < items.length - 1 ? 30 : 0),
                                      child: AnimatedTimelineCard(
                                        item: items[itemIndex],
                                        position: itemIndex % 2 == 0 ? ItemPosition.left : ItemPosition.right,
                                        delay: Duration(milliseconds: itemIndex * 50),
                                        cardWidth: MediaQuery.of(context).size.width * 0.8,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Footer
                        return _buildFooter();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Overlay de carga para cargar más elementos
          if (widget.cargandoMas || _isLoadingMore)
            _buildFullScreenLoader(),
        ],
      ),
    );
  }

  // Pantalla completa de carga con Lumina
  Widget _buildFullScreenLoader() {
    return Container(
      color: Colors.white.withOpacity(0.9), // Fondo semitransparente
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lumina(
              assetPath: 'assets/imagen/luminaos.png',
              duracion: Duration(milliseconds: 1500),
              size: 120,
            ),
            SizedBox(height: 20),
            Text(
              _isInitialLoading ? 'Cargando línea de tiempo...' : 'Cargando más eventos...',
              style: TextStyle(
                color: Color(0xFF3E2B6B),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
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

// Las demás clases (TimelineItem, EnhancedChainTimelinePainter, AnimatedTimelineCard)
// se mantienen igual que en tu código original

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
  final Duration delay;
  final double cardWidth;

  const AnimatedTimelineCard({
    super.key,
    required this.item,
    required this.position,
    required this.delay,
    this.cardWidth = 280, 
  });

  // Método para obtener el color según la eficiencia
  Color _getColorEficiencia(double eficiencia) {
    if (eficiencia >= 50) return const Color(0xFF64D9C5); // Verde
    if (eficiencia >= 30) return const Color(0xFFFFC066); // Naranja
    return const Color(0xFFFF625C); // Rojo
  }

  @override
  Widget build(BuildContext context) {
    // Convertir el porcentaje string a double
    double porcentaje = double.tryParse(item.porcentaje) ?? 0.0;
    
    return SizedBox(
      height: 210,
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
                color: const Color(0xFFF8F7FC),
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
                  mainAxisSize: MainAxisSize.min,
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
                      ],
                    ),    
                    const SizedBox(height: 10),
                    
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (item.imageBytesList.isNotEmpty)
                          GestureDetector(
                            onTap: () => showFullScreenImageCentrado(
                              context,
                              imageBytes: item.imageBytesList[0],
                              heroTag: 'imageHero_${item.title}',
                            ),
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
                                    const Icon(Icons.access_time, 
                                        color: Colors.green, 
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.time.split(' - ')[0],
                                      style: const TextStyle(
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
                                    const Icon(Icons.access_time, 
                                        color: Colors.red, 
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.time.split(' - ')[1],
                                      style: const TextStyle(
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
                                    const Icon( Icons.timer, 
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

                    // BARRA DE PROGRESO EN LA PARTE INFERIOR
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              // Fondo de la barra
                              Container(
                                width: 220,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Color(0xFFE7E7F3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // Barra de progreso
                              Container(
                                width: 220 * (porcentaje / 100),
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _getColorEficiencia(porcentaje),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // Texto del porcentaje
                              Positioned.fill(
                                child: Center(
                                  child: Text(
                                    "${porcentaje.toStringAsFixed(1)}%",
                                    style: const TextStyle(
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