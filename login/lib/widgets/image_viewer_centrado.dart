import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageViewerCentrado extends StatefulWidget {
  final Uint8List imageBytes;
  final String heroTag;

  const ImageViewerCentrado({
    super.key,
    required this.imageBytes,
    required this.heroTag,
  });

  @override
  State<ImageViewerCentrado> createState() => _ImageViewerCentradoState();
}

class _ImageViewerCentradoState extends State<ImageViewerCentrado> {
  final double _minScale = 0.8;
  final double _maxScale = 3.0;
  final double _doubleTapScale = 1.5;
  
  double _currentScale = 0.4;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  double _previousScale = 0.4;
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    
    // Simular carga de imagen
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isImageLoaded = true;
          _centerImage();
        });
      }
    });
  }

  void _centerImage() {
    if (!mounted) return;
    
    setState(() {
      _currentScale = _minScale;
      _offset = Offset.zero;
      _previousScale = _minScale;
      _previousOffset = Offset.zero;
    });
  }

  void _handleDoubleTap() {
    setState(() {
      if (_currentScale == _minScale) {
        _currentScale = _doubleTapScale;
      } else {
        _currentScale = _minScale;
        _offset = Offset.zero; // Resetear offset al volver al zoom mínimo
      }
      _previousScale = _currentScale;
    });
  }

  void _onScaleStart(ScaleStartDetails details) {
    _previousOffset = _offset;
    _previousScale = _currentScale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Zoom con pinch
      if (details.scale != 1.0) {
        _currentScale = (_previousScale * details.scale).clamp(_minScale, _maxScale);
      }
      
      // Desplazamiento (pan)
      if (_currentScale > _minScale) {
        _offset = _previousOffset + details.focalPointDelta;
        
        // Limitar el desplazamiento para que no se salga mucho
        final maxOffset = 500.0;
        _offset = Offset(
          _offset.dx.clamp(-maxOffset, maxOffset),
          _offset.dy.clamp(-maxOffset, maxOffset),
        );
      } else {
        _offset = Offset.zero; // No permitir desplazamiento en zoom mínimo
      }
    });
  }

  void _resetToCenter() {
    setState(() {
      _currentScale = _minScale;
      _offset = Offset.zero;
      _previousScale = _minScale;
      _previousOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, 
                color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_currentScale > _minScale + 0.1)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.center_focus_strong, 
                    color: Colors.white, size: 20),
              ),
              onPressed: _resetToCenter,
              tooltip: 'Centrar imagen',
            ),
        ],
      ),
      body: _isImageLoaded
          ? GestureDetector(
              onDoubleTap: _handleDoubleTap,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              child: Stack(
                children: [
                  // Fondo negro
                  Container(color: Colors.black),
                  
                  // Imagen transformada
                  Center(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translate(_offset.dx, _offset.dy)
                        ..scale(_currentScale),
                      alignment: Alignment.center,
                      child: Hero(
                        tag: widget.heroTag,
                        child: Image.memory(
                          widget.imageBytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // Indicador de zoom
                  if (_currentScale > _minScale + 0.1)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: AnimatedOpacity(
                        opacity: _currentScale > _minScale + 0.1 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),

                  // Instrucciones (solo en zoom mínimo)
                  if (_currentScale <= _minScale + 0.1)
                    const Positioned(
                      bottom: 60,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            'Doble tap para zoom',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.white70,
                strokeWidth: 2,
              ),
            ),
    );
  }
}

// Función para abrir la imagen
void showFullScreenImageCentrado(BuildContext context, {
  required Uint8List imageBytes, 
  required String heroTag,
}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: ImageViewerCentrado(
            imageBytes: imageBytes,
            heroTag: heroTag,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
    ),
  );
}