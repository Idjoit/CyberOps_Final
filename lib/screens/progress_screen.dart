import 'package:flutter/material.dart';
import 'package:cyberops/widgets/progress_chart.dart';

/// ProgressScreen
/// ------------------------------------------------------------
/// Displays the user's performance progress over multiple sessions.
///
/// Features:
/// - Visual progress chart (line/bar via ProgressChart widget)
/// - Sample score tracking (can be replaced with real user data)
/// - Simple performance overview UI
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {

    /// Sample performance scores (replace with Firestore/SQLite data later)
    final List<double> sampleScores = [40, 55, 65, 72, 90];

    /// Labels for each session or stage
    final List<String> labels = ["S1", "S2", "S3", "S4", "S5"];

    return Scaffold(
      // Dark theme background for cyber-style UI consistency
      backgroundColor: Colors.blueGrey[900],

      appBar: AppBar(
        title: const Text("Progress Overview"),
        backgroundColor: Colors.blueGrey[800],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),

        child: Column(
          children: [
            // Section title
            const Text(
              "Performance Trend",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 20),

            // Chart visualization area
            Expanded(
              child: ProgressChart(
                scores: sampleScores,
                labels: labels,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
