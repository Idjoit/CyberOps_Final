/// Scenario Model
/// ------------------------------------------------------------
/// Represents a decision-based scenario in the CyberOps game.
///
/// Each scenario:
/// - Presents a situation (title + description)
/// - Provides two choices (A and B)
/// - Applies different effects based on the chosen option
/// - Tracks correct decision and provides feedback
///
/// Used for:
/// - Scenario gameplay (Reigns-style decision system)
/// - Updating player stats (security, awareness, money, trust)
/// - Learning reinforcement via feedback text
class Scenario {

  /// Unique scenario ID (optional for database use)
  final int? id;

  /// Scenario title shown to the player
  final String title;

  /// Detailed description of the situation
  final String description;

  /// Choice A text
  final String choiceA;

  /// Choice B text
  final String choiceB;

  /// Effects of choosing A
  final int effectASecurity;
  final int effectAAwareness;
  final int effectAMoney;
  final int effectATrust;

  /// Effects of choosing B
  final int effectBSecurity;
  final int effectBAwareness;
  final int effectBMoney;
  final int effectBTrust;

  /// Correct choice identifier ("A" or "B")
  final String correctChoice;

  /// Feedback shown after making a decision
  final String feedbackText;

  /// Difficulty level (e.g., 1 = easy, 2 = medium, 3 = hard)
  final int difficulty;

  /// Scenario category (e.g., phishing, malware, social engineering)
  final String category;

  /// Optional image path for visual representation
  final String? imagePath;

  /// Constructor
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

  /// ------------------------------------------------------------
  /// Converts Scenario object into a Map
  /// Used for saving to database (SQLite / Firestore)
  /// ------------------------------------------------------------
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
      'image_path': imagePath,
    };
  }

  /// ------------------------------------------------------------
  /// Factory constructor to create Scenario from Map
  ///
  /// Supports both:
  /// - snake_case (database)
  /// - camelCase (Flutter/local objects)
  ///
  /// Provides default values to prevent crashes
  /// ------------------------------------------------------------
  factory Scenario.fromMap(Map<String, dynamic> map) {
    return Scenario(

      // Supports both 'scenario_id' and 'id'
      id: map['scenario_id'] ?? map['id'],

      title: map['title'] ?? 'Untitled Scenario',

      description:
          map['description'] ?? 'No description available.',

      // Supports both naming styles
      choiceA: map['choice_a'] ?? map['choiceA'] ?? 'Option A',
      choiceB: map['choice_b'] ?? map['choiceB'] ?? 'Option B',

      // Effects for choice A
      effectASecurity:
          map['effect_a_security'] ?? map['effectASecurity'] ?? 0,
      effectAAwareness:
          map['effect_a_awareness'] ?? map['effectAAwareness'] ?? 0,
      effectAMoney:
          map['effect_a_money'] ?? map['effectAMoney'] ?? 0,
      effectATrust:
          map['effect_a_trust'] ?? map['effectATrust'] ?? 0,

      // Effects for choice B
      effectBSecurity:
          map['effect_b_security'] ?? map['effectBSecurity'] ?? 0,
      effectBAwareness:
          map['effect_b_awareness'] ?? map['effectBAwareness'] ?? 0,
      effectBMoney:
          map['effect_b_money'] ?? map['effectBMoney'] ?? 0,
      effectBTrust:
          map['effect_b_trust'] ?? map['effectBTrust'] ?? 0,

      // Correct answer (defaults to A)
      correctChoice:
          map['correct_choice'] ?? map['correctChoice'] ?? 'A',

      // Feedback explanation
      feedbackText: map['feedback_text'] ??
          map['feedbackText'] ??
          'No feedback provided.',

      // Difficulty and category
      difficulty: map['difficulty'] ?? 1,
      category: map['category'] ?? 'General',

      // Optional image
      imagePath: map['image_path'] ?? map['imagePath'],
    );
  }
}
