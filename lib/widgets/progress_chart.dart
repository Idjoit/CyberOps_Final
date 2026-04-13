import 'package:flutter/material.dart';

/// ProgressChart
/// ------------------------------------------------------------
/// A reusable widget that visualizes user performance using
/// horizontal progress bars.
///
/// Features:
/// - Displays multiple scores with labels
/// - Uses LinearProgressIndicator for visual representation
/// - Shows percentage values for each entry
///
/// Used in:
/// - Progress tracking screens
/// - Performance dashboards
class ProgressChart extends StatelessWidget {

  /// List of score values (expected range: 0–100)
  final List<double> scores;

  /// Labels corresponding to each score (e.g., "S1", "S2")
  final List<String> labels;

  /// Constructor
  const ProgressChart({
    super.key,
    required this.scores,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Chart title
        const Text(
          "Progress Overview",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        // Generate progress bars dynamically based on scores
        for (int i = 0; i < scores.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),

            child: Row(
              children: [

                // Label (e.g., S1, S2, etc.)
                SizedBox(
                  width: 40,
                  child: Text(
                    labels[i],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                // Progress bar representing score percentage
                Expanded(
                  child: LinearProgressIndicator(
                    value: scores[i] / 100, // Normalize to 0–1
                    backgroundColor: Colors.grey[800],
                    color: Colors.blueGrey,
                    minHeight: 12,
                  ),
                ),

                const SizedBox(width: 10),

                // Percentage text display
                Text(
                  "${scores[i].toInt()}%",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
