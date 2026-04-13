/// UserAchievementModel
/// ------------------------------------------------------------
/// Represents an achievement unlocked by a user.
///
/// This model is used for:
/// - Tracking user achievements in the system
/// - Storing achievement data in database (SQLite / Firestore)
/// - Displaying unlocked achievements in UI
class UserAchievementModel {

  /// Unique ID for the achievement record (optional, for local DB)
  final int? id;

  /// ID of the user who unlocked the achievement
  final int userId;

  /// Unique identifier of the achievement (e.g., "first_win", "quiz_master")
  final String achievementId;

  /// Human-readable name of the achievement
  final String name;

  /// Timestamp when the achievement was unlocked
  final String achievedAt;

  /// Constructor
  UserAchievementModel({
    this.id,
    required this.userId,
    required this.achievementId,
    required this.name,
    required this.achievedAt,
  });

  /// ------------------------------------------------------------
  /// Converts UserAchievementModel into a Map
  /// Used for saving data into database
  /// ------------------------------------------------------------
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'achievement_id': achievementId,
        'name': name,
        'achieved_at': achievedAt,
      };

  /// ------------------------------------------------------------
  /// Factory constructor to create UserAchievementModel from Map
  /// Used when retrieving data from database
  /// ------------------------------------------------------------
  factory UserAchievementModel.fromMap(Map<String, dynamic> map) =>
      UserAchievementModel(

        // Optional ID (may be null if not stored locally)
        id: map['id'],

        // User reference
        userId: map['user_id'],

        // Achievement identifiers
        achievementId: map['achievement_id'],
        name: map['name'],

        // Timestamp of achievement unlock
        achievedAt: map['achieved_at'],
      );
}
