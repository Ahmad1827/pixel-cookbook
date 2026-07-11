import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/pixel_button.dart';
import '../../widgets/guild_auth_dialog.dart';
import '../../services/audio_service.dart';
import '../tavern/tavern_screen.dart';
import 'about_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E3C5A), Color(0xFF0F1E2D)], 
              ),
            ),
          ),
          ...List.generate(20, (index) => Positioned(
            left: (index * 45.0) % MediaQuery.of(context).size.width,
            top: (index * 30.0) % (MediaQuery.of(context).size.height / 2),
            child: Container(width: 2, height: 2, color: Colors.white)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(duration: (800 + index * 100).ms),
          )),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                 .moveY(begin: -8, end: 8, duration: 2.5.seconds) 
                 .shimmer(delay: 4.seconds, duration: 1.seconds, color: Colors.white54),
                const SizedBox(height: 12),
                Text(
                  'Where every recipe tells a story.',
                  style: GoogleFonts.vt323(fontSize: 24, color: const Color(0xFFE2D6B5)),
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 64),
                PixelButton(
                  text: user != null ? 'CONTINUE JOURNEY' : 'ENTER THE TAVERN',
                  color: const Color(0xFF8B5A2B),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TavernScreen()),
                    );
                  },
                ).animate().slideY(begin: 1, end: 0, delay: 400.ms).fadeIn(),
                const SizedBox(height: 16),
                if (user == null)
                  PixelButton(
                    text: 'JOIN THE GUILD',
                    color: const Color(0xFF2E8B57), 
                    onPressed: () {
                      showGuildAuthDialog(context);
                    },
                  ).animate().slideY(begin: 1, end: 0, delay: 600.ms).fadeIn(),
              ],
            ),
          ),
          
          // --- THE MUTE SOUND BUTTON ---
          Positioned(
            top: 48,
            right: 24,
            child: Consumer<AudioService>(
              builder: (context, audio, child) {
                return GestureDetector(
                  onTap: audio.toggleMute,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A0F08),
                      border: Border.all(color: const Color(0xFF5C3A21), width: 3),
                    ),
                    child: Icon(
                      audio.isMuted ? Icons.volume_off : Icons.volume_up,
                      color: const Color(0xFFF4EAD4), 
                      size: 28,
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms);
              },
            ),
          ),

          // --- THE ABOUT / INFO BUTTON ---
          Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B1D14),
                  border: Border.all(color: const Color(0xFF5C3A21), width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(3, 3))],
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFFF4EAD4), size: 28),
              ),
            ).animate().fadeIn(delay: 1.seconds),
          ),
        ],
      ),
    );
  }
}