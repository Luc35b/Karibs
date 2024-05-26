import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'school.db');
    return await openDatabase(
      path,
      version: 2, // Increment the version to trigger the upgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        status TEXT,
        class_id INTEGER NOT NULL,
        FOREIGN KEY (class_id) REFERENCES classes (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        notes TEXT,
        score INTEGER,
        student_id INTEGER NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE students ADD COLUMN status TEXT
      ''');
    }
  }

  Future<void> deleteDatabaseFile() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'school.db');
    File databaseFile = File(path);

    if (await databaseFile.exists()) {
      await databaseFile.delete();
      print('Database deleted');
    } else {
      print('Database file not found');
    }

    _database = null;
  }

  Future<int> insertClass(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('classes', row);
  }

  Future<int> insertStudent(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('students', row);
  }

  Future<int> insertReport(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('reports', row);
  }

  Future<List<Map<String, dynamic>>> queryAllClasses() async {
    Database db = await database;
    return await db.query('classes');
  }

  Future<List<Map<String, dynamic>>> queryAllStudents(int classId) async {
    Database db = await database;
    return await db.query('students', where: 'class_id = ?', whereArgs: [classId]);
  }

  Future<List<Map<String, dynamic>>> queryAllReports(int studentId) async {
    Database db = await database;
    return await db.query('reports', where: 'student_id = ?', whereArgs: [studentId]);
  }

  Future<Map<String, dynamic>?> queryStudent(int studentId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('students', where: 'id = ?', whereArgs: [studentId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<double?> queryAverageScore(int studentId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT AVG(score) as avg_score FROM reports WHERE student_id = ? AND score IS NOT NULL',
      [studentId],
    );
    if (result.isNotEmpty && result.first['avg_score'] != null) {
      return result.first['avg_score'];
    }
    return null;
  }
}
