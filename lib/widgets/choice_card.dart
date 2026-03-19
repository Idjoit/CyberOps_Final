import 'package:flutter/material.dart';

class ChoiceCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;

  const ChoiceCard({
    super.key,
    required this.text,
    required this.onTap,
    this.color = Colors.blueGrey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
