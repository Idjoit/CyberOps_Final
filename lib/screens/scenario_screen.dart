import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cyberops/models/scenario_model.dart';
import 'package:cyberops/screens/scenario_components/game_end_dialog.dart';
import 'package:cyberops/screens/scenario_components/scenario_card.dart';
import 'package:cyberops/screens/scenario_components/swipe_gesture.dart';
import 'package:cyberops/services/game_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cyberops/screens/dashboard_screen.dart';

class ScenarioScreen extends StatefulWidget {
  final String userId;
  final bool isGuest;
  final bool launchedFromModule;
  final int moduleOrder;

  const ScenarioScreen({
    super.key,
    required this.userId,
    this.isGuest = false,
    this.launchedFromModule = false,
    this.moduleOrder = 1,
  });

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  final GameService _gameService = GameService();
  bool _loading = true;
  List<Scenario> _scenarios = [];
  int _currentIndex = 0;
  Scenario? _currentScenario;

  bool _showFeedback = false;
  String _feedback = "";

  Map<String, int> stats = {
    "Security": 50,
    "Awareness": 50,
    "Money": 50,
    "Trust": 50,
  };

  @override
  void initState() {
    super.initState();
    _loadScenariosFromFirestore();
  }

  Future<void> _loadScenariosFromFirestore() async {
    setState(() => _loading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('questions_module_${widget.moduleOrder}')
          .get();

      final scenarios = snapshot.docs.map((doc) {
        final data = doc.data();
        return Scenario(
          id: doc.id.hashCode,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          choiceA: data['choiceA'] ?? '',
          choiceB: data['choiceB'] ?? '',
          effectASecurity: data['effectASecurity'] ?? 0,
          effectAAwareness: data['effectAAwareness'] ?? 0,
          effectAMoney: data['effectAMoney'] ?? 0,
          effectATrust: data['effectATrust'] ?? 0,
          effectBSecurity: data['effectBSecurity'] ?? 0,
          effectBAwareness: data['effectBAwareness'] ?? 0,
          effectBMoney: data['effectBMoney'] ?? 0,
          effectBTrust: data['effectBTrust'] ?? 0,
          correctChoice: data['correctChoice'] ?? 'A',
          feedbackText: data['feedbackText'] ?? '',
          difficulty: data['difficulty'] ?? 1,
          category: data['category'] ?? '',
          imagePath: data['imagePath'] ?? '',
        );
      }).toList();

      setState(() {
        _scenarios = scenarios;
        _currentScenario = scenarios.isNotEmpty ? scenarios.first : null;
        _loading = false;
      });
    } catch (e) {
      debugPrint("⚠️ Firestore error: $e");
      setState(() => _loading = false);
    }
  }

  void _handleChoice(String choice) {
    if (_currentScenario == null || _currentIndex >= _scenarios.length) return;

    // 🌀 If feedback is showing, swipe again to move to next
    if (_showFeedback) {
      _nextScenario();
      return;
    }

    final current = _scenarios[_currentIndex];
    final bool correct = choice == current.correctChoice;

    // Update feedback
    setState(() {
      _showFeedback = true;
      _feedback = correct
          ? "${current.feedbackText}\n✅ Swipe again to continue."
          : "${current.feedbackText}\n❌ Swipe again to continue.";
    });

    // Update stats
    final isA = choice == 'A';
    stats["Security"] =
        (stats["Security"]! + (isA ? current.effectASecurity : current.effectBSecurity))
            .clamp(0, 100);
    stats["Awareness"] =
        (stats["Awareness"]! + (isA ? current.effectAAwareness : current.effectBAwareness))
            .clamp(0, 100);
    stats["Money"] =
        (stats["Money"]! + (isA ? current.effectAMoney : current.effectBMoney)).clamp(0, 100);
    stats["Trust"] =
        (stats["Trust"]! + (isA ? current.effectATrust : current.effectBTrust)).clamp(0, 100);
  }

  void _nextScenario() {
    bool missionFailed = stats.values.any((v) => v <= 0);
    bool allCompleted = _currentIndex + 1 >= _scenarios.length;

    if (missionFailed || allCompleted) {
      _showEndDialog(missionFailed);
    } else {
      setState(() {
        _currentIndex++;
        _currentScenario = _scenarios[_currentIndex];
        _showFeedback = false;
        _feedback = "";
      });
    }
  }

  Future<void> _showEndDialog(bool failed) async {
    if (!widget.isGuest && !failed) {
      try {
        // ✅ Update Firestore progress incrementally
        await _gameService.updateFirestoreProgress(
          userId: widget.userId,
          xp: 20 + (_scenarios.length * 5),
          level: 1,
          streak: 1,
          scenariosCompleted: _scenarios.length,
          totalScenarios: 10,
          moduleOrder: widget.moduleOrder,
        );

        // ✅ Then check and unlock achievements
        await _gameService.checkAndUnlockAchievements(
          widget.userId,
          level: 1,
          scenariosCompleted: _scenarios.length,
          correctAnswers: _scenarios.length, // adjust later if tracking correctness
          stats: stats,
        );

        debugPrint("🏆 Achievements checked for ${widget.userId}");
      } catch (e) {
        debugPrint("⚠️ Error updating progress/achievements: $e");
      }
    }

    // Show mission end dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameEndDialog(
        missionFailed: failed,
        stats: stats,
        onPlayAgain: widget.launchedFromModule ? () {} : _restartGame,
        onReturnDashboard: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardScreen(userId: widget.userId),
            ),
          );
        },
      ),
    );
  }

  void _restartGame() {
    Navigator.pop(context);
    setState(() {
      stats = {"Security": 50, "Awareness": 50, "Money": 50, "Trust": 50};
      _currentIndex = 0;
      _showFeedback = false;
      _feedback = "";
    });
    _loadScenariosFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    if (_scenarios.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "No scenarios available in Firestore.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final current = _scenarios[_currentIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.launchedFromModule
              ? "CYBEROPS TRAINING MODE"
              : "CYBEROPS SIMULATION",
          style: GoogleFonts.orbitron(
            fontSize: 18,
            color: Colors.tealAccent,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 4,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F2E), Color(0xFF003D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 110, 20, 20),
        child: Column(
          children: [
            if (widget.launchedFromModule) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.tealAccent, width: 0.8),
                ),
                child: Text(
                  "🧠 TRAINING MODE — from Cybersecurity Basics",
                  style: GoogleFonts.orbitron(
                    color: Colors.tealAccent,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 🧠 Stats section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: stats.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            e.key,
                            style: GoogleFonts.orbitron(
                              color: Colors.tealAccent,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: e.value / 100,
                              color: Colors.tealAccent,
                              backgroundColor:
                                  Colors.tealAccent.withOpacity(0.15),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${e.value}",
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // 🕹 Scenario Card
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  child: child,
                ),
                child: SwipeGesture(
                  key: ValueKey(_currentIndex),
                  onSwipeLeft: () => _handleChoice('B'),
                  onSwipeRight: () => _handleChoice('A'),
                  leftLabel: _showFeedback ? "NEXT" : current.choiceB,
                  rightLabel: _showFeedback ? "NEXT" : current.choiceA,
                  child: ScenarioCard(
                    scenario: current,
                    showFeedback: _showFeedback,
                    feedback: _feedback,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Opacity(
              opacity: 0.8,
              child: Text(
                _showFeedback ? "SWIPE TO CONTINUE" : "←  SWIPE  →",
                style: GoogleFonts.orbitron(
                  color: Colors.tealAccent.withOpacity(0.7),
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
