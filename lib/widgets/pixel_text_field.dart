import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int maxLines;

  const PixelTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.pixelifySans(
            color: const Color(0xFF5C3A21),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          maxLines: maxLines,
          style: GoogleFonts.vt323(fontSize: 22, color: const Color(0xFF1A0F08)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFFFDF6),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF5C3A21), width: 4),
              borderRadius: BorderRadius.zero,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF2E8B57), width: 4),
              borderRadius: BorderRadius.zero,
            ),
            errorStyle: GoogleFonts.vt323(color: const Color(0xFFCD5C5C), fontSize: 16),
          ),
        ),
      ],
    );
  }
}