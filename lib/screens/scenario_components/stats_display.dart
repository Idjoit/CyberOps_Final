import 'package:flutter/material.dart';

class StatsDisplay extends StatelessWidget {
  final int security;
  final int awareness;
  final int money;
  final int trust;

  const StatsDisplay({
    super.key,
    required this.security,
    required this.awareness,
    required this.money,
    required this.trust,
  });

  Widget _buildStat(String label, int value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[300],
              color: color,
              minHeight: 10,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "$value",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _buildStat("Security", security, Colors.teal, Icons.shield),
            _buildStat("Awareness", awareness, Colors.orange, Icons.lightbulb),
            _buildStat("Money", money, Colors.green, Icons.attach_money),
            _buildStat("Trust", trust, Colors.blueAccent, Icons.handshake),
          ],
        ),
      ),
    );
  }
}
