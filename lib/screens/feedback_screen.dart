/// FeedbackScreen
/// ------------------------------------------------------------
/// A stateless screen that displays feedback after a user makes a
/// decision in a scenario-based activity (e.g., quiz, game, training app).
///
/// It shows:
/// - Whether the answer is correct or incorrect
/// - A feedback/explanation message
/// - A button to proceed to the next scenario
import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  final bool isCorrect;
  final String feedbackText;
  final VoidCallback onNext;

  const FeedbackScreen({
    super.key,
    required this.isCorrect,
    required this.feedbackText,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isCorrect ? "Correct Decision!" : "Incorrect Decision!",
                    style: TextStyle(
                      color: isCorrect ? Colors.green[800] : Colors.red[800],
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    feedbackText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Next Scenario",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
