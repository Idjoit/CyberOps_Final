import 'package:cyberops/database/db_helper.dart';

/// UserDao (Data Access Object)
/// ------------------------------------------------------------
/// Handles all database operations related to user accounts.
///
/// Responsibilities:
/// - Fetching users from database
/// - Retrieving specific user by username
/// - Inserting new users
/// - Deleting users
///
/// ⚠️ Note:
/// Passwords are stored as plain text here.
/// In production, always hash passwords before storing.
class UserDao {

  /// Instance of database helper
  final DBHelper _dbHelper = DBHelper();

  /// ------------------------------------------------------------
  /// Retrieves all users from the database
  ///
  /// - Ordered by user_id (ascending)
  /// - Returns raw Map data
  /// ------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await _dbHelper.database;

    return db.query(
      'users',
      orderBy: 'user_id ASC',
    );
  }

  /// ------------------------------------------------------------
  /// Retrieves a single user by username
  ///
  /// Parameters:
  /// - username: the username to search for
  ///
  /// Returns:
  /// - Map of user data if found
  /// - null if no user exists
  /// ------------------------------------------------------------
  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    // Return first match or null if empty
    return result.isNotEmpty ? result.first : null;
  }

  /// ------------------------------------------------------------
  /// Inserts a new user into the database
  ///
  /// Automatically adds:
  /// - created_at timestamp
  ///
  /// Returns:
  /// - ID of inserted row
  /// ------------------------------------------------------------
  Future<int> insertUser(String username, String password, String role) async {
    final db = await _dbHelper.database;

    return db.insert(
      'users',
      {
        'username': username,
        'password': password,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// ------------------------------------------------------------
  /// Deletes a user from the database
  ///
  /// Parameters:
  /// - id: user ID to delete
  ///
  /// Returns:
  /// - Number of rows deleted
  /// ------------------------------------------------------------
  Future<int> deleteUser(int id) async {
    final db = await _dbHelper.database;

    return db.delete(
      'users',
      where: 'user_id = ?',
      whereArgs: [id],
    );
  }
}
