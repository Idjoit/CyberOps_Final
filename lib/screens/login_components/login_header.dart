import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginHeader extends StatelessWidget {
  final bool isLoginMode;

  const LoginHeader({super.key, required this.isLoginMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "CYBEROPS",
          style: GoogleFonts.orbitron(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.tealAccent,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isLoginMode ? "ACCESS TERMINAL" : "REGISTER NEW AGENT",
          style: GoogleFonts.orbitron(
            color: Colors.white70,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
