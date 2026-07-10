import 'package:flutter/material.dart';

class PixelPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color baseColor;

  const PixelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.baseColor = const Color(0xFFF4EAD4), // Parchment default
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        border: Border.all(color: const Color(0xFF1A0F08), width: 4), // Sharp dark pixel border
        boxShadow: const [
          BoxShadow(
            color: Color(0x60000000), // Hard unblurred shadow
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
          BoxShadow( // Inner highlight
            color: Colors.white54,
            offset: Offset(-2, -2),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}