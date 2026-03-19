import 'package:cyberops/database/db_helper.dart';


class UserDao {
  final DBHelper _dbHelper = DBHelper();

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await _dbHelper.database;
    return db.query('users', orderBy: 'user_id ASC');
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await _dbHelper.database;
    final result = await db.query('users', where: 'username = ?', whereArgs: [username]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertUser(String username, String password, String role) async {
    final db = await _dbHelper.database;
    return db.insert('users', {
      'username': username,
      'password': password,
      'role': role,
      'created_at': DateTime.now().toIso8601String()
    });
  }

  Future<int> deleteUser(int id) async {
    final db = await _dbHelper.database;
    return db.delete('users', where: 'user_id = ?', whereArgs: [id]);
  }
}
