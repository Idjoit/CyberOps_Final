import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎮 Displays Start and View Achievements buttons
class DashboardButtons extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onViewAchievements;

  const DashboardButtons({
    super.key,
    required this.onStart,
    required this.onViewAchievements,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildNeonButton(
          text: "START SIMULATION",
          icon: Icons.play_arrow,
          onTap: onStart,
        ),
        const SizedBox(height: 16),
        _buildNeonButton(
          text: "VIEW ACHIEVEMENTS",
          icon: Icons.emoji_events,
          color: Colors.tealAccent.withOpacity(0.7),
          onTap: onViewAchievements,
        ),
      ],
    );
  }

  // --- Neon Button Widget ---
  Widget _buildNeonButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.tealAccent,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black),
      label: Text(
        text,
        style: GoogleFonts.orbitron(
          color: Colors.black,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: color,
        elevation: 8,
      ),
    );
  }
}
