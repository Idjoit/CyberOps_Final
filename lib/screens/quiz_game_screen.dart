import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cyberops/models/quiz_question_model.dart';
import 'package:cyberops/screens/scenario_components/game_end_dialog.dart';
import 'package:cyberops/screens/dashboard_screen.dart';
import 'package:cyberops/services/game_service.dart';

class QuizGameScreen extends StatefulWidget {
  final String userId;
  final bool isGuest;
  final int moduleOrder;

  const QuizGameScreen({
    super.key,
    required this.userId,
    this.isGuest = false,
    this.moduleOrder = 3,
  });

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  final GameService _gameService = GameService();
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  bool _loading = true;
  bool _answered = false;
  int? _selectedIndex;
  int _correctAnswers = 0;

  Timer? _timer;
  double _timeLeft = 60.0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _loading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('questions_module_${widget.moduleOrder}')
          .get();

      final questions =
          snapshot.docs.map((doc) => QuizQuestion.fromFirestore(doc)).toList();

      setState(() {
        _questions = questions;
        _loading = false;
      });

      _startTimer();
    } catch (e) {
      debugPrint("Error loading quiz questions: $e");
      setState(() => _loading = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        _handleTimeout();
        timer.cancel();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _handleTimeout() {
    if (!_answered) {
      setState(() {
        _answered = true;
        _selectedIndex = null;
      });
    }
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    final current = _questions[_currentIndex];
    final correct = index == current.correctAnswerIndex;

    setState(() {
      _answered = true;
      _selectedIndex = index;
      if (correct) _correctAnswers++;
    });

    _timer?.cancel();
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= _questions.length) {
      _endQuiz();
    } else {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedIndex = null;
      });
      _startTimer();
    }
  }

  Future<void> _endQuiz() async {
    _timer?.cancel();

    if (!widget.isGuest) {
      try {
        await _gameService.updateFirestoreProgress(
          userId: widget.userId,
          xp: 30 + (_correctAnswers * 5),
          level: 1,
          streak: 1,
          scenariosCompleted: _questions.length,
          totalScenarios: _questions.length,
          fromModule: true,
          moduleOrder: widget.moduleOrder,
        );

        await _gameService.checkAndUnlockAchievements(
          widget.userId,
          level: 1,
          scenariosCompleted: _questions.length,
          correctAnswers: _correctAnswers,
          stats: {"Security": 60, "Awareness": 60, "Trust": 60, "Money": 50},
        );
      } catch (e) {
        debugPrint("⚠️ Error saving quiz results: $e");
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameEndDialog(
        missionFailed: false,
        stats: {
          "Score": ((_correctAnswers / _questions.length) * 100).toInt(),
          "Correct": _correctAnswers,
          "Total": _questions.length,
        },
        onPlayAgain: _restartQuiz,
        onReturnDashboard: () {
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

  void _restartQuiz() {
    Navigator.pop(context);
    setState(() {
      _currentIndex = 0;
      _correctAnswers = 0;
      _answered = false;
      _selectedIndex = null;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

    if (_questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "No quiz questions available.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final current = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F2E), Color(0xFF003D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Mission Header
            Text(
              " CYBEROPS TRAINING — MODULE ${widget.moduleOrder}",
              style: GoogleFonts.orbitron(
                color: Colors.tealAccent,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            // 🔹 Timer + progress row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Question ${_currentIndex + 1}/${_questions.length}",
                  style: GoogleFonts.orbitron(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "${_timeLeft.toInt()}s",
                  style: GoogleFonts.orbitron(
                    color:
                        _timeLeft < 10 ? Colors.redAccent : Colors.tealAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _timeLeft / 60,
                color: Colors.tealAccent,
                backgroundColor: Colors.white10,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 25),

            // 🔹 Question Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.tealAccent.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                current.question,
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  color: Colors.tealAccent,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 🔹 Centered Answer Buttons (Improved)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < current.options.length; i++) ...[
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 320),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.tealAccent.withOpacity(
                                  _answered &&
                                          i == current.correctAnswerIndex
                                      ? 0.5
                                      : 0.1,
                                ),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _answered
                                  ? i == current.correctAnswerIndex
                                      ? Colors.tealAccent
                                      : (i == _selectedIndex
                                          ? Colors.redAccent
                                          : Colors.white10)
                                  : Colors.white10,
                              foregroundColor:
                                  _answered && i == current.correctAnswerIndex
                                      ? Colors.black
                                      : Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.tealAccent.withOpacity(0.4),
                                  width: 0.8,
                                ),
                              ),
                            ),
                            onPressed: () => _selectAnswer(i),
                            child: Text(
                              current.options[i],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.orbitron(
                                fontSize: 13,
                                letterSpacing: 1,
                                color: _answered && i == _selectedIndex
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Feedback Section
            if (_answered)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 1,
                child: Column(
                  children: [
                    Text(
                      _selectedIndex == current.correctAnswerIndex
                          ? "✅ Correct!"
                          : "❌ Incorrect.",
                      style: GoogleFonts.orbitron(
                        color: _selectedIndex == current.correctAnswerIndex
                            ? Colors.tealAccent
                            : Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      current.explanation,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _nextQuestion,
                      icon: const Icon(Icons.arrow_forward_ios, size: 14),
                      label: Text(
                        _currentIndex + 1 >= _questions.length
                            ? "FINISH QUIZ"
                            : "NEXT QUESTION",
                        style: GoogleFonts.orbitron(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
