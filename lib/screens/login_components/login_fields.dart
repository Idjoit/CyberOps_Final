import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginFields extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoginMode;

  const LoginFields({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoginMode,
  });

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleVisibility,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: inputType,
      style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.tealAccent),
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.tealAccent,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        labelText: label,
        labelStyle: GoogleFonts.orbitron(
          color: Colors.tealAccent,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.tealAccent.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.tealAccent, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🟢 LOGIN MODE → Username or Email
        if (widget.isLoginMode)
          _buildInputField(
            controller: widget.usernameController,
            label: "USERNAME OR EMAIL",
            icon: Icons.person_outline,
            inputType: TextInputType.text,
          ),

        // 🟣 REGISTER MODE → Username + Email
        if (!widget.isLoginMode) ...[
          _buildInputField(
            controller: widget.usernameController,
            label: "USERNAME",
            icon: Icons.person_outline,
            inputType: TextInputType.text,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: widget.emailController,
            label: "EMAIL ADDRESS",
            icon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
          ),
        ],

        const SizedBox(height: 16),

        // 🔒 PASSWORD
        _buildInputField(
          controller: widget.passwordController,
          label: "PASSWORD",
          icon: Icons.lock_outline,
          obscure: _obscurePassword,
          toggleVisibility: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),

        // 🔐 CONFIRM PASSWORD (register only)
        if (!widget.isLoginMode) ...[
          const SizedBox(height: 16),
          _buildInputField(
            controller: widget.confirmPasswordController,
            label: "CONFIRM PASSWORD",
            icon: Icons.lock_reset,
            obscure: _obscureConfirm,
            toggleVisibility: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ],
      ],
    );
  }
}
