import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/pixel_panel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email de resetare trimis! Verifică inbox-ul.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EAD4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0F08),
        title: Text('RESET PASSWORD', style: GoogleFonts.pixelifySans(color: const Color(0xFFF4EAD4))),
        iconTheme: const IconThemeData(color: Color(0xFFF4EAD4)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PixelPanel(
            baseColor: const Color(0xFFFFFFFF),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ai uitat parola magică?',
                  style: GoogleFonts.pixelifySans(fontSize: 24, color: const Color(0xFF1A0F08)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Introdu adresa de email și îți vom trimite un corb cu instrucțiunile de resetare.',
                  style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFF5C3A21)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  style: GoogleFonts.vt323(fontSize: 24),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF8B5A2B))
                    : ElevatedButton(
                        onPressed: resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A0F08),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        ),
                        child: Text(
                          'TRIMITE CORBUL',
                          style: GoogleFonts.pixelifySans(fontSize: 20, color: const Color(0xFFDAA520)),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}