import 'package:flutter/material.dart';
import 'package:karibs/screens/student_info_screen.dart';
import 'package:karibs/screens/view_test_grade_screen.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/student_grading_provider.dart';
import 'teacher_class_screen.dart';

class RegradeScreen extends StatefulWidget {
  final int reportId;

  const RegradeScreen({Key? key, required this.reportId}) : super(key: key);

  @override
  _RegradeScreenState createState() => _RegradeScreenState();
}

class _RegradeScreenState extends State<RegradeScreen> {
  String? _className;
  Map<String, dynamic>? _student;
  List<Map<String, dynamic>> _questions = [];
  Map<int, int> question_answer_map = {};
  int? _selectedStudentId;
  bool _isLoading = true;
  Map<String, int> sub_scores = {};
  Map<int, int> questionCorrectness = {};
  String? _testTitle;
  int? _testId;

  @override
  void initState() {
    super.initState();
    _fetchReportDetails();
  }

  Future<void> _fetchReportDetails() async {
    Map<String, dynamic>? report = await DatabaseHelper().getReportById(widget.reportId);
    if (report != null) {
      _selectedStudentId = report['student_id'];
      _testId = report['test_id'];
      _testTitle = report['title'];

      // Fetch student and questions details
      _student = await DatabaseHelper().getStudentById(_selectedStudentId!);
      _questions = await DatabaseHelper().getQuestionsByTestId(_testId!);
      _className = await DatabaseHelper().getClassName(_student!['class_id']);

      // Initialize sub_scores and questionCorrectness based on saved data
      await _initializeSavedResults();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initializeSavedResults() async {
    // Get saved regrading results for the current student and test
    Map<String, dynamic>? savedResults = await DatabaseHelper().getStudentTestResults(_selectedStudentId!, _testId!);
    if (savedResults != null) {
      // Initialize questionCorrectness based on saved results
      _initializeQuestionCorrectness(savedResults);
      // Initialize sub_scores based on saved results
      _initializeSubScores(savedResults);
    }
  }

  void _initializeSubScores(Map<String, dynamic> savedResults) {
    sub_scores.clear();
    for (var question in _questions) {
      String category = question['category'];
      int questionId = question['id'];
      int correctness = savedResults['question_correctness'][questionId] ?? 0;
      if (!sub_scores.containsKey(category)) {
        sub_scores[category] = 0;
      }
      if (correctness == 1) {
        sub_scores[category] = sub_scores[category]! + 1;
      } else if (correctness == -1) {
        sub_scores[category] = sub_scores[category]! - 1;
      }
    }
  }

  void _initializeQuestionCorrectness(Map<String, dynamic> savedResults) {
    questionCorrectness.clear();
    savedResults['question_correctness'].forEach((questionId, correctness) {
      questionCorrectness[int.parse(questionId)] = correctness;
    });
  }

  void _markCorrect(int questionId, String category) {
    setState(() {
      if (questionCorrectness[questionId] == -1) {
        questionCorrectness[questionId] = 1;
        sub_scores[category] = ((sub_scores[category])! + 1);
      } else if (questionCorrectness[questionId] == 0) {
        questionCorrectness[questionId] = 1;
        sub_scores[category] = ((sub_scores[category])! + 1);
      }
      question_answer_map[questionId] = 1;
    });
  }

  void _markIncorrect(int questionId, String category) {
    setState(() {
      if (questionCorrectness[questionId] == 1) {
        questionCorrectness[questionId] = -1;
        if ((sub_scores[category] ?? 0) > 0) {
          sub_scores[category] = (sub_scores[category] ?? 0) - 1;
        }
      }
      if (questionCorrectness[questionId] == 0) {
        questionCorrectness[questionId] = -1;
      }
      question_answer_map[questionId] = -1;
    });
  }

  void _saveRegradingResults() async {
    // Calculate total score and sub-scores
    int totalQuestions = _questions.length;
    int vocabQuestions = 0;
    int compQuestions = 0;
    for (int i = 0; i < totalQuestions; i++) {
      if (_questions[i]['category'] == 'Vocab') {
        vocabQuestions++;
      } else {
        compQuestions++;
      }
    }
    int totalCorrect = sub_scores.values.fold(0, (sum, score) => sum + score);

    double totalScore = (totalCorrect / totalQuestions) * 100;
    double vocabScore = (sub_scores['Vocab'] ?? 0) / vocabQuestions * 100;
    double compScore = (sub_scores['Comprehension'] ?? 0) / compQuestions * 100;

    // Ensure scores are not negative
    totalScore = totalScore.clamp(0, 100);
    vocabScore = vocabScore.clamp(0, 100);
    compScore = compScore.clamp(0, 100);

    print({
      'student_id': _selectedStudentId!,
      'test_id': _testId!,
      'total_score': totalScore,
      'vocab_score': vocabScore,
      'comp_score': compScore,
    });

    // Save scores to the database
    if (_selectedStudentId != null) {
      await DatabaseHelper().updateStudentTest({
        'student_id': _selectedStudentId!,
        'test_id': _testId!,
        'total_score': totalScore,
        'vocab_score': vocabScore,
        'comp_score': compScore,
      });
      await DatabaseHelper().updateReport(widget.reportId, {
        'date': DateTime.now().toIso8601String(),
        'title': _testTitle!,
        'notes': 'Regraded test for student',
        'score': totalScore,
        'vocab_score': vocabScore,
        'comp_score': compScore,
      });

      int? studentTestId = await DatabaseHelper().getStudentTestId(_selectedStudentId!, _testId!);

      print(question_answer_map);

      question_answer_map.forEach((key, value) async {
        await DatabaseHelper().updateStudentTestQuestion({
          'student_test_id': studentTestId,
          'question_id': key,
          'got_correct': value,
        });
        print({
          'student_test_id': studentTestId,
          'question_id': key,
          'got_correct': value,
        });
      });

      // Show a confirmation message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grades updated successfully'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
          )
      );

      // Notify the provider that a student has been regraded
      Provider.of<StudentGradingProvider>(context, listen: false).grade();
    }
  }

  Future<void> _navigateToStudentInfoScreen(int studentId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentInfoScreen(studentId: studentId),
      ),
    );
    _fetchReportDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regrade Test for $_testTitle'),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              if (_className != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Regrading details for class $_className and test $_testTitle',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              if (_student != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Regrading Student: ${_student!['name']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    int questionId = _questions[index]['id'];
                    String category = _questions[index]['category'];
                    return ListTile(
                      title: Text(_questions[index]['text']),
                      subtitle: Text(category),
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
                              _markCorrect(questionId, category);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
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
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: (_selectedStudentId != null && _questions.isNotEmpty)
                          ? () {
                        _saveRegradingResults(); // Save regrading results
                      }
                          : null,
                      child: const Text('Save Regrade'),
                    ),
                    const SizedBox(width: 42), // Add some space between the buttons
                    ElevatedButton(
                      onPressed: () {
                        _navigateToStudentInfoScreen(_selectedStudentId!);
                      },
                      child: const Text('Return to Student'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
