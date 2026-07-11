import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class CookingSequenceScreen extends StatefulWidget {
  final Future<void> Function() saveFuture;

  const CookingSequenceScreen({super.key, required this.saveFuture});

  @override
  State<CookingSequenceScreen> createState() => _CookingSequenceScreenState();
}

class _CookingSequenceScreenState extends State<CookingSequenceScreen> {
  bool _isCooked = false;

  @override
  void initState() {
    super.initState();
    _executeCooking();
  }

  Future<void> _executeCooking() async {
    await widget.saveFuture();
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isCooked = true);
      
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F08), 
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _isCooked 
                ? _buildSuccessAchievement() 
                : _buildCookingAnimation(),
          ),
        ),
      ),
    );
  }

  Widget _buildCookingAnimation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.soup_kitchen, size: 100, color: Color(0xFF8B5A2B))
            .animate(onPlay: (c) => c.repeat())
            .shake(hz: 4, curve: Curves.easeInOut)
            .tint(color: const Color(0xFFCD5C5C), duration: 1.seconds),
        const SizedBox(height: 24),
        Text(
          'Simmering ingredients...',
          textAlign: TextAlign.center,
          style: GoogleFonts.vt323(fontSize: 28, color: const Color(0xFFF4EAD4)),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(),
      ],
    );
  }

  Widget _buildSuccessAchievement() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.star, size: 120, color: Color(0xFFFFD700))
            .animate()
            .scale(begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut, duration: 800.ms)
            .rotate(begin: -0.2, end: 0)
            .shimmer(delay: 400.ms, duration: 1.seconds),
        const SizedBox(height: 24),
        Text(
          'NEW RECIPE\nDISCOVERED!',
          textAlign: TextAlign.center,
          style: GoogleFonts.pixelifySans(fontSize: 36, color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, height: 1.2),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
        const SizedBox(height: 16),
        Text(
          '+50 Cooking XP',
          textAlign: TextAlign.center,
          style: GoogleFonts.vt323(fontSize: 28, color: const Color(0xFF2E8B57)),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Level 2: Apprentice Chef',
              textAlign: TextAlign.center,
              style: GoogleFonts.vt323(fontSize: 24, color: const Color(0xFFF4EAD4)),
            ),
            const SizedBox(height: 8),
            Container(
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF2B1D14),
                border: Border.all(color: const Color(0xFF5C3A21), width: 3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.75, 
                child: Container(color: const Color(0xFF2E8B57)),
              ).animate().scaleX(begin: 0, end: 1, alignment: Alignment.centerLeft, duration: 1.seconds, delay: 800.ms),
            ),
            const SizedBox(height: 4),
            Text(
              '150 / 200 XP',
              textAlign: TextAlign.right,
              style: GoogleFonts.vt323(fontSize: 18, color: const Color(0xFF8B5A2B)),
            ),
          ],
        ).animate().fadeIn(delay: 800.ms),
      ],
    );
  }
}