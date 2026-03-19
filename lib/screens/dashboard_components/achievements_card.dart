import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🏆 Displays player achievements or a guest/empty message
class AchievementsCard extends StatelessWidget {
  final bool isGuest;
  final List<Map<String, dynamic>> achievements;

  const AchievementsCard({
    super.key,
    required this.isGuest,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    return _buildGlassCard(
      title: "ACHIEVEMENTS",
      child: isGuest
          ? Text(
              "Achievements are disabled in guest mode.",
              style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 13),
            )
          : achievements.isEmpty
              ? Text(
                  "No achievements unlocked yet.",
                  style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 13),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: achievements
                      .map(
                        (a) => Chip(
                          label: Text(
                            a['name'] ?? 'Unknown',
                            style: GoogleFonts.orbitron(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          backgroundColor: Colors.tealAccent.shade100,
                        ),
                      )
                      .toList(),
                ),
    );
  }

  // --- Glass Card Wrapper ---
  Widget _buildGlassCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.orbitron(
              color: Colors.tealAccent,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
