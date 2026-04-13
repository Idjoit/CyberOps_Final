import 'package:flutter/material.dart';

/// ChoiceCard
/// ------------------------------------------------------------
/// A reusable UI component representing a selectable choice.
///
/// Used in:
/// - Scenario-based gameplay (decision-making screens)
/// - Quiz or option selection interfaces
///
/// Features:
/// - Displays a text label
/// - Handles tap interaction
/// - Customizable background color
class ChoiceCard extends StatelessWidget {

  /// Text displayed inside the card (choice label)
  final String text;

  /// Callback function triggered when the card is tapped
  final VoidCallback onTap;

  /// Background color of the card (default: blueGrey)
  final Color color;

  /// Constructor
  const ChoiceCard({
    super.key,
    required this.text,
    required this.onTap,
    this.color = Colors.blueGrey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      // Trigger action when user taps the card
      onTap: onTap,

      child: Card(
        color: color,

        // Rounded corners for modern UI design
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        // Spacing between multiple choice cards
        margin: const EdgeInsets.symmetric(vertical: 8),

        elevation: 3,

        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: Center(

            // Display choice text
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
