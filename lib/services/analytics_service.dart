import 'package:cyberops/database/analytics_dao.dart';

class AnalyticsService {
  final AnalyticsDao _dao = AnalyticsDao();

  /// 🧮 Returns a map of analytics for a given user
  Future<Map<String, dynamic>> getUserAnalytics(int userId) async {
    final totalSessions = await _dao.getTotalSessions();
    final avgAccuracy = await _dao.getAverageAccuracy();
    final scenarioStats = await _dao.getScenarioStats();

    // Filter scenario stats for this user
    final userScenarios = scenarioStats.where((s) => s['user_id'] == userId).toList();

    return {
      'totalSessions': totalSessions,
      'averageAccuracy': avgAccuracy,
      'scenarios': userScenarios,
    };
  }

  /// 📊 Returns global analytics across all users
  Future<Map<String, dynamic>> getGlobalAnalytics() async {
    final totalSessions = await _dao.getTotalSessions();
    final avgAccuracy = await _dao.getAverageAccuracy();
    final scenarioStats = await _dao.getScenarioStats();

    return {
      'totalSessions': totalSessions,
      'averageAccuracy': avgAccuracy,
      'scenarios': scenarioStats,
    };
  }
}
