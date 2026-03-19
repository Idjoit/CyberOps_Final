import 'package:flutter/material.dart';
import 'package:cyberops/widgets/progress_chart.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<double> sampleScores = [40, 55, 65, 72, 90];
    final List<String> labels = ["S1", "S2", "S3", "S4", "S5"];

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Progress Overview"),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Performance Trend",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            Expanded(child: ProgressChart(scores: sampleScores, labels: labels)),
          ],
        ),
      ),
    );
  }
}
