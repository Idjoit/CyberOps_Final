/// UserModel
/// ------------------------------------------------------------
/// Represents a user in the system.
///
/// This model is used for:
/// - Storing user account information
/// - Managing roles (e.g., admin, user)
/// - Saving and retrieving user data from database (SQLite / Firestore)
///
/// ⚠️ Note:
/// Storing plain text passwords is NOT recommended for production.
/// Always hash passwords when handling real applications.
class UserModel {

  /// Unique user ID (optional for local database)
  final int? id;

  /// Username chosen by the user
  final String username;

  /// User password (should be hashed in production)
  final String password;

  /// Role of the user (e.g., "admin", "user")
  final String role;

  /// Timestamp of when the account was created
  final String createdAt;

  /// Constructor
  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  /// ------------------------------------------------------------
  /// Converts UserModel into a Map
  /// Used for saving user data into database
  /// ------------------------------------------------------------
  Map<String, dynamic> toMap() => {
        'user_id': id,
        'username': username,
        'password': password,
        'role': role,
        'created_at': createdAt,
      };

  /// ------------------------------------------------------------
  /// Factory constructor to create UserModel from Map
  /// Used when retrieving user data from database
  /// ------------------------------------------------------------
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(

        // Optional ID (may be null if not yet stored)
        id: map['user_id'],

        // User credentials and role
        username: map['username'],
        password: map['password'],
        role: map['role'],

        // Account creation timestamp
        createdAt: map['created_at'],
      );
}
