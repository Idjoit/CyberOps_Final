import 'package:flutter/material.dart';

/// StatBar
/// ------------------------------------------------------------
/// A reusable widget that displays a single statistic as a progress bar.
///
/// Used for:
/// - Showing player stats (security, awareness, trust, money)
/// - Visualizing percentage-based values
///
/// Features:
/// - Label + progress bar + numeric value
/// - Customizable bar color
class StatBar extends StatelessWidget {

  /// Label for the stat (e.g., "Security", "Awareness")
  final String label;

  /// Numeric value of the stat (expected range: 0–100)
  final int value;

  /// Color of the progress bar
  final Color color;

  /// Constructor
  const StatBar({
    super.key,
    required this.label,
    required this.value,
    this.color = Colors.blueGrey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),

      child: Row(
        children: [

          // Stat label
          SizedBox(
            width: 90,
            child: Text(label),
          ),

          // Progress bar visualization
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100, // Normalize value to 0–1
              color: color,
              backgroundColor: Colors.grey[300],
              minHeight: 8,
            ),
          ),

          const SizedBox(width: 8),

          // Numeric display of stat value
          Text(value.toString()),
        ],
      ),
    );
  }
}
