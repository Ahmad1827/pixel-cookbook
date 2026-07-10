import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'pixel_panel.dart';
import 'pixel_button.dart';
import 'pixel_text_field.dart';

void showGuildAuthDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Guild Master",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: GuildAuthPanel(),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: Curves.easeOutBack.transform(anim1.value),
        child: FadeTransition(opacity: anim1, child: child),
      );
    },
  );
}

class GuildAuthPanel extends StatefulWidget {
  @override
  _GuildAuthPanelState createState() => _GuildAuthPanelState();
}

class _GuildAuthPanelState extends State<GuildAuthPanel> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      child: PixelPanel(
        baseColor: const Color(0xFFE2D6B5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // NPC Dialogue Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5A2B),
                    border: Border.all(color: const Color(0xFF1A0F08), width: 3),
                  ),
                  child: const Icon(Icons.person, color: Colors.white), // Replace with pixel Guild Master sprite
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _isRegistering 
                        ? '"Ah, a new face! Sign the ledger to join the Chef\'s Guild."'
                        : '"Welcome back to the Tavern, Chef. Show me your credentials."',
                    style: GoogleFonts.vt323(fontSize: 22, color: const Color(0xFF1A0F08), fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: Color(0xFF5C3A21), thickness: 3),
            ),
            PixelTextField(controller: _emailController, label: 'Scroll Address (Email)'),
            const SizedBox(height: 12),
            PixelTextField(controller: _passwordController, label: 'Secret Passcode', obscureText: true),
            const SizedBox(height: 24),
            PixelButton(
              text: _isRegistering ? 'SIGN THE LEDGER' : 'PRESENT CREDENTIALS',
              color: const Color(0xFF2E8B57),
              onPressed: () async {
                if (_isRegistering) {
                  await authService.registerWithEmailAndPassword(_emailController.text, _passwordController.text);
                } else {
                  await authService.signInWithEmailAndPassword(_emailController.text, _passwordController.text);
                }
                if (mounted) Navigator.pop(context); // Close dialog on success
              },
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _isRegistering = !_isRegistering),
              child: Text(
                _isRegistering ? 'I already have a Guild Badge' : 'I need to join the Guild',
                style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFF5C3A21), decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}