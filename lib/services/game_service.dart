import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyberops/database/db_helper.dart';
import 'package:cyberops/models/progress_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class GameService {
  final DBHelper _dbHelper = DBHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// 🧩 Updates local + Firestore progress
  Future<void> updateProgress(GameProgress progress) async {
    final db = await _dbHelper.database;

    final existing = await db.query(
      'game_progress',
      where: 'user_id = ?',
      whereArgs: [progress.userId],
      limit: 1,
    );

    int previousXP = 0;
    int previousLevel = 1;
    int previousStreak = 0;

    if (existing.isNotEmpty) {
      final row = existing.first;
      previousXP = _asInt(row['xp']);
      previousLevel = _asInt(row['level']);
      previousStreak = _asInt(row['streak']);
    }

    int xpGain = switch (progress.difficultyLevel) {
      1 => 10,
      2 => 20,
      3 => 30,
      _ => 10,
    };

    int newXP = previousXP + xpGain;
    int newLevel = previousLevel;
    int newStreak = previousStreak + 1;

    while (newXP >= 100) {
      newXP -= 100;
      newLevel++;
    }

    final data = {
      'user_id': progress.userId,
      'current_scenario': progress.currentScenario,
      'security_score': progress.securityScore,
      'awareness_score': progress.awarenessScore,
      'money_score': progress.moneyScore,
      'trust_score': progress.trustScore,
      'xp': newXP,
      'level': newLevel,
      'streak': newStreak,
      'difficulty_level': progress.difficultyLevel,
      'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    };

    if (existing.isEmpty) {
      await db.insert('game_progress', data);
    } else {
      await db.update(
        'game_progress',
        data,
        where: 'user_id = ?',
        whereArgs: [progress.userId],
      );
    }

    try {
      final String userDocId = progress.userId.toString();
      final userProgressRef =
          _firestore.collection('user_progress').doc(userDocId);
      final userDoc = await userProgressRef.get();

      if (!userDoc.exists) {
        await userProgressRef.set({
          'xp': newXP,
          'level': newLevel,
          'streak': newStreak,
          'modulesCompleted': 0,
          'totalModules': 10,
          'scenariosCompleted': 1,
          'totalScenarios': 10,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      } else {
        await userProgressRef.update({
          'xp': newXP,
          'level': newLevel,
          'streak': newStreak,
          'scenariosCompleted': FieldValue.increment(1),
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }

      debugPrint("☁️ Synced progress to Firestore for user $userDocId");
    } catch (e) {
      debugPrint("⚠️ Firestore sync failed: $e");
    }

    debugPrint(
      "✅ Progress Updated → XP: $newXP, Level: $newLevel, Streak: $newStreak (User ${progress.userId})",
    );
  }

  /// 🧩 Get total module count dynamically from Firestore
  Future<int> getTotalModules() async {
    try {
      final snapshot = await _firestore.collection('learning_modules').get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint("⚠️ Error counting modules: $e");
      return 0;
    }
  }

  /// 🧩 NEW: Dynamically count total scenarios (auto-detect modules)
  Future<int> getTotalScenarios() async {
    try {
      int total = 0;

      // 🔍 Query all top-level collections and detect which are module question sets
      final List<String> allCollections = [
        'questions_module_1',
        'questions_module_2',
        'questions_module_3',
        'questions_module_4',
        'questions_module_5',
        'questions_module_6',
        'questions_module_7',
        'questions_module_8',
        'questions_module_9',
        'questions_module_10',
      ];

      for (final name in allCollections) {
        final snapshot = await _firestore.collection(name).get();
        if (snapshot.docs.isNotEmpty) total += snapshot.docs.length;
      }

      debugPrint("📊 Total Scenarios Counted: $total");
      return total;
    } catch (e) {
      debugPrint("⚠️ Error counting total scenarios: $e");
      return 0;
    }
  }

  /// 🔄 Update Firestore progress (now dynamically aware of all total scenarios)
  Future<void> updateFirestoreProgress({
    required String userId,
    required int xp,
    required int level,
    required int streak,
    required int scenariosCompleted,
    required int totalScenarios,
    required int moduleOrder,
    bool fromModule = false,
  }) async {
    try {
      final userRef = _firestore.collection('user_progress').doc(userId);
      final doc = await userRef.get();
      final totalModules = await getTotalModules();
      final dynamicTotalScenarios = await getTotalScenarios(); // ✅ dynamic global total
      final moduleKey = 'module_$moduleOrder';
      final now = DateTime.now().toIso8601String();

      if (!doc.exists) {
        await userRef.set({
          'xp': xp,
          'level': level,
          'streak': streak,
          'modulesCompleted': fromModule ? 1 : 0,
          'totalModules': totalModules,
          'scenariosCompleted': scenariosCompleted,
          'totalScenarios': dynamicTotalScenarios,
          'modules': {
            moduleKey: {
              'completedScenarios': scenariosCompleted,
              'totalScenarios': totalScenarios,
            },
          },
          'lastUpdated': now,
        });
        debugPrint("🆕 Created Firestore progress for $userId");
        return;
      }

      final data = doc.data() ?? {};
      final currentXP = _asInt(data['xp']);
      final currentLevel = _asInt(data['level']);
      final currentStreak = _asInt(data['streak']);
      final currentModules = _asInt(data['modulesCompleted']);

      final modulesData =
          Map<String, dynamic>.from(data['modules'] ?? <String, dynamic>{});
      final moduleData =
          Map<String, dynamic>.from(modulesData[moduleKey] ?? <String, dynamic>{});

      final alreadyCompleted = _asInt(moduleData['completedScenarios']);
      final completedScenarios =
          alreadyCompleted > 0 ? alreadyCompleted : scenariosCompleted;

      modulesData[moduleKey] = {
        'completedScenarios': completedScenarios,
        'totalScenarios': totalScenarios,
      };

      int totalCompletedAcrossModules = 0;
      int totalScenariosAcrossModules = 0;

      for (final mod in modulesData.values) {
        final m = mod as Map<String, dynamic>;
        totalCompletedAcrossModules += _asInt(m['completedScenarios']);
        totalScenariosAcrossModules += _asInt(m['totalScenarios']);
      }

      int newXP = currentXP + xp;
      int newLevel = currentLevel;
      while (newXP >= 100) {
        newXP -= 100;
        newLevel++;
      }

      await userRef.update({
        'xp': newXP,
        'level': newLevel,
        'streak': currentStreak + 1,
        'modulesCompleted': fromModule
            ? (currentModules < totalModules
                ? currentModules + 1
                : currentModules)
            : currentModules,
        'scenariosCompleted': totalCompletedAcrossModules,
        'totalScenarios': dynamicTotalScenarios, // ✅ now auto-detected total
        'modules': modulesData,
        'totalModules': totalModules,
        'lastUpdated': now,
      });

      debugPrint("☁️ Updated Firestore progress for $userId (module $moduleOrder)");
    } catch (e) {
      debugPrint("⚠️ Firestore progress update failed for $userId: $e");
    }
  }

  Future<Map<String, dynamic>> calculateProgress(int userId) async {
    final db = await _dbHelper.database;

    final totalResult = await db.rawQuery('SELECT COUNT(*) as total FROM scenarios');
    final total = _asInt(totalResult.first['total']);

    final playedResult = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT scenario_id) as played
      FROM analytics_log
      WHERE user_id = ?
      ''',
      [userId],
    );
    final played = _asInt(playedResult.first['played']);

    final correctResult = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT scenario_id) as correct
      FROM analytics_log
      WHERE user_id = ? AND is_correct = 1
      ''',
      [userId],
    );
    final correct = _asInt(correctResult.first['correct']);

    final progressPercent = total > 0 ? ((played / total) * 100).toInt() : 0;
    final accuracyPercent = played > 0 ? ((correct / played) * 100).toInt() : 0;

    return {
      'completed': played,
      'total': total,
      'progressPercent': progressPercent,
      'accuracyPercent': accuracyPercent,
    };
  }

  Future<void> checkAndUnlockAchievements(
    String userId, {
    required int level,
    required int scenariosCompleted,
    required int correctAnswers,
    required Map<String, int> stats,
  }) async {
    try {
      final userRef = _firestore.collection('user_progress').doc(userId);
      final achievementsRef = userRef.collection('achievements');
      final existingSnapshot = await achievementsRef.get();
      final existingIds = existingSnapshot.docs.map((d) => d.id).toSet();

      final List<Map<String, String>> newAchievements = [];

      void addAchievement(String id, String name) {
        if (!existingIds.contains(id)) {
          newAchievements.add({'id': id, 'name': name});
        }
      }

      if (scenariosCompleted >= 5) addAchievement("milestone_5", "Cyber Cadet");
      if (scenariosCompleted >= 10) addAchievement("milestone_10", "Security Operative");
      if (scenariosCompleted >= 20) addAchievement("milestone_20", "Cyber Sentinel");
      if (scenariosCompleted >= 30) addAchievement("milestone_30", "Elite Defender");

      if (level >= 5) addAchievement("level_5", "Experienced Agent");
      if (level >= 10) addAchievement("level_10", "Cyber Commander");

      if (stats["Security"]! >= 90 &&
          stats["Awareness"]! >= 90 &&
          stats["Trust"]! >= 90) {
        addAchievement("perfect_run", "Master of CyberOps");
      }

      for (final a in newAchievements) {
        await achievementsRef.doc(a['id']).set({
          'name': a['name'],
          'achievedAt': DateTime.now().toIso8601String(),
        });
      }

      if (newAchievements.isNotEmpty) {
        debugPrint("🏆 New Firestore Achievements: $newAchievements");
      } else {
        debugPrint("ℹ️ No new achievements for $userId.");
      }
    } catch (e) {
      debugPrint("⚠️ Firestore achievements failed for $userId: $e");
    }
  }
}
