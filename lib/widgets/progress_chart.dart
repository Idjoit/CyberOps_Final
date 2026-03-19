import 'package:flutter/material.dart';

class ProgressChart extends StatelessWidget {
  final List<double> scores;
  final List<String> labels;

  const ProgressChart({
    super.key,
    required this.scores,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Progress Overview",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 20),
        for (int i = 0; i < scores.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                SizedBox(width: 40, child: Text(labels[i], style: const TextStyle(color: Colors.white))),
                Expanded(
                  child: LinearProgressIndicator(
                    value: scores[i] / 100,
                    backgroundColor: Colors.grey[800],
                    color: Colors.blueGrey,
                    minHeight: 12,
                  ),
                ),
                const SizedBox(width: 10),
                Text("${scores[i].toInt()}%", style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
      ],
    );
  }
}
