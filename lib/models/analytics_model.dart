class AnalyticsLog {
  final int? id;
  final int userId;
  final int scenarioId;
  final String decision;
  final bool isCorrect;
  final int timeSpent;
  final int difficultyLevel;
  final int deltaSecurity;
  final int deltaAwareness;
  final int deltaMoney;
  final int deltaTrust;
  final String timestamp;

  AnalyticsLog({
    this.id,
    required this.userId,
    required this.scenarioId,
    required this.decision,
    required this.isCorrect,
    required this.timeSpent,
    required this.difficultyLevel,
    required this.deltaSecurity,
    required this.deltaAwareness,
    required this.deltaMoney,
    required this.deltaTrust,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'log_id': id,
        'user_id': userId,
        'scenario_id': scenarioId,
        'decision': decision,
        'is_correct': isCorrect ? 1 : 0,
        'time_spent': timeSpent,
        'difficulty_level': difficultyLevel,
        'delta_security': deltaSecurity,
        'delta_awareness': deltaAwareness,
        'delta_money': deltaMoney,
        'delta_trust': deltaTrust,
        'timestamp': timestamp,
      };

  factory AnalyticsLog.fromMap(Map<String, dynamic> map) => AnalyticsLog(
        id: map['log_id'],
        userId: map['user_id'],
        scenarioId: map['scenario_id'],
        decision: map['decision'],
        isCorrect: map['is_correct'] == 1,
        timeSpent: map['time_spent'],
        difficultyLevel: map['difficulty_level'],
        deltaSecurity: map['delta_security'],
        deltaAwareness: map['delta_awareness'],
        deltaMoney: map['delta_money'],
        deltaTrust: map['delta_trust'],
        timestamp: map['timestamp'],
      );
}
