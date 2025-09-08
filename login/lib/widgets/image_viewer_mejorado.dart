import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageViewerMejorado extends StatelessWidget {
  final Uint8List imageBytes;
  final String heroTag;

  const ImageViewerMejorado({
    super.key,
    required this.imageBytes,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final TransformationController _transformationController =
        TransformationController();
    double _currentScale = 1.0;
    bool _isZoomed = false;

    void _toggleZoom() {
      final newScale = _isZoomed ? 1.0 : 2.0;
      _isZoomed = !_isZoomed;

      _transformationController.value = Matrix4.identity()
        ..scale(newScale, newScale);
      _currentScale = newScale;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              onDoubleTap: _toggleZoom,
              onLongPress: () {
                _transformationController.value = Matrix4.identity();
                _currentScale = 1.0;
                _isZoomed = false;
              },
              child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  boundaryMargin: const EdgeInsets.all(20),
                  onInteractionUpdate: (details) {
                    _currentScale =
                        _transformationController.value.getMaxScaleOnAxis();
                    _isZoomed = _currentScale > 1.5;

                    if (_currentScale < 0.5) {
                      _transformationController.value = Matrix4.identity();
                      _currentScale = 1.0;
                      _isZoomed = false;
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

          Positioned(
            bottom: 20,
            right: 20,
            child: AnimatedOpacity(
              opacity: _isZoomed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Zoom ${_currentScale.toStringAsFixed(1)}x',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Función para abrir la imagen con zoom mejorado
void showFullScreenImageMejorado(BuildContext context, {
  required Uint8List imageBytes, 
  required String heroTag
}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
        opacity: animation,
        child: ImageViewerMejorado(
          imageBytes: imageBytes,
          heroTag: heroTag,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}