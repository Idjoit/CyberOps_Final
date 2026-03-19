class GameProgress {
  final int userId;
  final int currentScenario;
  final int securityScore;
  final int awarenessScore;
  final int moneyScore;
  final int trustScore;
  int xp;
  int level;
  int streak;
  final int difficultyLevel;
  final String timestamp; 

  GameProgress({
    required this.userId,
    required this.currentScenario,
    required this.securityScore,
    required this.awarenessScore,
    required this.moneyScore,
    required this.trustScore,
    required this.xp,
    required this.level,
    required this.streak,
    required this.difficultyLevel,
    required this.timestamp, 
  });

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'current_scenario': currentScenario,
        'security_score': securityScore,
        'awareness_score': awarenessScore,
        'money_score': moneyScore,
        'trust_score': trustScore,
        'xp': xp,
        'level': level,
        'streak': streak,
        'difficulty_level': difficultyLevel,
        'timestamp': timestamp, 
      };

  factory GameProgress.fromMap(Map<String, dynamic> map) => GameProgress(
        userId: map['user_id'],
        currentScenario: map['current_scenario'],
        securityScore: map['security_score'],
        awarenessScore: map['awareness_score'],
        moneyScore: map['money_score'],
        trustScore: map['trust_score'],
        xp: map['xp'],
        level: map['level'],
        streak: map['streak'],
        difficultyLevel: map['difficulty_level'],
        timestamp: map['timestamp'], 
      );
}
