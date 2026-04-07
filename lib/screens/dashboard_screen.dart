import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cyberops/services/game_service.dart';
import 'package:cyberops/database/db_helper.dart';
import 'package:cyberops/screens/achievements_screen.dart';
import 'package:cyberops/screens/learning_module_screen.dart';
import 'package:cyberops/screens/dashboard_components/user_header.dart';
import 'package:cyberops/screens/dashboard_components/mission_progress_card.dart';
import 'package:cyberops/screens/dashboard_components/achievements_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


import 'package:cyberops/screens/admin/admin_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  final bool isGuest;

  const DashboardScreen({
    super.key,
    required this.userId,
    this.isGuest = false,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GameService _gameService = GameService();
  final DBHelper _dbHelper = DBHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 0;

  Map<String, dynamic> _progress = {};
  List<Map<String, dynamic>> _achievements = [];
  bool _loading = true;

  String _username = "Agent";
  String _lastMissionUpdate = "No missions yet";
  int _level = 1;
  int _xp = 0;
  int _streak = 0;

  //New: role handling
  String _role = "user";

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (widget.isGuest) {
      setState(() {
        _username = "Guest";
        _progress = {
          'completed': 0,
          'total': 0,
          'progressPercent': 0,
          'modulesCompleted': 0,
          'totalModules': 0,
        };
        _achievements = [];
        _lastMissionUpdate = "N/A (Guest Mode)";
        _loading = false;
      });
      return;
    }

    try {
      // Load user profile for name + role
      final userInfo =
          await _firestore.collection('users').doc(widget.userId).get();
      if (userInfo.exists) {
        final data = userInfo.data()!;
        _username = data['username'] ?? 'Agent';
        _role = data['role'] ?? 'user';
      }

      //  Load user progress
      final userDoc =
          await _firestore.collection('user_progress').doc(widget.userId).get();

      final modulesSnapshot =
          await _firestore.collection('learning_modules').get();
      final totalModules = modulesSnapshot.docs.length;

      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        _level = _toInt(data['level']);
        _xp = _toInt(data['xp']);
        _streak = _toInt(data['streak']);

        final modulesCompleted = _toInt(data['modulesCompleted']);
        final scenariosCompleted = _toInt(data['scenariosCompleted']);
        final totalScenarios = _toInt(data['totalScenarios']);

        _progress = {
          'modulesCompleted': modulesCompleted,
          'totalModules': totalModules,
          'completed': scenariosCompleted,
          'total': totalScenarios,
          'progressPercent':
              _calculatePercent(scenariosCompleted, totalScenarios),
        };

        _lastMissionUpdate = data['lastUpdated'] != null
            ? DateFormat('MMM dd, yyyy – HH:mm')
                .format(DateTime.parse(data['lastUpdated']))
            : "No recent missions";
      } else {
        _progress = {
          'modulesCompleted': 0,
          'totalModules': totalModules,
          'completed': 0,
          'total': 0,
          'progressPercent': 0,
        };
      }

      // Fetch Firestore achievements
      final achievementsSnapshot = await _firestore
          .collection('user_progress')
          .doc(widget.userId)
          .collection('achievements')
          .get();

      final achievements = achievementsSnapshot.docs.map((doc) {
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
    } catch (e) {
      debugPrint("⚠️ Error loading dashboard data: $e");
      setState(() {
        _username = "Agent";
        _progress = {'completed': 0, 'total': 0, 'progressPercent': 0};
        _achievements = [];
        _lastMissionUpdate = "Error fetching data";
        _loading = false;
      });
    }
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  int _calculatePercent(int completed, int total) {
    if (total <= 0) return 0;
    return ((completed / total) * 100).clamp(0, 100).toInt();
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final pages = [
      _buildDashboardContent(size),
      AchievementsScreen(userId: widget.userId, embedded: true),
      LearningModuleScreen(userId: widget.userId, isGuest: widget.isGuest),
    ];

    final titles = [
      "CYBEROPS DASHBOARD",
      "ACHIEVEMENTS",
      "LEARNING MODULES",
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 4,
        centerTitle: true,
        title: Text(
          titles[_selectedIndex],
          style: GoogleFonts.orbitron(
            color: Colors.tealAccent,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          //New: Admin panel button (only visible for admins)
          if (_role == "admin")
            IconButton(
              icon: const Icon(Icons.admin_panel_settings,
                  color: Colors.tealAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AdminDashboardScreen(userId: widget.userId)),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.tealAccent),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              )
            : pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          border: const Border(
            top: BorderSide(color: Colors.tealAccent, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.tealAccent,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onTabSelected,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              label: "Achievements",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              label: "Modules",
            ),
          ],
          selectedLabelStyle: GoogleFonts.orbitron(
            fontSize: 12,
            letterSpacing: 1.2,
          ),
          unselectedLabelStyle: GoogleFonts.orbitron(fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(Size size) {
    return Container(
      height: size.height,
      width: size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF001F2E), Color(0xFF003D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: Colors.tealAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 90, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome, $_username",
                style: GoogleFonts.orbitron(
                  color: Colors.tealAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              UserHeader(
                username: _username,
                lastMissionUpdate: _lastMissionUpdate,
                isGuest: widget.isGuest,
              ),
              const SizedBox(height: 30),
              MissionProgressCard(
                progress: _progress,
                level: _level,
                xp: _xp,
                streak: _streak,
              ),
              const SizedBox(height: 30),
              AchievementsCard(
                isGuest: widget.isGuest,
                achievements: _achievements,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
