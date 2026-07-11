import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/pixel_panel.dart';
import '../../widgets/pixel_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B1D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0F08),
        title: Text(
          'DEVELOPER STATS',
          style: GoogleFonts.pixelifySans(color: const Color(0xFFFFD700), fontSize: 24),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF4EAD4)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: PixelPanel(
            baseColor: const Color(0xFF3A2311),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0F08),
                    border: Border.all(color: const Color(0xFF5C3A21), width: 4),
                  ),
                  child: const Center(
                    child: Icon(Icons.terminal, color: Color(0xFF2E8B57), size: 50),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'AHMAD ARNAOUTE',
                  style: GoogleFonts.pixelifySans(fontSize: 32, color: const Color(0xFFFFD700), fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '< AtodDev />',
                  style: GoogleFonts.vt323(fontSize: 24, color: const Color(0xFFF4EAD4)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Divider(color: Color(0xFF5C3A21), thickness: 4),
                ),
                Text(
                  'Lvl 10 Code-Smith',
                  style: GoogleFonts.pixelifySans(fontSize: 22, color: const Color(0xFFCD5C5C), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Currently studying the arcane systems of Computer Science at UPB in the Bucharest realm.\n\nKnown across the land for full-stack crafting and forging the most intricate and efficient code spells.',
                  style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFFE2D6B5), height: 1.2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildSocialButton('GITHUB', 'https://github.com/Ahmad1827', const Color(0xFF1A0F08)),
                const SizedBox(height: 12),
                _buildSocialButton('LINKEDIN', 'https://www.linkedin.com/in/ahmad-arnaoute-974465283/', const Color(0xFF2E8B57)),
                const SizedBox(height: 12),
                _buildSocialButton('INSTAGRAM', 'https://www.instagram.com/atod.arts/', const Color(0xFF8B5A2B)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String text, String url, Color color) {
    return SizedBox(
      width: double.infinity,
      child: PixelButton(
        text: text,
        color: color,
        onPressed: () => _launchURL(url),
      ),
    );
  }
}