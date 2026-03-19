import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();

  bool _loading = false;
  String? _message;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// 🔐 Firebase password reset via email
  Future<void> _resetPassword() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _message = "Please enter your email address.";
        _loading = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        _message =
            "Password reset link sent! Check your email and follow the instructions.";
      });
    } on FirebaseAuthException catch (e) {
      String msg = "An error occurred.";
      if (e.code == 'user-not-found') msg = "No account found for this email.";
      setState(() => _message = msg);
    } catch (e) {
      setState(() => _message = "Unexpected error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 4,
        centerTitle: true,
        title: Text(
          "RESET PASSWORD",
          style: GoogleFonts.orbitron(
            color: Colors.tealAccent,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.tealAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF001F2E), Color(0xFF003D40)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Recover Your Account",
                      style: GoogleFonts.orbitron(
                        color: Colors.tealAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInput(
                      label: "Email Address",
                      controller: _emailController,
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),
                    if (_message != null)
                      Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          color: _message!.contains("sent")
                              ? Colors.tealAccent
                              : Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 20),
                    _loading
                        ? const CircularProgressIndicator(
                            color: Colors.tealAccent,
                          )
                        : ElevatedButton(
                            onPressed: _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              shadowColor: Colors.tealAccent,
                              elevation: 8,
                            ),
                            child: Text(
                              "SEND RESET LINK",
                              style: GoogleFonts.orbitron(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.tealAccent),
        labelText: label,
        labelStyle: GoogleFonts.orbitron(
          color: Colors.tealAccent,
          fontSize: 13,
          letterSpacing: 1.1,
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
}
