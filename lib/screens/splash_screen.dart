import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  String _bootText = "INITIALIZING SYSTEM...";
  bool _showDots = false;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    _controller.forward();

    // Animated dot sequence for boot text
    Future.delayed(const Duration(milliseconds: 500), _animateBootText);

    // Navigate to LoginScreen after short delay
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  void _animateBootText() async {
    const base = "SYSTEM BOOTING";
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _bootText = "$base${'.' * ((i + 1) % 4)}");
    }
    setState(() => _bootText = "ACCESSING CYBEROPS CORE...");
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _bootText = "READY.");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F2E), Color(0xFF003D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glowing circles
            Positioned(
              top: size.height * 0.25,
              left: size.width * 0.2,
              child: _glowCircle(100, Colors.tealAccent.withOpacity(0.2)),
            ),
            Positioned(
              bottom: size.height * 0.2,
              right: size.width * 0.25,
              child: _glowCircle(120, Colors.tealAccent.withOpacity(0.25)),
            ),

            // Logo and Boot Text
            FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "CYBEROPS",
                      style: GoogleFonts.orbitron(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: Colors.tealAccent.withOpacity(0.6),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        _bootText,
                        key: ValueKey(_bootText),
                        style: GoogleFonts.orbitron(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const SizedBox(
                      width: 180,
                      child: LinearProgressIndicator(
                        color: Colors.tealAccent,
                        backgroundColor: Colors.white24,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧩 Glowing background circles
  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 60,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }
}
