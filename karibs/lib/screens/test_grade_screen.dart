import 'package:flutter/material.dart';
import 'package:karibs/main.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../providers/student_grading_provider.dart';
import 'teacher_class_screen.dart';
import 'package:karibs/pdf_gen.dart';

class TestGradeScreen extends StatefulWidget {
  final int classId;
  final String testTitle;
  final int testId;

  const TestGradeScreen({
    super.key,
    required this.classId,
    required this.testTitle,
    required this.testId,
  });

  @override
  _TestGradeScreenState createState() => _TestGradeScreenState();
}

class _TestGradeScreenState extends State<TestGradeScreen> {
  String? _className;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _categories = [];
  Map<int, int> question_answer_map = {};
  int? _selectedStudentId;
  bool _isLoading = true;
  Map<int, int> categoryScores = {};
  Map<int, int> questionCorrectness = {};
  Set<int> _gradedStudentIds = {};

  @override
  void initState() {
    super.initState();
    _fetchClassName();
    _fetchStudents();
    _fetchQuestions();
    _fetchGradedStudents();
  }

  Future<void> _fetchClassName() async {
    String? className = await DatabaseHelper().getClassName(widget.classId);
    setState(() {
      _className = className;
    });
  }

  Future<void> _fetchStudents() async {
    List<Map<String, dynamic>> students = await DatabaseHelper().queryAllStudents(widget.classId);
    setState(() {
      _students = students;
      _isLoading = false;
    });
  }

  Future<void> _fetchQuestions() async {
    final data = await DatabaseHelper().queryAllQuestionsWithChoices(widget.testId);
    final prefs = await SharedPreferences.getInstance();
    final orderList = prefs.getStringList('test_${widget.testId}_order'); // Corrected method

    List<Map<String, dynamic>> orderedQuestions = data;

    if (orderList != null) {
      final orderIntList = orderList.map((e) => int.parse(e)).toList();
      orderedQuestions.sort((a, b) => orderIntList.indexOf(a['id']).compareTo(orderIntList.indexOf(b['id'])));
    }

    List<Map<String, dynamic>> categories = await DatabaseHelper().getCategoriesByTestId(widget.testId);
    setState(() {
      _questions = orderedQuestions;
      _categories = categories;
      _initializeCategoryScores();
      _initializeQuestionCorrectness();
    });
  }

  Future<void> _fetchGradedStudents() async {
    List<int> gradedStudentIds = await DatabaseHelper().getGradedStudents(widget.testId);
    setState(() {
      _gradedStudentIds = gradedStudentIds.toSet();
    });
  }

  void _initializeCategoryScores() {
    categoryScores.clear();
    for (var category in _categories) {
      categoryScores[category['id']] = 0;
    }
  }

  void _initializeQuestionCorrectness() {
    questionCorrectness.clear();
    for (var question in _questions) {
      questionCorrectness[question['id']] = 0;
    }
  }

  void _markCorrect(int questionId, int categoryId) {
    setState(() {
      if (questionCorrectness[questionId] == -1) {
        questionCorrectness[questionId] = 1;
        categoryScores[categoryId] = (categoryScores[categoryId] ?? 0) + 1;
      } else if (questionCorrectness[questionId] == 0) {
        questionCorrectness[questionId] = 1;
        categoryScores[categoryId] = (categoryScores[categoryId] ?? 0) + 1;
      }
      question_answer_map[questionId] = 1;
    });
  }

  void _markIncorrect(int questionId, int categoryId) {
    setState(() {
      if (questionCorrectness[questionId] == 1) {
        questionCorrectness[questionId] = -1;
        categoryScores[categoryId] = (categoryScores[categoryId] ?? 0) - 1;
      }
      if (questionCorrectness[questionId] == 0) {
        questionCorrectness[questionId] = -1;
      }
      question_answer_map[questionId] = -1;
    });
  }

