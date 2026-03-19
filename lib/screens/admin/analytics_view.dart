import 'package:flutter/material.dart';
import 'package:cyberops/database/db_helper.dart';

class AnalyticsViewScreen extends StatefulWidget {
  const AnalyticsViewScreen({super.key});

  @override
  State<AnalyticsViewScreen> createState() => _AnalyticsViewScreenState();
}

class _AnalyticsViewScreenState extends State<AnalyticsViewScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _analytics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT scenario_id,
             COUNT(*) AS attempts,
             SUM(is_correct) AS corrects,
             AVG(time_spent) AS avg_time
      FROM analytics_log
      GROUP BY scenario_id
      ORDER BY scenario_id;
    ''');

    setState(() {
      _analytics = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Training Analytics"),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: _analytics.isEmpty
          ? const Center(child: Text("No analytics data available yet."))
          : ListView.builder(
              itemCount: _analytics.length,
              itemBuilder: (context, index) {
                final a = _analytics[index];
                final rate = (a['corrects'] / a['attempts'] * 100).toStringAsFixed(1);
                return Card(
                  child: ListTile(
                    title: Text("Scenario ID: ${a['scenario_id']}"),
                    subtitle: Text("Attempts: ${a['attempts']} | Accuracy: $rate% | Avg Time: ${a['avg_time']}s"),
                  ),
                );
              },
            ),
    );
  }
}
