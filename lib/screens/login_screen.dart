import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cyberops/screens/dashboard_screen.dart';
import 'package:cyberops/screens/login_components/login_header.dart';
import 'package:cyberops/screens/login_components/login_fields.dart';
import 'package:cyberops/screens/login_components/login_buttons.dart';
import 'package:cyberops/screens/forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// LoginScreen
/// ------------------------------------------------------------
/// Handles both user login and registration using Firebase Auth
/// and stores user data in Firestore.
///
/// Features:
/// - Login & Register toggle mode
/// - Email + username login support
/// - Firebase Authentication integration
/// - Firestore user profile creation
/// - Email verification enforcement
/// - Guest mode login
/// - Forgot password navigation
/// - Input validation (email + strong password rules)
/// - Animated UI (fade-in effect)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  /// Input controllers for form fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  /// Loading state for async auth operations
  bool _loading = false;

  /// Toggle between login and register mode
  bool _isLoginMode = true;

  /// Error or status message display
  String? _errorText;

  /// Animation controller for fade-in effect
  late AnimationController _controller;

  /// Fade animation
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);

    // Start animation on load
    _controller.forward();
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _controller.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// ------------------------------------------------------------
  /// Validates login/register inputs
  ///
  /// Rules:
  /// - Required fields must not be empty
  /// - Email must be valid format
  /// - Password must be strong (uppercase, lowercase, number, symbol)
  /// - Password confirmation must match (register only)
  String? _validateInputs({
    required bool isRegister,
    required String username,
    required String email,
    required String password,
    String? confirmPassword,
  }) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    final strongPassword = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );

    if (isRegister) {
      if (username.isEmpty || email.isEmpty || password.isEmpty) {
        return "Please fill in all required fields.";
      }
      if (!emailRegex.hasMatch(email)) {
        return "Please enter a valid email address.";
      }
      if (!strongPassword.hasMatch(password)) {
        return "Password must include upper, lower, number, and symbol.";
      }
      if (password != confirmPassword) {
        return "Passwords do not match.";
      }
    } else {
      if (username.isEmpty || password.isEmpty) {
        return "Please enter username/email and password.";
      }
    }

    return null;
  }

  /// ------------------------------------------------------------
  /// Handles login and registration logic
  ///
  /// LOGIN FLOW:
  /// - Accept username or email
  /// - If username, fetch email from Firestore
  /// - Authenticate using FirebaseAuth
  /// - Check email verification
  /// - Ensure Firestore user document exists
  ///
  /// REGISTER FLOW:
  /// - Create FirebaseAuth user
  /// - Save user profile in Firestore
  /// - Send email verification
  /// - Switch back to login mode
  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    final validationError = _validateInputs(
      isRegister: !_isLoginMode,
      username: username,
      email: email,
      password: password,
      confirmPassword: confirm,
    );

    if (validationError != null) {
      setState(() {
        _errorText = validationError;
        _loading = false;
      });
      return;
    }

    try {
      if (_isLoginMode) {
        // ==============================
        // 🔹 LOGIN PROCESS
        // ==============================

        String? emailToUse = email;

        // If username is used instead of email, fetch from Firestore
        if (!username.contains("@")) {
          final userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

          if (userQuery.docs.isEmpty) {
            setState(() {
              _errorText = "No user found with username '$username'.";
              _loading = false;
            });
            return;
          }

          emailToUse = userQuery.docs.first['email'];
        } else {
          emailToUse = username;
        }

        // Firebase login
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: emailToUse!,
              password: password,
            );

        final user = credential.user!;

        // Email verification check
        if (!user.emailVerified) {
          setState(() {
            _errorText = "Please verify your email before logging in.";
          });
          await user.sendEmailVerification();
          await FirebaseAuth.instance.signOut();
          _loading = false;
          return;
        }

        // Ensure Firestore user profile exists
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        final snapshot = await userRef.get();

        if (!snapshot.exists) {
          await userRef.set({
            'username': username.isNotEmpty
                ? username
                : user.displayName ?? 'Agent_${user.uid.substring(0, 5)}',
            'email': user.email,
            'role': 'user',
            'created_at': FieldValue.serverTimestamp(),
          });
        }

        if (!mounted) return;

        // Navigate to dashboard after login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              userId: user.uid,
              isGuest: false,
            ),
          ),
        );
      } else {
        // ==============================
        // 🔹 REGISTER PROCESS
        // ==============================

        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

        final uid = credential.user!.uid;

        // Create Firestore user profile
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': username,
          'email': email,
          'role': 'user',
          'created_at': FieldValue.serverTimestamp(),
        });

        // Send verification email
        await credential.user!.sendEmailVerification();

        setState(() {
          _isLoginMode = true;
          _errorText =
              "Account created! Please verify your email before logging in.";
        });
      }
    } on FirebaseAuthException catch (e) {
      // Firebase auth error handling
      String msg = "Authentication error.";
      if (e.code == 'user-not-found') msg = "No account found.";
      if (e.code == 'wrong-password') msg = "Incorrect password.";
      if (e.code == 'email-already-in-use') {
        msg = "Email already registered.";
      }
      setState(() => _errorText = msg);
    } catch (e) {
      // Unexpected error fallback
      setState(() => _errorText = "Unexpected error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Guest login (bypasses authentication)
  Future<void> _continueAsGuest() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardScreen(
          userId: "guest",
          isGuest: true,
        ),
      ),
    );
  }

  /// Opens forgot password screen
  void _openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,

      // Fade-in animation wrapper
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

          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),

              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.tealAccent.withOpacity(0.3),
                  ),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoginHeader(isLoginMode: _isLoginMode),
                    const SizedBox(height: 30),

                    LoginFields(
                      usernameController: _usernameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController:
                          _confirmPasswordController,
                      isLoginMode: _isLoginMode,
                    ),

                    const SizedBox(height: 10),

                    if (_isLoginMode)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _openForgotPassword,
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.orbitron(
                              color: Colors.tealAccent,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    LoginButtons(
                      isLoginMode: _isLoginMode,
                      loading: _loading,
                      errorText: _errorText,
                      onSubmit: _submit,
                      onToggleMode: () {
                        setState(() {
                          _isLoginMode = !_isLoginMode;
                          _errorText = null;
                        });
                      },
                      onGuest: _continueAsGuest,
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
}
