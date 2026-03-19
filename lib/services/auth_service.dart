import 'package:cyberops/database/db_helper.dart';
import 'package:cyberops/models/user_model.dart';


class AuthService {
  final DBHelper _dbHelper = DBHelper();

  // Login method
  Future<UserModel?> login(String username, String password) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  // Registration method
  Future<void> register(String username, String password) async {
    final db = await _dbHelper.database;

    // Assign admin role automatically if username == "admin"
    String role = (username.toLowerCase() == 'admin') ? 'admin' : 'user';

    await db.insert('users', {
      'username': username,
      'password': password,
      'role': role,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    final db = await _dbHelper.database;
    final result = await db.query('users');
    return result.map((e) => UserModel.fromMap(e)).toList();
  }

  // Delete user
  Future<void> deleteUser(int id) async {
    final db = await _dbHelper.database;
    await db.delete('users', where: 'user_id = ?', whereArgs: [id]);
  }

  // Update password
  Future<void> updatePassword(int id, String newPassword) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'user_id = ?',
      whereArgs: [id],
    );
  }
}
