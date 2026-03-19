import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementsScreen extends StatefulWidget {
  final String userId; // Firestore user ID
  final bool embedded; // hides AppBar if true

  const AchievementsScreen({
    super.key,
    required this.userId,
    this.embedded = false,
  });

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _achievements = [];
  bool _loading = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _loadAchievements();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    try {
      // 🧩 Skip Firestore lookup for guest mode
      if (widget.userId == "guest") {
        setState(() {
          _achievements = [];
          _loading = false;
        });
        return;
      }

      // 🔹 Fetch achievements from Firestore
      final snapshot = await _firestore
          .collection('user_progress')
          .doc(widget.userId)
          .collection('achievements')
          .get();

      final achievements = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? 'Unknown',
          'achieved_at': data['achievedAt'] ?? 'Unknown',
        };
      }).toList();

      setState(() {
        _achievements = achievements;
        _loading = false;
      });

      if (_achievements.isNotEmpty) _controller.forward();
    } catch (e) {
      debugPrint("⚠️ Firestore error while loading achievements: $e");
      setState(() {
        _achievements = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = widget.embedded ? 100.0 : 120.0;

    return Scaffold(
      extendBodyBehindAppBar: !widget.embedded,
      backgroundColor: Colors.black,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.black.withOpacity(0.7),
              elevation: 4,
              centerTitle: true,
              title: Text(
                "ACHIEVEMENTS",
                style: GoogleFonts.orbitron(
                  color: Colors.tealAccent,
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.tealAccent),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F2E), Color(0xFF003D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.fromLTRB(20, topPadding, 20, 30),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              )
            : _achievements.isEmpty
                ? Center(
                    child: Text(
                      widget.userId == "guest"
                          ? "Achievements are disabled in Guest Mode."
                          : "No achievements unlocked yet.",
                      style: GoogleFonts.orbitron(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _achievements.length,
                    itemBuilder: (context, index) {
                      final achievement = _achievements[index];
                      final animation = CurvedAnimation(
                        parent: _controller,
                        curve: Interval(
                          (index / _achievements.length).clamp(0.0, 1.0),
                          1.0,
                          curve: Curves.easeOutExpo,
                        ),
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: _buildAchievementCard(achievement),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final Color glowColor = Colors.tealAccent;
    final String name = achievement['name'] ?? 'Unknown';
    final String achievedAt = achievement['achieved_at'] ?? 'Unknown';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: glowColor.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.25),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: glowColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: glowColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.tealAccent,
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    color: glowColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Unlocked: $achievedAt",
                  style: GoogleFonts.orbitron(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
