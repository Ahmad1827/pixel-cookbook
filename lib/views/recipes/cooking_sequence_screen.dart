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
    // 1. Wait for Firebase to actually save
    await widget.saveFuture();
    
    // 2. Artificial delay to let the "bubbling pot" animation play out
    await Future.delayed(const Duration(seconds: 2));
    
    // 3. Trigger the success state
    if (mounted) {
      setState(() => _isCooked = true);
      
      // 4. Wait for the success animation to finish, then pop back to Tavern
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F08), // Pitch black room focus
      body: Center(
        child: _isCooked 
            ? _buildSuccessAchievement() 
            : _buildCookingAnimation(),
      ),
    );
  }

  Widget _buildCookingAnimation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bubbling Pot Icon (Simulated with animation)
        const Icon(Icons.soup_kitchen, size: 100, color: Color(0xFF8B5A2B))
            .animate(onPlay: (c) => c.repeat())
            .shake(hz: 4, curve: Curves.easeInOut)
            .tint(color: const Color(0xFFCD5C5C), duration: 1.seconds),
        const SizedBox(height: 24),
        Text(
          'Simmering ingredients...',
          style: GoogleFonts.vt323(fontSize: 28, color: const Color(0xFFF4EAD4)),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(),
      ],
    );
  }

  Widget _buildSuccessAchievement() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star, size: 120, color: Color(0xFFFFD700))
            .animate()
            .scale(begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut, duration: 800.ms)
            .rotate(begin: -0.2, end: 0)
            .shimmer(delay: 400.ms, duration: 1.seconds),
        const SizedBox(height: 24),
        Text(
          'NEW RECIPE DISCOVERED!',
          style: GoogleFonts.pixelifySans(fontSize: 36, color: const Color(0xFFFFD700), fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
        const SizedBox(height: 8),
        Text(
          '+50 Cooking XP',
          style: GoogleFonts.vt323(fontSize: 24, color: const Color(0xFF2E8B57)),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0),
      ],
    );
  }
}