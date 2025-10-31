import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io'; // ← Para detectar plataforma

class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;

  const AdaptiveButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      // 🍎 Botón estilo iOS nativo
      return Container(
        width: double.infinity,
        child: CupertinoButton.filled(
          onPressed: isLoading ? null : onPressed,
          color: backgroundColor ?? Color(0xFF7775E2),
          borderRadius: BorderRadius.circular(12), // Esquinas redondeadas iOS
          child: isLoading
              ? CupertinoActivityIndicator(color: Colors.white)
              : Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.w600, // Peso de fuente iOS
                    fontSize: 17, // Tamaño estándar iOS
                  ),
                ),
        ),
      );
    } else {
      // 🤖 Tu botón actual Android (Material Design)
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Color(0xFF7775E2),
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      );
    }
  }
}