  void _saveGradingResults() async {
    int totalQuestions = _questions.length;
    int totalCorrect = categoryScores.values.fold(0, (sum, score) => sum + score);

    double totalScore = (totalCorrect / totalQuestions) * 100;

    Map<int, double> categoryScoresPercentage = {};
    for (var category in _categories) {
      int categoryId = category['id'];
      int categoryQuestions = _questions.where((question) => question['category_id'] == categoryId).length;
      double categoryScore = (categoryScores[categoryId] ?? 0) / categoryQuestions * 100;
      categoryScoresPercentage[categoryId] = categoryScore;
    }

    if (_selectedStudentId != null) {
      int studentTestId = await DatabaseHelper().insertStudentTest({
        'student_id': _selectedStudentId!,
        'test_id': widget.testId,
        'total_score': totalScore,
      });

      await DatabaseHelper().insertReport({
        'student_id': _selectedStudentId!,
        'test_id': widget.testId,
        'date': DateTime.now().toIso8601String(),
        'title': widget.testTitle,
        'notes': 'Graded test for student ',
        'score': totalScore,
      });

      for (var entry in question_answer_map.entries) {
        await DatabaseHelper().insertStudentTestQuestion({
          'student_test_id': studentTestId,
          'question_id': entry.key,
          'got_correct': entry.value
        });
      }

      for (var entry in categoryScoresPercentage.entries) {
        await DatabaseHelper().insertStudentTestCategoryScore({
          'student_test_id': studentTestId,
          'category_id': entry.key,
          'score': entry.value,
        });
      }

      setState(() {
        _gradedStudentIds.add(_selectedStudentId!);
        _selectedStudentId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grades saved successfully'),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );

      Provider.of<StudentGradingProvider>(context, listen: false).grade();
    }
  }

  void _goToTeacherDashboard(int classId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeacherClassScreen(classId: classId, refresh: true)),
    ).then((_) {
      _fetchClassName();
      _fetchStudents();
    });
  }

  void _generateAndPrintPdf() {
    PdfGenerator().generateTestScoresPdf(widget.testId, widget.testTitle, _students);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Exam for ${widget.testTitle}'),
        backgroundColor: DeepPurple,
        foregroundColor: White,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Column(
          children: [
            if (_className != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Grading Exam: ${widget.testTitle} for "$_className" ',
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<int>(
                hint: const Text("Select Student"),
                value: _selectedStudentId,
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedStudentId = newValue;
                    _initializeCategoryScores();
                    _initializeQuestionCorrectness();
                    question_answer_map.clear();
                  });
                },
                items: _students.map<DropdownMenuItem<int>>((Map<String, dynamic> student) {
                  return DropdownMenuItem<int>(
                    value: student['id'],
                    enabled: !_gradedStudentIds.contains(student['id']),
                    child: Text(
                      student['name'],
                      style: TextStyle(
                        color: _gradedStudentIds.contains(student['id']) ? Colors.grey : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_selectedStudentId != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Selected Student: ${_students.firstWhere((student) => student['id'] == _selectedStudentId)['name']}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            if (_selectedStudentId != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    int questionId = _questions[index]['id'];
                    int categoryId = _questions[index]['category_id'];
                    String categoryName =
                    _categories.firstWhere((category) => category['id'] == categoryId)['name'];
                    return ListTile(
                      title: Text(_questions[index]['text']),
                      subtitle: Text(categoryName),
                      tileColor: questionCorrectness[questionId] == 1
                          ? Colors.green.withOpacity(0.2)
                          : questionCorrectness[questionId] == -1
                          ? Colors.red.withOpacity(0.2)
                          : questionCorrectness[questionId] == 0
                          ? Colors.grey.withOpacity(0.2)
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              _markCorrect(questionId, categoryId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed: () {
                              _markIncorrect(questionId, categoryId);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (_gradedStudentIds.length == _students.length)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "View student report to edit their score.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ElevatedButton(
                    onPressed: (_selectedStudentId != null &&
                        _questions.isNotEmpty &&
                        !_gradedStudentIds.contains(_selectedStudentId) &&
                        !_questions.any((question) => questionCorrectness[question['id']] == 0))
                        ? () {
                      _saveGradingResults();
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: White,
                      foregroundColor: DeepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      side: const BorderSide(width: 1, color: DeepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Save Grade'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _goToTeacherDashboard(widget.classId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: White,
                      foregroundColor: DeepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      side: const BorderSide(width: 1, color: DeepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Go to Class'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: IconButton(
                    onPressed: _generateAndPrintPdf,
                    icon: Icon(Icons.print),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: White,
                      foregroundColor: DeepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      side: const BorderSide(width: 1, color: DeepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    color: DeepPurple,
                    iconSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

