/// AchievementModel
/// ------------------------------------------------------------
/// Represents a predefined achievement in the system.
///
/// This model defines:
/// - The achievement identifier
/// - The display name shown to users
///
/// Used for:
/// - Defining available achievements in the game
/// - Mapping achievements to users (via UserAchievementModel)
/// - Displaying achievement lists in UI
class AchievementModel {

  /// Unique identifier for the achievement
  /// (e.g., "first_win", "quiz_master", "security_expert")
  final String id;

  /// Human-readable name of the achievement
  final String name;

  /// Constructor
  AchievementModel({
    required this.id,
    required this.name,
  });

  /// ------------------------------------------------------------
  /// Converts AchievementModel into a Map
  /// Used for saving or transferring achievement data
  /// ------------------------------------------------------------
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
      };
}
