import 'package:cloud_firestore/cloud_firestore.dart';

/// QuizQuestion Model
/// ------------------------------------------------------------
/// Represents a single quiz question used in the quiz gameplay.
///
/// This model is used for:
/// - Parsing question data from Firestore
/// - Rendering questions and choices in the UI
/// - Validating correct answers during gameplay
class QuizQuestion {

  /// The main question text shown to the player
  final String question;

  /// List of possible answer choices
  final List<String> options;

  /// Index of the correct answer in the options list
  final int correctAnswerIndex;

  /// Explanation shown after answering (learning feedback)
  final String explanation;

  /// Difficulty level of the question (e.g., 1 = easy, 2 = medium, 3 = hard)
  final int difficulty;

  /// Constructor
  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.difficulty,
  });

  /// ------------------------------------------------------------
  /// Factory constructor to create a QuizQuestion from Firestore
  ///
  /// Expected Firestore structure:
  /// {
  ///   "question": String,
  ///   "options": List<String>,
  ///   "correctAnswerIndex": int,
  ///   "explanation": String,
  ///   "difficulty": int
  /// }
  /// ------------------------------------------------------------
  factory QuizQuestion.fromFirestore(DocumentSnapshot doc) {

    // Extract raw data from Firestore document
    final data = doc.data() as Map<String, dynamic>;

    return QuizQuestion(
      question: data['question'] ?? '',

      // Convert dynamic list into strongly typed List<String>
      options: List<String>.from(data['options'] ?? []),

      // Default to first option if missing
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,

      // Explanation used for feedback after answering
      explanation: data['explanation'] ?? '',

      // Default difficulty is 1 (easy)
      difficulty: data['difficulty'] ?? 1,
    );
  }
}
