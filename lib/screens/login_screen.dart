import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cyberops/screens/dashboard_screen.dart';
import 'package:cyberops/screens/login_components/login_header.dart';
import 'package:cyberops/screens/login_components/login_fields.dart';
import 'package:cyberops/screens/login_components/login_buttons.dart';
import 'package:cyberops/screens/forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _loading = false;
  bool _isLoginMode = true;
  String? _errorText;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
        // 🔹 LOGIN
        String? emailToUse = email;

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

        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: emailToUse!, password: password);

        final user = credential.user!;

        if (!user.emailVerified) {
          setState(() {
            _errorText = "Please verify your email before logging in.";
          });
          await user.sendEmailVerification();
          await FirebaseAuth.instance.signOut();
          _loading = false;
          return;
        }

        // ✅ Ensure Firestore doc exists for this Auth user
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
          debugPrint("🆕 Created Firestore user for ${user.uid}");
        } else {
          debugPrint("✅ Existing Firestore user found for ${user.uid}");
        }

        if (!mounted) return;

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
        // 🔹 REGISTER
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final uid = credential.user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': username,
          'email': email,
          'role': 'user', // default
          'created_at': FieldValue.serverTimestamp(),
        });

        await credential.user!.sendEmailVerification();

        setState(() {
          _isLoginMode = true;
          _errorText =
              "Account created! Please verify your email before logging in.";
        });
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Authentication error.";
      if (e.code == 'user-not-found') msg = "No account found.";
      if (e.code == 'wrong-password') msg = "Incorrect password.";
      if (e.code == 'email-already-in-use') msg = "Email already registered.";
      setState(() => _errorText = msg);
    } catch (e) {
      setState(() => _errorText = "Unexpected error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.15),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
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
                      confirmPasswordController: _confirmPasswordController,
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
