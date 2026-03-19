import 'package:flutter/material.dart';

class SessionSummaryScreen extends StatelessWidget {
  final int level;
  final int xp;
  final List<String> badges;

  const SessionSummaryScreen({
    super.key,
    required this.level,
    required this.xp,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Session Summary"),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Training Session Complete!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard("Level", level.toString()),
            _buildInfoCard("XP Gained", xp.toString()),
            const SizedBox(height: 20),
            const Text(
              "Badges Unlocked",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            badges.isEmpty
                ? const Text("No badges yet. Keep training!",
                    style: TextStyle(color: Colors.white))
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: badges
                        .map(
                          (b) => Chip(
                            label: Text(b),
                            backgroundColor: Colors.lightBlue[100],
                          ),
                        )
                        .toList(),
                  ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text("Return to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
