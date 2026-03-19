class AchievementModel {
  final String id;
  final String name;

  AchievementModel({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
}
