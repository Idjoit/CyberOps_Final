import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

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
          SizedBox(width: 90, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              color: color,
              backgroundColor: Colors.grey[300],
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          Text(value.toString()),
        ],
      ),
    );
  }
}
