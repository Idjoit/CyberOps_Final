import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginButtons extends StatelessWidget {
  final bool isLoginMode;
  final bool loading;
  final String? errorText;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;
  final VoidCallback onGuest;

  const LoginButtons({
    super.key,
    required this.isLoginMode,
    required this.loading,
    required this.errorText,
    required this.onSubmit,
    required this.onToggleMode,
    required this.onGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (errorText != null)
          Text(
            errorText!,
            style: GoogleFonts.orbitron(
              color: Colors.redAccent,
              fontSize: 12,
            ),
          ),
        const SizedBox(height: 16),
        loading
            ? const CircularProgressIndicator(color: Colors.tealAccent)
            : _buildNeonButton(isLoginMode ? "LOGIN" : "REGISTER", onSubmit),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onToggleMode,
          child: Text(
            isLoginMode ? "Create New Account" : "Back to Login",
            style: GoogleFonts.orbitron(
              color: Colors.tealAccent,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onGuest,
          child: Text(
            "Continue as Guest",
            style: GoogleFonts.orbitron(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeonButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.tealAccent,
        elevation: 10,
      ),
      child: Text(
        text,
        style: GoogleFonts.orbitron(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
