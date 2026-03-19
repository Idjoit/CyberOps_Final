import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameEndDialog extends StatelessWidget {
  final bool missionFailed;
  final Map<String, int> stats;
  final VoidCallback onPlayAgain;
  final VoidCallback onReturnDashboard;

  const GameEndDialog({
    super.key,
    required this.missionFailed,
    required this.stats,
    required this.onPlayAgain,
    required this.onReturnDashboard,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = missionFailed ? Colors.redAccent : Colors.tealAccent;

    return Stack(
      children: [
        // 🕶 Dimmed holographic background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001F2E), Color(0xFF003D40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        // Centered Neon Dialog
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.5),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🎖 Icon + Header
                  Icon(
                    missionFailed ? Icons.warning_amber_rounded : Icons.military_tech,
                    size: 70,
                    color: accentColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    missionFailed ? "MISSION FAILED" : "MISSION COMPLETE",
                    style: GoogleFonts.orbitron(
                      color: accentColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    missionFailed
                        ? "Your systems were compromised. Regroup and retry."
                        : "Excellent work, Agent. You've secured the network.",
                    style: GoogleFonts.orbitron(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),

                  // 📊 Stat Bars (Cyber style)
                  ...stats.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              entry.key.toUpperCase(),
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: entry.value / 100,
                                color: accentColor,
                                backgroundColor: accentColor.withOpacity(0.15),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${entry.value}",
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 32),

                  // 🎮 Buttons
                  _buildNeonButton(
                    context,
                    label: "PLAY AGAIN",
                    icon: Icons.refresh,
                    color: accentColor,
                    onPressed: onPlayAgain,
                  ),
                  const SizedBox(height: 14),
                  _buildHollowButton(
                    context,
                    label: "RETURN TO DASHBOARD",
                    icon: Icons.home,
                    onPressed: onReturnDashboard,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 🔘 Neon Button
  Widget _buildNeonButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black),
      label: Text(
        label,
        style: GoogleFonts.orbitron(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.3,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: color,
        elevation: 10,
      ),
    );
  }

  // ⚙️ Hollow Cyber Button
  Widget _buildHollowButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.tealAccent),
      label: Text(
        label,
        style: GoogleFonts.orbitron(
          color: Colors.tealAccent,
          letterSpacing: 1.1,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.tealAccent, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
