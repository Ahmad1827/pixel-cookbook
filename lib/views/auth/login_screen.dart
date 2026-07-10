import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../widgets/pixel_panel.dart';
import '../../widgets/pixel_button.dart';
import '../../widgets/pixel_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // In a real app, replace this with an animated looping pixel-art GIF
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2B2B45), Color(0xFF1A0F08)], // Night sky to dark ground
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Logo
                Text(
                  'PIXEL\nCOOKBOOK',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pixelifySans(
                    fontSize: 54,
                    color: const Color(0xFFFFD700),
                    height: 1.1,
                    shadows: const [
                      Shadow(color: Color(0xFF1A0F08), offset: Offset(4, 4)),
                    ],
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .moveY(begin: -5, end: 5, duration: 2.seconds) // Floating idle animation
                 .shimmer(delay: 3.seconds, duration: 1.seconds),

                const SizedBox(height: 40),

                // Notice Board (Login Form)
                PixelPanel(
                  baseColor: const Color(0xFFE2D6B5), // Weathered paper
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PixelTextField(
                          controller: _emailController,
                          label: 'Chef\'s Email',
                        ),
                        const SizedBox(height: 16),
                        PixelTextField(
                          controller: _passwordController,
                          label: 'Secret Passcode',
                          obscureText: true,
                        ),
                        const SizedBox(height: 32),
                        PixelButton(
                          text: 'Continue Journey',
                          color: const Color(0xFF8B5A2B), // Leather brown
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await authService.signInWithEmailAndPassword(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: Text(
                            'Start New Adventure',
                            style: GoogleFonts.vt323(
                              fontSize: 22,
                              color: const Color(0xFF5C3A21),
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
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