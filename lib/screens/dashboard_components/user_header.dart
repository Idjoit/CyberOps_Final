import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🧠 Displays last mission date and guest info
class UserHeader extends StatelessWidget {
  final String username;
  final String lastMissionUpdate;
  final bool isGuest;

  const UserHeader({
    super.key,
    required this.username,
    required this.lastMissionUpdate,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🕓 Last mission info
        Text(
          isGuest
              ? "Guest Mode - Progress not saved"
              : "Last Mission: $lastMissionUpdate",
          style: GoogleFonts.orbitron(
            color: Colors.white70,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
