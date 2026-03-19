class UserAchievementModel {
  final int? id;
  final int userId;
  final String achievementId;
  final String name;
  final String achievedAt;

  UserAchievementModel({
    this.id,
    required this.userId,
    required this.achievementId,
    required this.name,
    required this.achievedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'achievement_id': achievementId,
        'name': name,
        'achieved_at': achievedAt,
      };

  factory UserAchievementModel.fromMap(Map<String, dynamic> map) =>
      UserAchievementModel(
        id: map['id'],
        userId: map['user_id'],
        achievementId: map['achievement_id'],
        name: map['name'],
        achievedAt: map['achieved_at'],
      );
}
