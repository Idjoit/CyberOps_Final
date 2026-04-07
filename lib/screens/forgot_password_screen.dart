import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ForgotPasswordScreen
/// ------------------------------------------------------------
/// This screen allows users to reset their password via Firebase Authentication.
/// The user enters their email, and a password reset link is sent.
///
/// Features:
/// - Firebase password reset integration
/// - Animated fade-in UI
/// - Form validation (basic email check)
/// - Loading indicator during request
/// - Error/success message display
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {

  /// Controller for email input field
  final TextEditingController _emailController = TextEditingController();

  /// Loading state for async Firebase request
  bool _loading = false;

  /// Message shown to user (success or error)
  String? _message;

  /// Animation controller for fade-in effect
  late AnimationController _controller;

  /// Fade animation used for screen transition
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Smooth fade-in curve
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);

    // Start animation on screen load
    _controller.forward();
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// ------------------------------------------------------------
  /// Sends a password reset email using Firebase Authentication
  ///
  /// Flow:
  /// 1. Validate email input
  /// 2. Call Firebase sendPasswordResetEmail
  /// 3. Show success or error message
  /// 4. Handle loading state
  Future<void> _resetPassword() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    final email = _emailController.text.trim();

    // Basic validation
    if (email.isEmpty) {
      setState(() {
        _message = "Please enter your email address.";
        _loading = false;
      });
      return;
    }

    try {
      // Firebase password reset request
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        _message =
            "Password reset link sent! Check your email and follow the instructions.";
      });
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      String msg = "An error occurred.";

      if (e.code == 'user-not-found') {
        msg = "No account found for this email.";
      }

      setState(() => _message = msg);
    } catch (e) {
      // Handle unexpected errors
      setState(() => _message = "Unexpected error: $e");
    } finally {
      // Always stop loading
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark background theme for cybersecurity-style UI
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 4,
        centerTitle: true,

        // Screen title styled with Orbitron font
        title: Text(
          "RESET PASSWORD",
          style: GoogleFonts.orbitron(
            color: Colors.tealAccent,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),

        // Back navigation button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.tealAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // Fade-in animation wrapper for screen content
      body: FadeTransition(
        opacity: _fadeAnim,

        child: Container(
          // Cyber-themed gradient background
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
                // Glassmorphism-style card
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.tealAccent.withOpacity(0.3),
                  ),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Screen heading
                    Text(
                      "Recover Your Account",
                      style: GoogleFonts.orbitron(
                        color: Colors.tealAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Email input field
                    _buildInput(
                      label: "Email Address",
                      controller: _emailController,
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 20),

                    // Feedback message (success or error)
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

                    // Loading indicator or submit button
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
                                horizontal: 50,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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

  /// Reusable input field builder
  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,

      // Input text style
      style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14),

      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.tealAccent),

        labelText: label,
        labelStyle: GoogleFonts.orbitron(
          color: Colors.tealAccent,
          fontSize: 13,
          letterSpacing: 1.1,
        ),

        // Default border
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.tealAccent.withOpacity(0.4),
          ),
          borderRadius: BorderRadius.circular(10),
        ),

        // Focused border
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.tealAccent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),

        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}
