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
        average_score DOUBLE,
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
    await db.execute('''
      CREATE TABLE tests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        test_id INTEGER NOT NULL,
        FOREIGN KEY (test_id) REFERENCES tests (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE question_choices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL,
        choice_text TEXT NOT NULL,
        is_correct BOOLEAN NOT NULL,
        FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE student_tests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        test_id INTEGER NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (test_id) REFERENCES tests (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE tests (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE questions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          text TEXT NOT NULL,
          type TEXT NOT NULL,
          answer TEXT,
          category TEXT NOT NULL,
          test_id INTEGER NOT NULL,
          FOREIGN KEY (test_id) REFERENCES tests (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE question_choices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          question_id INTEGER NOT NULL,
          choice_text TEXT NOT NULL,
          is_correct BOOLEAN NOT NULL,
          FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE student_tests (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          student_id INTEGER NOT NULL,
          test_id INTEGER NOT NULL,
          FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
          FOREIGN KEY (test_id) REFERENCES tests (id) ON DELETE CASCADE
        )
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

  Future<int> insertTest(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('tests', row);
  }

  Future<int> insertQuestion(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('questions', row);
  }

  Future<int> insertQuestionChoice(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('question_choices', row);
  }

  Future<int> insertStudentTest(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('student_tests', row);
  }

  Future<int> updateStudentStatus(int studentId, String newStatus) async {
    Database db = await database;
    return await db.update(
      'students',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [studentId],
    );
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

  Future<int> deleteTest(int id) async {
    Database db = await database;
    return await db.delete('tests', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteQuestion(int id) async {
    Database db = await database;
    return await db.delete('questions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteQuestionChoices(int questionId) async {
    Database db = await database;
    return await db.delete('question_choices', where: 'question_id = ?', whereArgs: [questionId]);
  }

  Future<int> deleteStudentTests(int studentId) async {
    Database db = await database;
    return await db.delete('student_tests', where: 'student_id = ?', whereArgs: [studentId]);
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

  Future<List<Map<String, dynamic>>> queryAllTests() async {
    Database db = await database;
    return await db.query('tests');
  }

  Future<List<Map<String, dynamic>>> queryAllQuestions(int testId) async {
    Database db = await database;
    return await db.query('questions', where: 'test_id = ?', whereArgs: [testId]);
  }

  Future<List<Map<String, dynamic>>> queryAllQuestionChoices(int questionId) async {
    Database db = await database;
    return await db.query('question_choices', where: 'question_id = ?', whereArgs: [questionId]);
  }

  Future<Map<String, dynamic>?> queryQuestion(int questionId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'questions',
      where: 'id = ?',
      whereArgs: [questionId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<double?> queryAverageScore(int studentId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT AVG(score) as avg_score FROM reports WHERE student_id = ? AND score IS NOT NULL',
      [studentId],
    );
    if (result.isNotEmpty && result.first['avg_score'] != null) {
      double avgScore = result.first['avg_score'];
      await db.update(
        'students',
        {'average_score': avgScore},
        where: 'id = ?',
        whereArgs: [studentId],
      );
      return avgScore;
    }
    return null;
  }
}
