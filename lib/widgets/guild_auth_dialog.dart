import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../views/auth/forgot_password_screen.dart';
import 'pixel_button.dart';

void showGuildAuthDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const GuildAuthDialog(),
  );
}

class GuildAuthDialog extends StatefulWidget {
  const GuildAuthDialog({super.key});

  @override
  State<GuildAuthDialog> createState() => _GuildAuthDialogState();
}

class _GuildAuthDialogState extends State<GuildAuthDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;

  Future<void> submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      if (isLogin) {
        await authService.signInWithEmailAndPassword(email, password);
      } else {
        await authService.registerWithEmailAndPassword(email, password);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2B1D14),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF5C3A21), width: 4),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLogin ? 'ENTER GUILD' : 'JOIN GUILD',
              style: GoogleFonts.pixelifySans(fontSize: 32, color: const Color(0xFFDAA520)),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              style: GoogleFonts.vt323(fontSize: 24, color: const Color(0xFFF4EAD4)),
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFF8B5A2B)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF5C3A21))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFDAA520))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: GoogleFonts.vt323(fontSize: 24, color: const Color(0xFFF4EAD4)),
              decoration: const InputDecoration(
                labelText: 'Passcode',
                labelStyle: TextStyle(color: Color(0xFF8B5A2B)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF5C3A21))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFDAA520))),
              ),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator(color: Color(0xFFDAA520))
                : PixelButton(
                    text: isLogin ? 'LOGIN' : 'REGISTER',
                    color: const Color(0xFF2E8B57),
                    onPressed: submit,
                  ),
            const SizedBox(height: 16),
            
            // AICI ESTE BUTONUL DE FORGOT PASSWORD
            if (isLogin)
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Închidem pop-up-ul
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                  );
                },
                child: Text(
                  'FORGOT PASSCODE?',
                  style: GoogleFonts.pixelifySans(fontSize: 18, color: const Color(0xFFCD5C5C), decoration: TextDecoration.underline),
                ),
              ),
              
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(
                isLogin ? 'Need an account? Register' : 'Already in guild? Login',
                style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFFE2D6B5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}