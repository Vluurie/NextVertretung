import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:next_cloud_plans/model/substitution_plan.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('substitution.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS plans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  hour TEXT NOT NULL,
  action TEXT NOT NULL,
  teacher TEXT NOT NULL,
  className TEXT NOT NULL,
  hash TEXT
)
  ''');
    await db.execute('''
    CREATE UNIQUE INDEX idx_uniqueness ON plans (className, date, hour, action, teacher);
  ''');
  }

  Future<void> clearAllPlans() async {
    final db = await instance.database;
    await db.delete('plans');
    debugPrint('All plans have been deleted from the database.');
  }

  Future<void> insertOrUpdatePlan(String date,
      List<SubstitutionPlanItem> newPlans, String className) async {
    final db = await database;

    await db.transaction((txn) async {
      // Fetch all current plans for the specific date and class to compare
      List<Map<String, dynamic>> currentPlans = await txn.query('plans',
          where: 'date = ? AND className = ?', whereArgs: [date, className]);

      // Convert current plans to a map keyed by a composite of identifiers
      Map<String, Map<String, dynamic>> currentPlansMap = {
        for (var plan in currentPlans)
          '${plan['hour']}-${plan['action']}-${plan['teacher']}-${plan['className']}':
              plan
      };

      for (var newPlan in newPlans) {
        var jsonData = newPlan.toJson();
        jsonData['date'] = date;
        jsonData['className'] = className;

        String key =
            '${newPlan.hour}-${newPlan.action}-${newPlan.teacher}-$className';
        var existingPlan = currentPlansMap[key];

        // Log the decision process
        debugPrint('Checking plan: $key');

        if (existingPlan != null) {
          // If hashes are different, update the existing plan
          if (existingPlan['hash'] != newPlan.generateHash()) {
            int updateCount = await txn.update('plans', jsonData,
                where: 'id = ?', whereArgs: [existingPlan['id']]);
            debugPrint('Updated $updateCount existing plan(s): $jsonData');
          } else {
            debugPrint('No update needed for plan: $jsonData');
          }
        } else {
          // If plan does not exist, insert it
          int newId = await txn.insert('plans', jsonData);
          debugPrint('Inserted new plan with ID $newId: $jsonData');
        }
      }

      // Confirm changes by fetching the updated data
      List<Map<String, dynamic>> updatedRows = await txn.query('plans',
          where: 'date = ? AND className = ?', whereArgs: [date, className]);
      debugPrint(
          'Post-operation state for date $date and class $className: ${updatedRows.map((row) => row.toString()).join(", ")}');
    });
    debugPrint('Database transaction completed.');
  }

// Helper method to fetch all plans within a transaction
  Future<List<SubstitutionPlanItem>> fetchAllPlansTxn(Transaction txn) async {
    final maps = await txn.query('plans',
        columns: ['className', 'hour', 'action', 'teacher', 'date']);
    return maps.isNotEmpty
        ? maps.map((map) => SubstitutionPlanItem.fromJson(map)).toList()
        : [];
  }

  Future<List<SubstitutionPlanItem>> fetchPlansByDate(
      String date, String className) async {
    final db = await instance.database;
    final maps = await db.query('plans',
        columns: ['hour', 'action', 'teacher', 'className'],
        where: 'date = ? AND className = ?',
        whereArgs: [date, className]);

    return maps.isNotEmpty
        ? maps.map((map) => SubstitutionPlanItem.fromJson(map)).toList()
        : [];
  }

  Future<bool> compareFetchedData(String date,
      List<SubstitutionPlanItem> newPlans, String className) async {
    final List<SubstitutionPlanItem> oldPlans =
        await fetchPlansByDate(date, className);

    if (oldPlans.length != newPlans.length) {
      debugPrint(
          'Mismatch in plan counts: Old count ${oldPlans.length}, New count ${newPlans.length}');
      return false;
    }

    for (int i = 0; i < oldPlans.length; i++) {
      if (oldPlans[i].hour != newPlans[i].hour ||
          oldPlans[i].action != newPlans[i].action ||
          oldPlans[i].teacher != newPlans[i].teacher) {
        debugPrint('Difference detected: ');
        debugPrint(
            'Old Plan: ${oldPlans[i].hour}, ${oldPlans[i].action}, ${oldPlans[i].teacher}');
        debugPrint(
            'New Plan: ${newPlans[i].hour}, ${newPlans[i].action}, ${newPlans[i].teacher}');
        return false;
      }
    }

    debugPrint('No differences found for date $date.');
    return true;
  }

  Future<List<SubstitutionPlanItem>> fetchPastPlans() async {
    final db = await instance.database;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final maps =
        await db.query('plans', where: 'date <= ?', whereArgs: [today]);

    if (maps.isNotEmpty) {
      return maps.map((map) => SubstitutionPlanItem.fromJson(map)).toList();
    }
    return [];
  }

  Future<List<String>> fetchUniqueDates() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('plans',
        columns: ['distinct date'], orderBy: 'date DESC');
    return result.map((map) => map['date'] as String).toList();
  }

  Future<List<SubstitutionPlanItem>> fetchPlansFromLastTwoWeeks() async {
    final db = await instance.database;
    String twoWeeksAgo = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 14)));
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final maps = await db.query('plans',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [twoWeeksAgo, today],
        orderBy: 'date DESC');

    if (maps.isNotEmpty) {
      return maps.map((map) => SubstitutionPlanItem.fromJson(map)).toList();
    }
    return [];
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
