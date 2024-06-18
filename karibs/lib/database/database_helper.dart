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
      readOnly: false,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE classes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      subject_id INTEGER NOT NULL,
      FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
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
    CREATE TABLE subjects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');
    await db.execute('''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      subject_id INTEGER NOT NULL,
      FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
    )
  ''');
    await db.execute('''
    CREATE TABLE reports (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      title TEXT NOT NULL,
      notes TEXT,
      score DOUBLE,
      test_id INTEGER,
      student_id INTEGER NOT NULL,
      FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
      FOREIGN KEY (test_id) REFERENCES tests (id) ON DELETE CASCADE
    )
  ''');
    await db.execute('''
    CREATE TABLE tests (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      "order" INTEGER,
      subject_id INTEGER NOT NULL,
      FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      
    )
  ''');
    await db.execute('''
    CREATE TABLE questions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      text TEXT NOT NULL,
      type TEXT NOT NULL,
      category_id INTEGER NOT NULL,
      test_id INTEGER NOT NULL,
      "order" INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE,
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
      total_score DOUBLE,
      FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
      FOREIGN KEY (test_id) REFERENCES tests (id) ON DELETE CASCADE
    )
  ''');
    await db.execute('''
    CREATE TABLE student_test_question (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_test_id INTEGER NOT NULL, 
      question_id INTEGER NOT NULL,
      got_correct INTEGER NOT NULL,
      FOREIGN KEY (student_test_id) REFERENCES student_tests (id) ON DELETE CASCADE,
      FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE
    )
  ''');
    await db.execute('''
    CREATE TABLE student_test_category_scores (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_test_id INTEGER NOT NULL,
      category_id INTEGER NOT NULL,
      score DOUBLE,
      FOREIGN KEY (student_test_id) REFERENCES student_tests (id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
    )
  ''');
  }


  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
      await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        subject_id INTEGER NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');
      await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        type TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        test_id INTEGER NOT NULL,
        "order" INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE,
        FOREIGN KEY (test_id) REFERENCES tests (id) ON DELETE CASCADE
      )
    ''');
      await db.execute('''
      CREATE TABLE student_test_category_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_test_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        score DOUBLE,
        FOREIGN KEY (student_test_id) REFERENCES student_tests (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
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

  Future<int> insertStudentTestQuestion(Map<String,dynamic> row) async {
    Database db = await database;
    return await db.insert('student_test_question', row);
  }

  Future<int> insertSubject(Map<String, dynamic> subject) async {
    final db = await database;
    return await db.insert('subjects', subject);
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category);
  }

  Future<int> insertStudentTestCategoryScore(Map<String, dynamic> score) async {
    final db = await database;
    return await db.insert('student_test_category_scores', score);
  }

  // Function to get the category name from a question ID
  Future<String?> getCategoryNameFromQuestion(int questionId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT c.name FROM categories c
      INNER JOIN questions q ON c.id = q.category_id
      WHERE q.id = ?
    ''', [questionId]);

    if (result.isNotEmpty) {
      return result.first['name'] as String?;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> queryAllSubjects() async {
    final db = await database;
    return await db.query('subjects');
  }

  Future<List<Map<String, dynamic>>> getCategoriesForSubject(int subjectId) async {
    final db = await database;
    return await db.query(
      'categories',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );
  }

  Future<List<Map<String, dynamic>>> getQuestionsForTest(int testId) async {
    final db = await database;
    return await db.query(
      'questions',
      where: 'test_id = ?',
      whereArgs: [testId],
    );
  }

  Future<List<Map<String, dynamic>>> getStudentTestCategoryScores(int studentTestId) async {
    final db = await database;
    return await db.query(
      'student_test_category_scores',
      where: 'student_test_id = ?',
      whereArgs: [studentTestId],
    );
  }


  Future<List<Map<String, dynamic>>> getQuestionsForStudentTest(int studentId, int testId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT questions.id as question_id, questions.text as question_text, questions.type as question_type, questions.category as question_category, questions.test_id, student_test_question.got_correct
      FROM questions
      INNER JOIN student_test_question ON questions.id = student_test_question.question_id
      INNER JOIN student_tests ON student_tests.id = student_test_question.student_test_id
      WHERE student_tests.student_id = ? AND student_tests.test_id = ?
    ''', [studentId, testId]);

    return result;
  }

  Future<Map<String, dynamic>> getQuestionsAndAnswersForReport(int reportId) async {
    final db = await database;

    // Fetch questions and whether the student got them correct
    final List<Map<String, dynamic>> questionsResult = await db.rawQuery('''
      SELECT 
        questions.id AS question_id, 
        questions.text AS question_text, 
        questions.type AS question_type, 
        questions.category AS question_category, 
        questions.test_id, 
        student_test_question.got_correct
      FROM reports
      INNER JOIN student_tests ON reports.student_id = student_tests.student_id AND reports.test_id = student_tests.test_id
      INNER JOIN student_test_question ON student_tests.id = student_test_question.student_test_id
      INNER JOIN questions ON student_test_question.question_id = questions.id
      WHERE reports.id = ?
    ''', [reportId]);

    // Fetch choices for the questions
    final List<Map<String, dynamic>> choicesResult = await db.rawQuery('''
      SELECT 
        question_choices.question_id AS question_id, 
        question_choices.id AS choice_id, 
        question_choices.choice_text, 
        question_choices.is_correct
      FROM question_choices
      INNER JOIN questions ON question_choices.question_id = questions.id
      INNER JOIN student_test_question ON questions.id = student_test_question.question_id
      INNER JOIN student_tests ON student_test_question.student_test_id = student_tests.id
      INNER JOIN reports ON student_tests.student_id = reports.student_id AND student_tests.test_id = reports.test_id
      WHERE reports.id = ?
    ''', [reportId]);

    return {
      'questions': questionsResult,
      'choices': choicesResult,
    };
  }

  Future<int?> getStudentTestId(int studentId, int testId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'student_tests',
      columns: ['id'],
      where: 'student_id = ? AND test_id = ?',
      whereArgs: [studentId, testId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int?;
    } else {
      return null;
    }
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

  Future<int> updateStudentName(int studentId, String newName) async{
    Database db = await database;
    return await db.update(
      'students',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }

  Future<int> updateClass(int classId, Map<String, dynamic> row) async {
    Database db = await database;
    return await db.update(
      'classes',
      row,
      where: 'id = ?',
      whereArgs: [classId],
    );
  }


  Future<int> updateReportTitle(int reportId, String newName) async{
    Database db = await database;
    return await db.update(
      'reports',
      {'title': newName},
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  Future<int> updateReportNotes(int reportId, String newName) async{
    Database db = await database;
    return await db.update(
      'reports',
      {'notes': newName},
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  Future<Map<String,dynamic>?> queryReport(int reportId) async {
    Database db = await database;
    List<Map<String,dynamic>> rep = await db.query('reports', where: 'id = ?', whereArgs: [reportId]);
    return rep.isNotEmpty ? rep.first : null;
  }

  Future<int> updateReportScore(int reportId, double newScore) async{
    Database db = await database;
    return await db.update(
      'reports',
      {'score': newScore},
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }


  Future<int> updateQuestion(int questionId, Map<String, dynamic> row) async {
    Database db = await database;
    return await db.update(
      'questions',
      row,
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }

  Future<int> updateQuestionChoice(int choiceId, Map<String, dynamic> row) async {
    Database db = await database;
    return await db.update(
      'question_choices',
      row,
      where: 'id = ?',
      whereArgs: [choiceId],
    );
  }

  Future<void> updateQuestionOrder(int questionId, int newOrder) async {
    final db = await database;
    await db.update(
      'questions',
      {'order': newOrder},
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }

  Future<void> updateTest(int testId, Map<String, dynamic> row) async {
    final db = await database;
    await db.update(
      'tests',
      row,
      where: 'id = ?',
      whereArgs: [testId],
    );
  }

  Future<void> updateTestOrder(int testId, int order) async {
    final db = await database;
    await db.update(
      'tests',
      {'order': order},
      where: 'id = ?',
      whereArgs: [testId],
    );
  }

  Future<List<Map<String, dynamic>>> queryAllTests() async {
    final db = await database;
    return await db.query(
      'tests',
      orderBy: '"order" ASC',
    );
  }

  Future<int> deleteQuestion(int questionId) async {
    Database db = await database;
    await db.delete('question_choices', where: 'question_id = ?', whereArgs: [questionId]); // Delete choices first
    return await db.delete('questions', where: 'id = ?', whereArgs: [questionId]);
  }

  Future<int> deleteQuestionChoice(int choiceId) async {
    Database db = await database;
    return await db.delete('question_choices', where: 'id = ?', whereArgs: [choiceId]);
  }

  Future<List<Map<String, dynamic>>> queryQuestionChoices(int questionId) async {
    Database db = await database;
    return await db.query('question_choices', where: 'question_id = ?', whereArgs: [questionId]);
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
    List<Map<String,dynamic>> students = await db.query('students', where: 'class_id = ?', whereArgs: [classId]);
    for (var i = 0; i < students.length; i++) {
      queryAverageScore(i);
    }
    return students;
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


  /*Future<List<Map<String, dynamic>>> queryAllTests() async {
    Database db = await database;
    return await db.query('tests');
  }*/

  Future<List<Map<String, dynamic>>> queryAllQuestions(int testId) async {
    Database db = await database;
    return await db.query('questions', where: 'test_id = ?', whereArgs: [testId]);
  }

  Future<List<Map<String, dynamic>>> queryAllQuestionsWithChoices(int testId) async {
    final db = await database;
    final questions = await db.query('questions', where: 'test_id = ?', whereArgs: [testId]);

    List<Map<String, dynamic>> mutableQuestions = [];
    for (var question in questions) {
      Map<String, dynamic> questionCopy = Map<String, dynamic>.from(question);
      final choices = await db.query('question_choices', where: 'question_id = ?', whereArgs: [question['id']]);
      questionCopy['choices'] = List<Map<String, dynamic>>.from(choices);
      mutableQuestions.add(questionCopy);
    }

    return mutableQuestions;
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
    else {
      Null avgScore = null;
      await db.update(
        'students',
        {'average_score': avgScore},
        where: 'id = ?',
        whereArgs: [studentId],
      );
    }
    return null;
  }

  Future<String?> getClassName(int classId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'classes',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [classId],
    );
    if (result.isNotEmpty) {
      return result.first['name'] as String?;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getQuestionsByTestId(int testId) async {
    Database db = await database;
    return await db.query(
      'questions',
      where: 'test_id = ?',
      whereArgs: [testId],
    );
  }



}
