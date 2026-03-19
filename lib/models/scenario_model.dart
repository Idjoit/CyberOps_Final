class Scenario {
  final int? id;
  final String title;
  final String description;
  final String choiceA;
  final String choiceB;
  final int effectASecurity;
  final int effectAAwareness;
  final int effectAMoney;
  final int effectATrust;
  final int effectBSecurity;
  final int effectBAwareness;
  final int effectBMoney;
  final int effectBTrust;
  final String correctChoice;
  final String feedbackText;
  final int difficulty;
  final String category;
  final String? imagePath;

  Scenario({
    this.id,
    required this.title,
    required this.description,
    required this.choiceA,
    required this.choiceB,
    required this.effectASecurity,
    required this.effectAAwareness,
    required this.effectAMoney,
    required this.effectATrust,
    required this.effectBSecurity,
    required this.effectBAwareness,
    required this.effectBMoney,
    required this.effectBTrust,
    required this.correctChoice,
    required this.feedbackText,
    required this.difficulty,
    required this.category,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'scenario_id': id,
      'title': title,
      'description': description,
      'choice_a': choiceA,
      'choice_b': choiceB,
      'effect_a_security': effectASecurity,
      'effect_a_awareness': effectAAwareness,
      'effect_a_money': effectAMoney,
      'effect_a_trust': effectATrust,
      'effect_b_security': effectBSecurity,
      'effect_b_awareness': effectBAwareness,
      'effect_b_money': effectBMoney,
      'effect_b_trust': effectBTrust,
      'correct_choice': correctChoice,
      'feedback_text': feedbackText,
      'difficulty': difficulty,
      'category': category,
      'image_path': imagePath
    };
  }

factory Scenario.fromMap(Map<String, dynamic> map) {
  return Scenario(
    id: map['scenario_id'] ?? map['id'],
    title: map['title'] ?? 'Untitled Scenario',
    description: map['description'] ?? 'No description available.',
    choiceA: map['choice_a'] ?? map['choiceA'] ?? 'Option A',
    choiceB: map['choice_b'] ?? map['choiceB'] ?? 'Option B',
    effectASecurity: map['effect_a_security'] ?? map['effectASecurity'] ?? 0,
    effectAAwareness: map['effect_a_awareness'] ?? map['effectAAwareness'] ?? 0,
    effectAMoney: map['effect_a_money'] ?? map['effectAMoney'] ?? 0,
    effectATrust: map['effect_a_trust'] ?? map['effectATrust'] ?? 0,
    effectBSecurity: map['effect_b_security'] ?? map['effectBSecurity'] ?? 0,
    effectBAwareness: map['effect_b_awareness'] ?? map['effectBAwareness'] ?? 0,
    effectBMoney: map['effect_b_money'] ?? map['effectBMoney'] ?? 0,
    effectBTrust: map['effect_b_trust'] ?? map['effectBTrust'] ?? 0,
    correctChoice: map['correct_choice'] ?? map['correctChoice'] ?? 'A',
    feedbackText: map['feedback_text'] ?? map['feedbackText'] ?? 'No feedback provided.',
    difficulty: map['difficulty'] ?? 1,
    category: map['category'] ?? 'General',
    imagePath: map['image_path'] ?? map['imagePath'],
  );
}

}
