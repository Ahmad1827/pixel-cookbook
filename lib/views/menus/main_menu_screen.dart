import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/pixel_button.dart';
import '../tavern/tavern_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Parallax Background Layer (Replace with real pixel art later)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E3C5A), Color(0xFF0F1E2D)], // Night sky
              ),
            ),
          ),
          
          // 2. Twinkling Stars (Micro-interactions)
          ...List.generate(20, (index) => Positioned(
            left: (index * 45.0) % MediaQuery.of(context).size.width,
            top: (index * 30.0) % (MediaQuery.of(context).size.height / 2),
            child: Container(width: 2, height: 2, color: Colors.white)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(duration: (800 + index * 100).ms),
          )),

          // 3. Foreground Elements
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Title
                Text(
                  'PIXEL\nCOOKBOOK',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pixelifySans(
                    fontSize: 64,
                    color: const Color(0xFFFFD700),
                    height: 1.0,
                    shadows: const [Shadow(color: Color(0xFF1A0F08), offset: Offset(4, 4))],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                 .moveY(begin: -8, end: 8, duration: 2.5.seconds) // Idle float
                 .shimmer(delay: 4.seconds, duration: 1.seconds, color: Colors.white54),
                
                const SizedBox(height: 12),
                Text(
                  'Where every recipe tells a story.',
                  style: GoogleFonts.vt323(fontSize: 24, color: const Color(0xFFE2D6B5)),
                ).animate().fadeIn(delay: 800.ms),
                
                const SizedBox(height: 64),

                // Main Navigation Options
                PixelButton(
                  text: user != null ? 'CONTINUE JOURNEY' : 'ENTER THE TAVERN',
                  color: const Color(0xFF8B5A2B),
                  onPressed: () {
                    // Navigate directly to the Tavern. No login required.
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const TavernScreen()),
                    );
                  },
                ).animate().slideY(begin: 1, end: 0, delay: 400.ms).fadeIn(),

                const SizedBox(height: 16),
                
                if (user == null)
                  PixelButton(
                    text: 'JOIN THE GUILD',
                    color: const Color(0xFF2E8B57), // Pelican green
                    onPressed: () {
                      // We will open the Guild Auth Dialog here later
                    },
                  ).animate().slideY(begin: 1, end: 0, delay: 600.ms).fadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}