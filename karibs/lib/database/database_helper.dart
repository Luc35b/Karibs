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
      version: 1,
      onCreate: _onCreate,
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
        class_id INTEGER NOT NULL,
        average_score FLOAT NOT NULL,
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
    return await db
        .query('students', where: 'class_id = ?', whereArgs: [classId]);
  }

  Future<List<Map<String, dynamic>>> queryAllReports(int studentId) async {
    Database db = await database;
    return await db
        .query('reports', where: 'student_id = ?', whereArgs: [studentId]);
  }

  Future<int> updateClass(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('classes', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateStudent(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('students', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateReport(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('reports', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteClass(int id) async {
    Database db = await database;
    return await db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteStudent(int id) async {
    Database db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteReport(int id) async {
    Database db = await database;
    return await db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }
}
