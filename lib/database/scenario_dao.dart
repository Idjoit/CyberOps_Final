import 'package:cyberops/database/db_helper.dart';
import 'package:cyberops/models/scenario_model.dart';

class ScenarioDao {
  final DBHelper _dbHelper = DBHelper();

  Future<List<Scenario>> getAllScenarios() async {
    final db = await _dbHelper.database;
    final result = await db.query('scenarios', orderBy: 'difficulty ASC');
    return result.map((e) => Scenario.fromMap(e)).toList();
  }

  Future<int> insertScenario(Scenario scenario) async {
    final db = await _dbHelper.database;
    return db.insert('scenarios', scenario.toMap());
  }

  Future<int> updateScenario(Scenario scenario) async {
    final db = await _dbHelper.database;
    return db.update('scenarios', scenario.toMap(),
        where: 'scenario_id = ?', whereArgs: [scenario.id]);
  }

  Future<int> deleteScenario(int id) async {
    final db = await _dbHelper.database;
    return db.delete('scenarios', where: 'scenario_id = ?', whereArgs: [id]);
  }
}
