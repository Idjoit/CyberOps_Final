import 'dart:convert';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cyberops.db');

    return await openDatabase(
      path,
      version: 2, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // --- Users table ---
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT DEFAULT 'user',
        created_at TEXT,
        security_question TEXT,
        security_answer TEXT
      )
    ''');

    // --- Scenarios table ---
    await db.execute('''
      CREATE TABLE scenarios (
        scenario_id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        choice_a TEXT,
        choice_b TEXT,
        effect_a_security INTEGER,
        effect_a_awareness INTEGER,
        effect_a_money INTEGER,
        effect_a_trust INTEGER,
        effect_b_security INTEGER,
        effect_b_awareness INTEGER,
        effect_b_money INTEGER,
        effect_b_trust INTEGER,
        correct_choice TEXT,
        feedback_text TEXT,
        difficulty INTEGER,
        category TEXT,
        image_path TEXT
      )
    ''');

    // --- Analytics table ---
    await db.execute('''
      CREATE TABLE analytics_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        scenario_id INTEGER,
        decision TEXT,
        is_correct INTEGER,
        time_spent INTEGER,
        difficulty_level INTEGER,
        delta_security INTEGER,
        delta_awareness INTEGER,
        delta_money INTEGER,
        delta_trust INTEGER,
        timestamp TEXT
      )
    ''');

    // --- Achievements table ---
    await db.execute('''
      CREATE TABLE user_achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        achievement_id TEXT,
        name TEXT,
        achieved_at TEXT
      )
    ''');

    // --- Game progress table ---
    await db.execute('''
      CREATE TABLE game_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        current_scenario INTEGER,
        security_score INTEGER,
        awareness_score INTEGER,
        money_score INTEGER,
        trust_score INTEGER,
        xp INTEGER,
        level INTEGER,
        streak INTEGER,
        difficulty_level INTEGER,
        timestamp TEXT
      )
    ''');

    await _insertDefaultScenarios(db);
  }

  /// Handles database upgrades (e.g., adding new columns)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new security fields if not present
      await db.execute("ALTER TABLE users ADD COLUMN security_question TEXT");
      await db.execute("ALTER TABLE users ADD COLUMN security_answer TEXT");
      debugPrint("✅ Added security_question and security_answer columns to users table.");
    }
  }

  Future<void> _insertDefaultScenarios(Database db) async {
    try {
      final count =
          Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM scenarios')) ?? 0;
      if (count > 0) {
        debugPrint('✅ Default scenarios already exist, skipping insert.');
        return;
      }

      debugPrint('📂 Loading default scenarios from JSON...');
      final jsonString = await rootBundle.loadString('assets/data/default_scenarios.json');
      final List<dynamic> data = json.decode(jsonString);

      for (final s in data) {
        final scenario = {
          'title': s['title'],
          'description': s['description'],
          'choice_a': s['choiceA'],
          'choice_b': s['choiceB'],
          'effect_a_security': s['effectASecurity'],
          'effect_a_awareness': s['effectAAwareness'],
          'effect_a_money': s['effectAMoney'],
          'effect_a_trust': s['effectATrust'],
          'effect_b_security': s['effectBSecurity'],
          'effect_b_awareness': s['effectBAwareness'],
          'effect_b_money': s['effectBMoney'],
          'effect_b_trust': s['effectBTrust'],
          'correct_choice': s['correctChoice'],
          'feedback_text': s['feedbackText'],
          'difficulty': s['difficulty'],
          'category': s['category'] ?? 'General',
          'image_path': s['imagePath'] ?? 'assets/images/placeholder.png',
        };
        await db.insert('scenarios', scenario);
      }

      debugPrint('✅ Default scenarios successfully inserted.');
    } catch (e) {
      debugPrint('❌ Error inserting default scenarios: $e');
    }
  }

  // -----------------------------------------------------------
  // 🧠 Added for offline password recovery
  // -----------------------------------------------------------

  /// Fetch user by username (case-insensitive)
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [username.toLowerCase()],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Update password for user
  Future<void> updatePassword(int userId, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
