import 'package:cyberops/database/db_helper.dart';
import 'package:cyberops/models/scenario_model.dart';

/// ScenarioDao (Data Access Object)
/// ------------------------------------------------------------
/// Handles all database operations related to Scenario objects.
///
/// Responsibilities:
/// - Fetching scenarios from local database
/// - Inserting new scenarios
/// - Updating existing scenarios
/// - Deleting scenarios
///
/// Uses:
/// - DBHelper for database connection
/// - Scenario model for data mapping
class ScenarioDao {

  /// Instance of database helper
  final DBHelper _dbHelper = DBHelper();

  /// ------------------------------------------------------------
  /// Retrieves all scenarios from the database
  ///
  /// - Ordered by difficulty (ascending)
  /// - Converts raw database maps into Scenario objects
  /// ------------------------------------------------------------
  Future<List<Scenario>> getAllScenarios() async {
    final db = await _dbHelper.database;

    // Query all rows from 'scenarios' table
    final result = await db.query(
      'scenarios',
      orderBy: 'difficulty ASC',
    );

    // Convert List<Map> to List<Scenario>
    return result.map((e) => Scenario.fromMap(e)).toList();
  }

  /// ------------------------------------------------------------
  /// Inserts a new scenario into the database
  ///
  /// Returns:
  /// - The ID of the inserted row
  /// ------------------------------------------------------------
  Future<int> insertScenario(Scenario scenario) async {
    final db = await _dbHelper.database;

    return db.insert(
      'scenarios',
      scenario.toMap(),
    );
  }

  /// ------------------------------------------------------------
  /// Updates an existing scenario
  ///
  /// - Matches scenario using scenario_id
  /// - Updates all fields from the model
  ///
  /// Returns:
  /// - Number of rows affected
  /// ------------------------------------------------------------
  Future<int> updateScenario(Scenario scenario) async {
    final db = await _dbHelper.database;

    return db.update(
      'scenarios',
      scenario.toMap(),
      where: 'scenario_id = ?',
      whereArgs: [scenario.id],
    );
  }

  /// ------------------------------------------------------------
  /// Deletes a scenario from the database
  ///
  /// Parameters:
  /// - id: scenario ID to delete
  ///
  /// Returns:
  /// - Number of rows deleted
  /// ------------------------------------------------------------
  Future<int> deleteScenario(int id) async {
    final db = await _dbHelper.database;

    return db.delete(
      'scenarios',
      where: 'scenario_id = ?',
      whereArgs: [id],
    );
  }
}
