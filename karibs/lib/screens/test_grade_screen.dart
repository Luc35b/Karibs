import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';

class TestGradeScreen extends StatefulWidget {
  final int classId;
  final String testTitle;
  final int testId;

  TestGradeScreen({
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
  int? _selectedStudentId;
  bool _isLoading = true;
  Map<String, int> sub_scores = {};
  Map<int, bool> questionCorrectness = {};

  @override
  void initState() {
    super.initState();
    _fetchClassName();
    _fetchStudents();
    _fetchQuestions();
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
    List<Map<String, dynamic>> questions = await DatabaseHelper().getQuestionsByTestId(widget.testId);
    setState(() {
      _questions = questions;
      _initializeSubScores();
      _initializeQuestionCorrectness();
    });
  }

  void _initializeSubScores() {
    sub_scores.clear();
    for (var question in _questions) {
      if (!sub_scores.containsKey(question['category'])) {
        sub_scores[question['category']] = 0;
      }
    }
  }

  void _initializeQuestionCorrectness() {
    questionCorrectness.clear();
    for (var question in _questions) {
      questionCorrectness[question['id']] = false;
    }
  }

  void _markCorrect(int questionId, String category) {
    setState(() {
      questionCorrectness[questionId] = true;
      sub_scores[category] = (sub_scores[category] ?? 0) + 1;
    });
  }

  void _markIncorrect(int questionId, String category) {
    setState(() {
      questionCorrectness[questionId] = false;
      sub_scores[category] = (sub_scores[category] ?? 0) - 1;
    });
  }

  void _saveGradingResults() async {
    // Calculate total score and sub-scores
    int totalQuestions = _questions.length;
    int totalCorrect = sub_scores.values.fold(0, (sum, score) => sum + score);

    double totalScore = (totalCorrect / totalQuestions) * 100;
    double vocabScore = (sub_scores['vocab'] ?? 0) / totalQuestions * 100;
    double compScore = (sub_scores['comp'] ?? 0) / totalQuestions * 100;

    // Save scores to the database
    if (_selectedStudentId != null) {
      await DatabaseHelper().insertStudentTest({
        'student_id': _selectedStudentId!,
        'test_id': widget.testId,
        'total_score': totalScore,
        'vocab_score': vocabScore,
        'comp_score': compScore,
      }
      );
      await DatabaseHelper().insertReport({
        'student_id': _selectedStudentId!,
        'test_id': widget.testId,
        'date': DateTime.now().toIso8601String(),
        'title': widget.testTitle,
        'notes': 'Graded test for student ',
        'score': totalScore,
        'vocab_score': vocabScore,
        'comp_score': compScore,
      });
      // Show a confirmation message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Grades saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Test for ${widget.testTitle}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_className != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Grading details for class $_className and test ${widget.testTitle}',
                style: TextStyle(fontSize: 20),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<int>(
              hint: Text("Select Student"),
              value: _selectedStudentId,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedStudentId = newValue;
                  _initializeSubScores(); // Clear sub_scores when a new student is selected
                  _initializeQuestionCorrectness(); // Clear questionCorrectness when a new student is selected
                });
              },
              items: _students.map<DropdownMenuItem<int>>((Map<String, dynamic> student) {
                return DropdownMenuItem<int>(
                  value: student['id'],
                  child: Text(student['name']),
                );
              }).toList(),
            ),
          ),
          if (_selectedStudentId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Selected Student: ${_students.firstWhere((student) => student['id'] == _selectedStudentId)['name']}',
                style: TextStyle(fontSize: 18),
              ),
            ),
          if (_selectedStudentId != null)
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  int questionId = _questions[index]['id'];
                  String category = _questions[index]['category'];
                  return ListTile(
                    title: Text(_questions[index]['text']),
                    subtitle: Text(category),
                    tileColor: questionCorrectness[questionId] == true
                        ? Colors.green.withOpacity(0.2)
                        : questionCorrectness[questionId] == false
                        ? Colors.red.withOpacity(0.2)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _markCorrect(questionId, category);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.red),
                          onPressed: () {
                            _markIncorrect(questionId, category);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: (_selectedStudentId != null && _questions.isNotEmpty)
                  ? _saveGradingResults
                  : null,
              child: Text('Save Grades'),
            ),
          ),
        ],
      ),
    );
  }
}
