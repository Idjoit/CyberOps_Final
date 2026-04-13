/// GameProgress Model
/// ------------------------------------------------------------
/// Represents the player's progress and performance in the game.
///
/// This model is used for:
/// - Tracking player stats (scores, XP, level, streak)
/// - Saving progress to database (Firestore / SQLite)
/// - Loading progress back into the app
class GameProgress {

  /// Unique user identifier
  final int userId;

  /// Current scenario or stage the player is in
  final int currentScenario;

  /// Player's security decision score
  final int securityScore;

  /// Player's awareness level score
  final int awarenessScore;

  /// Player's financial/resource score
  final int moneyScore;

  /// Player's trust/reputation score
  final int trustScore;

  /// Experience points gained by the player
  int xp;

  /// Current player level
  int level;

  /// Current streak (consecutive successful scenarios)
  int streak;

  /// Difficulty level of the current gameplay
  final int difficultyLevel;

  /// Timestamp of last progress update (stored as String)
  final String timestamp;

  /// Constructor
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

  /// ------------------------------------------------------------
  /// Converts GameProgress object into a Map
  /// Used for saving data into database (Firestore / SQLite)
  /// ------------------------------------------------------------
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

  /// ------------------------------------------------------------
  /// Factory constructor to create GameProgress from a Map
  /// Used when retrieving data from database
  /// ------------------------------------------------------------
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
