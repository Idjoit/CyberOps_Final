import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cyberops/screens/scenario_screen.dart';
import 'package:cyberops/screens/quiz_game_screen.dart';

class LearningModuleDetailScreen extends StatefulWidget {
  final String userId;
  final String title;
  final String description;
  final String heading;
  final String duration;
  final List<Map<String, dynamic>> sections;
  final String gameType;
  final int order;

  const LearningModuleDetailScreen({
    super.key,
    required this.userId,
    required this.title,
    required this.description,
    required this.heading,
    required this.duration,
    required this.sections,
    required this.gameType,
    required this.order,
  });

  @override
  State<LearningModuleDetailScreen> createState() =>
      _LearningModuleDetailScreenState();
}

class _LearningModuleDetailScreenState
    extends State<LearningModuleDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 🎮 Handles launching the correct training game based on module type
  void _startModuleGame() {
    final normalizedType = widget.gameType.trim().toLowerCase();
    debugPrint("🎮 Launching module ${widget.order} with gameType: '$normalizedType'");

    switch (normalizedType) {
      case "strategy":
        // ✅ Scenario (Reigns-style) game
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ScenarioScreen(
              userId: widget.userId,
              isGuest: false,
              launchedFromModule: true,
              moduleOrder: widget.order,
            ),
          ),
        );
        break;

      case "quiz":
        // ✅ Multiple-choice quiz game
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QuizGameScreen(
              userId: widget.userId,
              isGuest: false,
              moduleOrder: widget.order,
            ),
          ),
        );
        break;

      case "simulation":
        // 🧩 Placeholder for future simulation-style module
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "🧠 Simulation mode coming soon!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.teal,
          ),
        );
        break;

      default:
        // ⚠️ Unsupported game type
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "⚠️ Game type '${widget.gameType}' not yet available.",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.teal,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSections = widget.sections.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.orbitron(
            color: Colors.tealAccent,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F2E), Color(0xFF003D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.heading,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                color: Colors.tealAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time,
                    color: Colors.tealAccent, size: 14),
                const SizedBox(width: 6),
                Text(
                  widget.duration,
                  style: GoogleFonts.orbitron(
                    color: Colors.tealAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 📘 PageView for learning content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: totalSections,
                itemBuilder: (context, index) {
                  final section = widget.sections[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.tealAccent.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.1),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        section["body"] ?? "No content available.",
                        style: GoogleFonts.orbitron(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.7,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 🔘 Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalSections, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 20 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.tealAccent
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // ⏭️ Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  _navButton("PREVIOUS", Icons.arrow_back_ios, () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  })
                else
                  const SizedBox(width: 100),

                _navButton(
                  _currentPage < totalSections - 1
                      ? "NEXT"
                      : "BEGIN TRAINING GAME",
                  _currentPage < totalSections - 1
                      ? Icons.arrow_forward_ios
                      : Icons.check,
                  _currentPage < totalSections - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : _startModuleGame,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Reusable styled navigation button
  Widget _navButton(String label, IconData icon, VoidCallback onPressed) {
    return Flexible(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
