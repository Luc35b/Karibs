import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ExamResult {
  final int id;
  final double score;
  final DateTime date;

  ExamResult({required this.id, required this.score, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'date': date.toIso8601String(),
    };
  }

  factory ExamResult.fromMap(Map<String, dynamic> map) {
    return ExamResult(
      id: map['id'],
      score: map['score'],
      date: DateTime.parse(map['date']),
    );
  }
}


class Exam {
  int? id; // Unique identifier for each exam
  double currentScore; // Current score of the exam
  double highestScore; // Highest score achieved in the exam
  DateTime date; // Date of the exam

  Exam({
    this.id,
    required this.currentScore,
    required this.highestScore,
    required this.date,
  });

  // Convert Exam object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currentScore': currentScore,
      'highestScore': highestScore,
      'date': date.toIso8601String(), // Convert DateTime to ISO 8601 string for storage
    };
  }

  // Create Exam object from a Map
  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'],
      currentScore: map['currentScore'],
      highestScore: map['highestScore'],
      date: DateTime.parse(map['date']), // Parse ISO 8601 string back to DateTime
    );
  }
}


class ExamDatabaseHelper {
  static final ExamDatabaseHelper instance = ExamDatabaseHelper._privateConstructor();
  static Database? _database;

  ExamDatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'exams_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exams(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        grade TEXT,
        examName TEXT,
        currentScore REAL,
        highestScore REAL,
        date TEXT
      )
    ''');
  }

  Future<int> insertExam(Map<String, dynamic> exam) async {
    Database db = await instance.database;
    return await db.insert('exams', exam);
  }

  Future<List<Map<String, dynamic>>> getExamsByGrade(String grade) async {
    Database db = await instance.database;
    return await db.query('exams', where: 'grade = ?', whereArgs: [grade]);
  }

  Future<int> insertExamResult(ExamResult result) async {
    Database db = await instance.database;
    return await db.insert('exam_results', result.toMap());
  }
}