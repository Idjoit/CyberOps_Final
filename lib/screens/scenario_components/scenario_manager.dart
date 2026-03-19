import 'package:cyberops/models/scenario_model.dart';
import 'package:cyberops/database/db_helper.dart';
import 'package:cyberops/models/progress_model.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class ScenarioManager {
  final DBHelper dbHelper;
  List<Scenario> _scenarios = [];
  int _currentIndex = 0;

  ScenarioManager({required this.dbHelper});

  Future<List<Scenario>> loadScenarios() async {
    final db = await dbHelper.database;
    final result = await db.query('scenarios');
    return result.map((e) => Scenario.fromMap(e)).toList();
  }

  void setScenarios(List<Scenario> scenarios) {
    _scenarios = scenarios;
    _currentIndex = 0;
  }

  Scenario? get currentScenario =>
      _scenarios.isNotEmpty ? _scenarios[_currentIndex] : null;

  bool moveToNextScenario() {
    if (_currentIndex + 1 < _scenarios.length) {
      _currentIndex++;
      return true;
    }
    return false;
  }

  Map<String, int> getChoiceEffects(Scenario scenario, bool isChoiceA) {
    return {
      'security': isChoiceA
          ? scenario.effectASecurity
          : scenario.effectBSecurity,
      'awareness': isChoiceA
          ? scenario.effectAAwareness
          : scenario.effectBAwareness,
      'money': isChoiceA
          ? scenario.effectAMoney
          : scenario.effectBMoney,
      'trust': isChoiceA
          ? scenario.effectATrust
          : scenario.effectBTrust,
    };
  }

  Future<void> saveDecision({
    required int userId,
    required Scenario scenario,
    required bool isChoiceA,
  }) async {
    final db = await dbHelper.database;

    await db.insert('analytics_log', {
      'user_id': userId,
      'scenario_id': scenario.id,
      'decision': isChoiceA ? 'A' : 'B',
      'is_correct': (isChoiceA && scenario.correctChoice == "A") ||
              (!isChoiceA && scenario.correctChoice == "B")
          ? 1
          : 0,
      'time_spent': 10,
      'difficulty_level': scenario.difficulty,
      'delta_security': isChoiceA
          ? scenario.effectASecurity
          : scenario.effectBSecurity,
      'delta_awareness': isChoiceA
          ? scenario.effectAAwareness
          : scenario.effectBAwareness,
      'delta_money':
          isChoiceA ? scenario.effectAMoney : scenario.effectBMoney,
      'delta_trust':
          isChoiceA ? scenario.effectATrust : scenario.effectBTrust,
      'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    });
  }

  GameProgress buildProgress({
    required int userId,
    required int security,
    required int awareness,
    required int money,
    required int trust,
    required int scenarioId,
  }) {
    return GameProgress(
      userId: userId,
      currentScenario: scenarioId,
      securityScore: security,
      awarenessScore: awareness,
      moneyScore: money,
      trustScore: trust,
      xp: 0,
      level: 1,
      streak: 0,
      difficultyLevel: 1,
      timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );
  }
}
