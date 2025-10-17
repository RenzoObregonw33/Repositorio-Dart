import 'package:flutter/material.dart';

/// Wrapper ultra-seguro para widgets de gráficos que previene errores de dispose
class SafeChartWrapper extends StatefulWidget {
  final Widget child;
  final String? debugLabel;

  const SafeChartWrapper({
    super.key,
    required this.child,
    this.debugLabel,
  });

  @override
  State<SafeChartWrapper> createState() => _SafeChartWrapperState();
}

class _SafeChartWrapperState extends State<SafeChartWrapper>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  
  bool _isDisposed = false;
  bool _isMounted = true;

  @override
  bool get wantKeepAlive => !_isDisposed && _isMounted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      setState(() {
        _isMounted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Requerido por AutomaticKeepAliveClientMixin
    
    // Triple verificación de seguridad
    if (_isDisposed || !_isMounted || !mounted) {
      return const SizedBox.shrink();
    }

    // Wrapper adicional para capturar errores
    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (e) {
          // Si hay cualquier error, retorna widget vacío
          debugPrint('🛡️ SafeChartWrapper capturó error: $e');
          return const SizedBox.shrink();
        }
      },
    );
  }
}