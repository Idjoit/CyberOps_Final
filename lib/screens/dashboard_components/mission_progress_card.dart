import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🚀 Displays user progress, XP, modules, and streak in a CyberOps neon-glass style
class MissionProgressCard extends StatelessWidget {
  final Map<String, dynamic> progress;
  final int level;
  final int xp;
  final int streak;

  const MissionProgressCard({
    super.key,
    required this.progress,
    required this.level,
    required this.xp,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 Safely extract data (fallbacks ensure no crash)
    final int modulesCompleted = _asInt(progress['modulesCompleted']);
    final int totalModules = _asInt(progress['totalModules']);
    final int completedScenarios = _asInt(progress['completed']);
    final int totalScenarios = _asInt(progress['total']);

    // 🔹 Progress percentages (module, scenario, XP)
    final double modulePercent =
        totalModules > 0 ? (modulesCompleted / totalModules).clamp(0.0, 1.0) : 0.0;

    final double scenarioPercent =
        totalScenarios > 0 ? (completedScenarios / totalScenarios).clamp(0.0, 1.0) : 0.0;

    final double xpProgress = (xp % 100) / 100;

    return _buildGlassCard(
      title: "MISSION PROGRESS",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧩 Modules Progress
          _buildProgressBar(
            label: "Modules Completed: $modulesCompleted / $totalModules",
            value: modulePercent,
            accent: Colors.purpleAccent,
          ),
          const SizedBox(height: 14),

          // 🎯 Scenarios Progress
          _buildProgressBar(
            label:
                "Scenarios Completed: ${(scenarioPercent * 100).toStringAsFixed(0)}%",
            value: scenarioPercent,
            accent: Colors.lightBlueAccent,
          ),
          const SizedBox(height: 6),
          Text(
            "$completedScenarios / $totalScenarios Scenarios",
            style: GoogleFonts.orbitron(
              color: Colors.white70,
              fontSize: 13,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),

          // 🧠 XP Progress
          _buildProgressBar(
            label: "Experience: Level $level | XP ${xp % 100} / 100",
            value: xpProgress,
            accent: Colors.tealAccent,
          ),
          const SizedBox(height: 18),

          // 🧾 Summary Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat("LEVEL", level.toString()),
              _buildStat("XP", xp.toString()),
              _buildStat("STREAK", "${streak}🔥"),
            ],
          ),
        ],
      ),
    );
  }

  /// --- 🧩 Helper: Safe Int Parser ---
  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// --- 💠 Neon Glass Card Container ---
  Widget _buildGlassCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.orbitron(
              color: Colors.tealAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  /// --- ⚡ Neon Progress Bar ---
  Widget _buildProgressBar({
    required String label,
    required double value,
    Color accent = Colors.tealAccent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            color: accent,
            backgroundColor: accent.withOpacity(0.2),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// --- 🧾 Stat Display Box ---
  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: Colors.tealAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: Colors.white70,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
