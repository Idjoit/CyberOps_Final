import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String userId; // ✅ Added this parameter for consistency

  const AdminDashboardScreen({super.key, required this.userId});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = true;
  List<Map<String, dynamic>> _userData = [];

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
  }

  Future<void> _loadUserProgress() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final progressSnapshot =
          await _firestore.collection('user_progress').get();

      final userProgressMap = {
        for (var doc in progressSnapshot.docs) doc.id: doc.data(),
      };

      final List<Map<String, dynamic>> combined =
          usersSnapshot.docs.map((userDoc) {
        final userId = userDoc.id;
        final userData = userDoc.data();
        final progress = userProgressMap[userId] ?? {};

        return {
          'id': userId,
          'username': userData['username'] ?? 'Unknown',
          'xp': progress['xp'] ?? 0,
          'level': progress['level'] ?? 1,
          'streak': progress['streak'] ?? 0,
          'modulesCompleted': progress['modulesCompleted'] ?? 0,
          'totalModules': progress['totalModules'] ?? 0,
          'scenariosCompleted': progress['scenariosCompleted'] ?? 0,
          'totalScenarios': progress['totalScenarios'] ?? 0,
          'lastUpdated': progress['lastUpdated'] ?? 'N/A',
        };
      }).toList();

      setState(() {
        _userData = combined;
        _loading = false;
      });
    } catch (e) {
      debugPrint("⚠️ Error loading user progress: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        title: Text(
          "ADMIN DASHBOARD",
          style: GoogleFonts.orbitron(
            color: Colors.tealAccent,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            )
          : RefreshIndicator(
              onRefresh: _loadUserProgress,
              color: Colors.tealAccent,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _userData.length,
                itemBuilder: (context, index) {
                  final user = _userData[index];
                  final percentModules = _calculatePercent(
                    user['modulesCompleted'],
                    user['totalModules'],
                  );
                  final percentScenarios = _calculatePercent(
                    user['scenariosCompleted'],
                    user['totalScenarios'],
                  );

                  return Card(
                    color: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.tealAccent.withOpacity(0.3),
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        user['username'],
                        style: GoogleFonts.orbitron(
                          color: Colors.tealAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Level ${user['level']} • XP ${user['xp']} • Streak ${user['streak']}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildProgressBar("Modules", percentModules),
                          const SizedBox(height: 4),
                          _buildProgressBar("Scenarios", percentScenarios),
                          const SizedBox(height: 8),
                          Text(
                            "Last update: ${user['lastUpdated']}",
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      onTap: () =>
                          _openUserDetails(user['id'], user['username']),
                    ),
                  );
                },
              ),
            ),
    );
  }

  int _calculatePercent(int completed, int total) {
    if (total <= 0) return 0;
    return ((completed / total) * 100).clamp(0, 100).toInt();
  }

  Widget _buildProgressBar(String label, int percent) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            "$label:",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: percent / 100,
            color: Colors.tealAccent,
            backgroundColor: Colors.white12,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          "$percent%",
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  void _openUserDetails(String userId, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            UserDetailScreen(userId: userId, username: username),
      ),
    );
  }
}

class UserDetailScreen extends StatelessWidget {
  final String userId;
  final String username;

  const UserDetailScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "$username's Progress",
          style: GoogleFonts.orbitron(color: Colors.tealAccent),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('user_progress')
            .doc(userId)
            .collection('achievements')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            );
          }

          final achievements = snapshot.data!.docs;

          if (achievements.isEmpty) {
            return const Center(
              child: Text(
                "No achievements yet.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final data = achievements[index].data();
              return Card(
                color: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.tealAccent.withOpacity(0.3),
                  ),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    data['name'] ?? 'Unknown Achievement',
                    style: GoogleFonts.orbitron(color: Colors.tealAccent),
                  ),
                  subtitle: Text(
                    "Unlocked: ${data['achievedAt'] ?? 'N/A'}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
