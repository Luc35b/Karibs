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
      version: 2,
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
      subject_id INTEGER,
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
      FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE,
      UNIQUE(name, subject_id)
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
      essay_spaces INTEGER,
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
    // Insert initial subjects
    await db.insert('subjects', {'name': 'None'}); // Add default subject
    await db.insert('subjects', {'name': 'Math'});
    await db.insert('subjects', {'name': 'Science'});
    await db.insert('subjects', {'name': 'History'});
    await db.insert('subjects', {'name': 'English'});
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
  essay_spaces INTEGER,
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
    } else {
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


  Future<List<Map<String, dynamic>>> queryAllClassesWithSubjects() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT classes.id, classes.name as name, subjects.name as subjectName
      FROM classes
      INNER JOIN subjects ON classes.subject_id = subjects.id
    ''');
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


  Future<int?> getSubjectId(String subjectName) async {
    final db = await database;

    List<Map<String,dynamic>> result = await db.query(
      'subjects',
      columns:['id'],
      where: 'name = ?',
      whereArgs: [subjectName],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    return null;

  }

  Future<String?> getSubjectName(int subjectId) async {
    final db = await database;

    List<Map<String,dynamic>> result = await db.query(
      'subjects',
      columns:['name'],
      where: 'id = ?',
      whereArgs: [subjectId],
    );
    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }
    return null;

  }

  Future<int?> getCategoryId(String categoryName) async {
    final db = await database;

    List<Map<String,dynamic>> result = await db.query(
      'categories',
      columns:['id'],
      where: 'name = ?',
      whereArgs: [categoryName],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    return null;

  }

  Future<String?> getCategoryName(int categoryId) async {
    final db = await database;

    List<Map<String,dynamic>> result = await db.query(
      'categories',
      columns:['name'],
      where: 'id = ?',
      whereArgs: [categoryId],
    );
    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }
    return null;

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
      SELECT questions.id as question_id, questions.text as question_text, questions.type as question_type, questions.category_id as question_category, questions.test_id, student_test_question.got_correct
      FROM questions
      INNER JOIN student_test_question ON questions.id = student_test_question.question_id
      INNER JOIN student_tests ON student_tests.id = student_test_question.student_test_id
      WHERE student_tests.student_id = ? AND student_tests.test_id = ?
    ''', [studentId, testId]);

    return result;
  }

  Future<double?> getStudentTestTotalScore(int studentId, int testId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT total_score FROM student_tests WHERE student_id = ? AND test_id = ?',
      [studentId, testId],
    );
    if (result.isNotEmpty) {
      return result.first['total_score'] as double?;
    } else {
      return null;
    }
  }

  Future<double?> getReportScore(int reportId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT score FROM reports WHERE id = ?',
      [reportId],
    );
    if (result.isNotEmpty) {
      return result.first['score'] as double?;
    } else {
      return null;
    }
  }

  Future<int?> getStudentTestQuestionResult(int studentTestId, int questionId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT got_correct
    FROM student_test_question
    WHERE student_test_id = ? AND question_id = ?
  ''', [studentTestId, questionId]);
    if (result.isNotEmpty) {
      return result.first['got_correct'];
    }
    return null;
  }

  Future<Map<String, dynamic>?> getCategoryByNameAndSubjectId(String name, int subjectId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'categories',
      where: 'name = ? AND subject_id = ?',
      whereArgs: [name, subjectId],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCategoryByName(String categoryName) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT categories.id, categories.name, subjects.name as subject_name
    FROM categories
    JOIN subjects ON categories.subject_id = subjects.id
    WHERE categories.name = ?
  ''', [categoryName]);

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }



  Future<Map<String, dynamic>> getQuestionById(int questionId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'questions',
      where: 'id = ?',
      whereArgs: [questionId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : {};
  }


  Future<Map<String, dynamic>> getQuestionsAndAnswersForReport(int reportId) async {
    final db = await database;

    // Fetch questions and whether the student got them correct
    final List<Map<String, dynamic>> questionsResult = await db.rawQuery('''
      SELECT 
        questions.id AS question_id, 
        questions.text AS question_text, 
        questions.type AS question_type, 
        categories.name AS question_category, 
        questions.test_id, 
        student_test_question.got_correct
      FROM reports
      INNER JOIN student_tests 
        ON reports.student_id = student_tests.student_id 
        AND reports.test_id = student_tests.test_id
      INNER JOIN student_test_question 
        ON student_tests.id = student_test_question.student_test_id
      INNER JOIN questions 
        ON student_test_question.question_id = questions.id
      INNER JOIN categories 
        ON questions.category_id = categories.id
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

  Future<List<int>> getGradedStudents(int testId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'student_tests',
      columns: ['student_id'],
      where: 'test_id = ?',
      whereArgs: [testId],
    );
    return results.map((row) => row['student_id'] as int).toList();
  }

  Future<Map<String, dynamic>?> getStudentTestResults(int studentId, int testId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT * FROM student_tests 
    JOIN student_test_question ON student_tests.id = student_test_question.student_test_id
    WHERE student_tests.student_id = ? AND student_tests.test_id = ?
  ''', [studentId, testId]);

    Map<String, dynamic> savedResults = {
      'student_id': studentId,
      'test_id': testId,
      'question_correctness': {},
    };

    for (var result in results) {
      int questionId = result['question_id'];
      int correctness = result['got_correct'];
      savedResults['question_correctness'][questionId.toString()] = correctness;
    }

    return savedResults;
  }

  Future<List<Map<String, dynamic>>> getStudentScoresByTestId(int testId) async {
    final db = await database;
    return await db.query(
      'student_tests',
      columns: ['student_id', 'total_score'],
      where: 'test_id = ?',
      whereArgs: [testId],
    );
  }

  Future<List<Map<String, dynamic>>> getStudentTestQuestions(int studentId, int testId) async {
    final db = await database;
    return await db.query('student_test_questions', where: 'student_id = ? AND test_id = ?', whereArgs: [studentId, testId]);
  }

  Future<Map<String, dynamic>?> getReportById(int reportId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'reports',
      where: 'id = ?',
      whereArgs: [reportId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getStudentById(int studentId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [studentId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateReport(int reportId, Map<String, dynamic> updatedReport) async {
    final db = await database;
    await db.update(
      'reports',
      updatedReport,
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  // Update subject
  Future<void> updateSubject(int id, String newName) async {
    final db = await database;
    await db.update('subjects', {'name': newName}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateStudentTestCategoryScore(int studentTestId, int categoryId, Map<String,dynamic> updatedSTCategoryScore) async {
    final db = await database;
    await db.update(
      'student_test_category_scores',
      updatedSTCategoryScore,
      where: 'student_test_id = ? AND category_id = ?',
      whereArgs: [studentTestId, categoryId]
    );
  }

  Future<void> updateStudentTest(Map<String, dynamic> test) async {
    final db = await database;
    await db.update('student_tests', test, where: 'student_id = ? AND test_id = ?', whereArgs: [test['student_id'], test['test_id']]);
  }

  Future<void> updateStudentTestQuestion(Map<String, dynamic> question) async {
    final db = await database;
    await db.update('student_test_question', question, where: 'student_test_id = ? AND question_id = ?', whereArgs: [question['student_test_id'], question['question_id']]);
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

  Future<List<Map<String, dynamic>>> queryAllSubjects() async {
    final db = await database;
    return await db.query('subjects');
  }

  Future<int> deleteQuestion(int questionId) async {
    Database db = await database;

    // Step 1: Get the test_id and category_id associated with the question
    final questionDetails = await db.query('questions', where: 'id = ?', whereArgs: [questionId], limit: 1);
    if (questionDetails.isEmpty) return 0; // If question doesn't exist, return 0

    final testId = questionDetails.first['test_id'];
    final categoryId = questionDetails.first['category_id'];

    // Step 2: Get all student_test_id(s) associated with this test
    final studentTests = await db.query('student_tests', where: 'test_id = ?', whereArgs: [testId]);

    // Step 3: Delete the student responses to this question
    await db.delete('student_test_question', where: 'question_id = ?', whereArgs: [questionId]);

    // Step 4: Delete choices first
    await db.delete('question_choices', where: 'question_id = ?', whereArgs: [questionId]);

    // Step 5: Delete the question
    final deleteCount = await db.delete('questions', where: 'id = ?', whereArgs: [questionId]);

    // Step 6: Recalculate and update category scores and total scores for each student_test_id
    for (var studentTest in studentTests) {
      final studentTestId = studentTest['id'];

      // Calculate the new score for the affected category
      final correctAnswers = await db.rawQuery('''
      SELECT COUNT(*) as correct_count 
      FROM student_test_question 
      INNER JOIN questions ON student_test_question.question_id = questions.id 
      WHERE student_test_question.student_test_id = ? 
      AND questions.category_id = ? 
      AND student_test_question.got_correct = 1
    ''', [studentTestId, categoryId]);

      final totalQuestions = await db.rawQuery('''
      SELECT COUNT(*) as total_count 
      FROM questions 
      WHERE test_id = ? 
      AND category_id = ?
    ''', [testId, categoryId]);

      final correctCount = correctAnswers.first['correct_count'] as int;
      final totalCount = totalQuestions.first['total_count'] as int;

      if (totalCount > 0) {
        double newCategoryScore = (correctCount / totalCount) * 100;

        // Update the student_test_category_scores table
        await db.update('student_test_category_scores',
            {'score': newCategoryScore},
            where: 'student_test_id = ? AND category_id = ?',
            whereArgs: [studentTestId, categoryId]);
      } else {
        // Delete category score if there are no questions left in the category
        await db.delete('student_test_category_scores',
            where: 'student_test_id = ? AND category_id = ?',
            whereArgs: [studentTestId, categoryId]);
      }

      // Calculate the new total score for the student test
      final allCategoryScores = await db.rawQuery('''
      SELECT AVG(score) as average_score 
      FROM student_test_category_scores 
      WHERE student_test_id = ?
    ''', [studentTestId]);

      final totalScore = allCategoryScores.first['average_score'] ?? 0.0;

      await db.update('student_tests',
          {'total_score': totalScore},
          where: 'id = ?',
          whereArgs: [studentTestId]);

      // Step 7: Update the report score
      await db.update('reports',
          {'score': totalScore},
          where: 'student_id = ? AND test_id = ?',
          whereArgs: [studentTest['student_id'], testId]);
    }

    return deleteCount;
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
  // Delete subject
  Future<void> deleteSubject(int subjectId) async {
    final db = await DatabaseHelper().database;
    int defaultSubjectId = await getDefaultSubjectId();

    // Update classes and tests to set their subject to "None"
    await db.update(
      'classes',
      {'subject_id': defaultSubjectId},
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );

    await db.update(
      'tests',
      {'subject_id': defaultSubjectId},
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );

    await db.update(
      'categories',
      {'subject_id': defaultSubjectId},
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );

    // Now delete the subject
    await db.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [subjectId],
    );
  }

  Future<int> updateCategory(int categoryId, String newName) async {
    final db = await database;
    return await db.update(
      'categories',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<int> deleteCategory(int categoryId, int subjectId) async {
    final db = await database;

    // Check if the "None" category exists; if not, create it
    final List<Map<String, dynamic>> noneCategory = await db.query(
      'categories',
      where: 'name = ? AND subject_id = ?',
      whereArgs: ['None', subjectId], // subjectId should be provided or fetched accordingly
    );

    int noneCategoryId;
    if (noneCategory.isEmpty) {
      noneCategoryId = await db.insert('categories', {'name': 'None', 'subject_id': subjectId});
    } else {
      noneCategoryId = noneCategory.first['id'];
    }

    // Update all questions and items with the deleted category to the "None" category
    await db.update(
      'questions',
      {'category_id': noneCategoryId},
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );

    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<int> getDefaultSubjectId() async {
    final db = await DatabaseHelper().database;
    List<Map<String, dynamic>> result = await db.query(
      'subjects',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: ['None'],
    );

    if (result.isNotEmpty) {
      return result.first['id'];
    } else {
      throw Exception('Default subject "None" does not exist.');
    }
  }


  Future<int> deleteReport(int id) async {
    Database db = await database;

    // Fetch the related student_test IDs
    List<Map<String, dynamic>> studentTests = await db.rawQuery('''
    SELECT student_tests.*
    FROM student_tests
    INNER JOIN reports ON student_tests.test_id = reports.test_id AND student_tests.student_id = reports.student_id
    WHERE reports.id = ?
  ''', [id]);

    // Extract student_test IDs
    List<int> studentTestIds = studentTests.map((st) => st['id'] as int).toList();

    if (studentTestIds.isNotEmpty) {
      // Delete related entries in student_test_question
      await db.delete(
        'student_test_question',
        where: 'student_test_id IN (${studentTestIds.join(',')})',
      );

      // Delete related entries in student_test_category_scores
      await db.delete(
        'student_test_category_scores',
        where: 'student_test_id IN (${studentTestIds.join(',')})',
      );

      // Delete the student_tests entries
      await db.delete(
        'student_tests',
        where: 'id IN (${studentTestIds.join(',')})',
      );
    }

    // Delete the report
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


  Future<bool> classExists(String className, int subjectId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'classes',
      where: 'name = ? AND subject_id = ?',
      whereArgs: [className, subjectId],
    );
    return results.isNotEmpty;
  }


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
      Null avgScore;
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


  Future<List<Map<String, dynamic>>> getCategoriesByTestId(int testId) async {
    Database db = await database;

    // First, get the subject ID from the test ID
    List<Map<String, dynamic>> testResults = await db.query(
      'tests',
      columns: ['subject_id'],
      where: 'id = ?',
      whereArgs: [testId],
    );

    if (testResults.isEmpty) {
      return []; // Return an empty list if the test ID is not found
    }

    int subjectId = testResults.first['subject_id'];

    // Now, get the categories related to the subject ID
    List<Map<String, dynamic>> categoryResults = await db.query(
      'categories',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );

    return categoryResults;
  }

  // Function to get all classes with a specific subject ID
  Future<List<Map<String, dynamic>>> getClassesBySubjectId(int subjectId) async {
    Database db = await database;

    // Query to get classes with the specific subject ID
    List<Map<String, dynamic>> classResults = await db.query(
      'classes',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );

    return classResults;
  }

  Future<List<int>> getGradedQuestions(int testId) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'student_test_question',
      columns: ['question_id'],
      where: 'student_test_id = ?',
      whereArgs: [testId],
    );

    return result.map((map) => map['question_id'] as int).toList();
  }

  Future<double?> getStudentTestCategoryScore(int studentTestId, int categoryId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'student_test_category_scores',
      columns: ['score'],
      where: 'student_test_id = ? AND category_id = ?',
      whereArgs: [studentTestId, categoryId],
    );
    if (result.isNotEmpty) {
      return result.first['score'];
    }
    return null;
  }



  Future<Map<String, double?>> getCategoryScoresbyStudentTestId(int studentTestId) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT categories.name AS category, student_test_category_scores.score AS score
      FROM student_test_category_scores
      JOIN categories ON student_test_category_scores.category_id = categories.id
      WHERE student_test_category_scores.student_test_id = ?
    ''', [studentTestId]);

    Map<String, double?> categoryScores = {};

    for (var row in result) {
      categoryScores[row['category']] = row['score'];
    }

    return categoryScores;
  }

  Future<Map<int, double?>> getCategoryScoresbyIndexbyStudentTestId(int studentTestId) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT categories.id AS category, student_test_category_scores.score AS score
      FROM student_test_category_scores
      JOIN categories ON student_test_category_scores.category_id = categories.id
      WHERE student_test_category_scores.student_test_id = ?
    ''', [studentTestId]);

    Map<int, double?> categoryScores = {};

    for (var row in result) {
      categoryScores[row['category']] = row['score'];
    }

    return categoryScores;
  }




  Future<int?> getStudentTestIdFromReport(int reportId) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'reports',
      columns: ['student_id', 'test_id'],
      where: 'id = ?',
      whereArgs: [reportId],
    );

    if (result.isNotEmpty && result.first['test_id'] != null) {
      int studentId = result.first['student_id'];
      int testId = result.first['test_id'];

      final List<Map<String, dynamic>> studentTestResult = await db.query(
        'student_tests',
        columns: ['id'],
        where: 'student_id = ? AND test_id = ?',
        whereArgs: [studentId, testId],
      );

      if (studentTestResult.isNotEmpty) {
        return studentTestResult.first['id'] as int;
      }
    }
    return null;
  }



}
