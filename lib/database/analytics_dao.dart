//THIS ISNT USED ANYMORE LMFAOO
import 'package:cyberops/database/db_helper.dart';

class AnalyticsDao {
  final DBHelper _dbHelper = DBHelper();

  /// 🔍 Global scenario stats
  Future<List<Map<String, dynamic>>> getScenarioStats() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT scenario_id,
             COUNT(*) AS attempts,
             SUM(is_correct) AS corrects,
             AVG(time_spent) AS avg_time
      FROM analytics_log
      GROUP BY scenario_id;
    ''');
  }

  /// 🔍 User-specific scenario stats
  Future<List<Map<String, dynamic>>> getUserScenarioStats(int userId) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT scenario_id,
             COUNT(*) AS attempts,
             SUM(is_correct) AS corrects,
             AVG(time_spent) AS avg_time
      FROM analytics_log
      WHERE user_id = ?
      GROUP BY scenario_id;
    ''', [userId]);
  }

  /// 📊 Total unique user sessions
  Future<int> getTotalSessions() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(DISTINCT user_id) as count FROM analytics_log');
    return result.first['count'] as int? ?? 0;
  }

  /// 🎯 Average accuracy across all logs
  Future<double> getAverageAccuracy() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT AVG(is_correct) as avg FROM analytics_log');
    return (result.first['avg'] as num?)?.toDouble() ?? 0.0;
  }
}
