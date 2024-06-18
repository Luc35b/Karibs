import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/student_grading_provider.dart';
import 'package:karibs/providers/student_grading_provider.dart';
import 'teacher_class_screen.dart';

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
  Map<int, int> question_answer_map = {};
  int? _selectedStudentId;
  bool _isLoading = true;
  Map<String, int> sub_scores = {};
  Map<int, int> questionCorrectness = {};

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

  void _initializeQuestionMap() {
    question_answer_map.clear();
  }

  void _initializeQuestionCorrectness() {
    questionCorrectness.clear();
    for (var question in _questions) {
      questionCorrectness[question['id']] = 0;
    }
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
        sub_scores[category] = ((sub_scores[category])! - 1);
      }
      if (questionCorrectness[questionId] == 0) {
        questionCorrectness[questionId] = -1;
      }
      question_answer_map[questionId] = -1;
    });
  }

  void _saveGradingResults() async {
    // Calculate total score and sub-scores
    int totalQuestions = _questions.length;
    int vocabQuestions = 0;
    int compQuestions = 0;
    for(int i = 0; i < totalQuestions; i++) {
      if(_questions[i]['category'] == 'Vocab') {
        vocabQuestions++;
      }
      else{
        compQuestions++;
      }
    }
    int totalCorrect = sub_scores.values.fold(0, (sum, score) => sum + score);

    double totalScore = (totalCorrect / totalQuestions) * 100;
    double vocabScore = (sub_scores['Vocab'] ?? 0) / vocabQuestions * 100;
    double compScore = (sub_scores['Comprehension'] ?? 0) / compQuestions * 100;

    print(
        {
          'student_id': _selectedStudentId!,
          'test_id': widget.testId,
          'total_score': totalScore,
          'vocab_score': vocabScore,
          'comp_score': compScore,
        }
    );

    // Save scores to the database
    if (_selectedStudentId != null) {
      await DatabaseHelper().insertStudentTest({
        'student_id': _selectedStudentId!,
        'test_id': widget.testId,
        'total_score': totalScore,
        'vocab_score': vocabScore,
        'comp_score': compScore,
      });
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

      int? student_test_id = await DatabaseHelper().getStudentTestId(_selectedStudentId!, widget.testId);

      print(question_answer_map);

      question_answer_map.forEach((key,value) async {
        await DatabaseHelper().insertStudentTestQuestion({
          'student_test_id': student_test_id,
          'question_id': key,
          'got_correct': value
        });
        print({
          'student_test_id': student_test_id,
          'question_id': key,
          'got_correct': value
        });
      });


      // Show a confirmation message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Grades saved successfully'),
      duration: Duration(milliseconds: 1500),));

      // Notify the provider that a student has been graded
      Provider.of<StudentGradingProvider>(context, listen: false).grade();
    }
  }

  void _goToTeacherDashboard(int classId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeacherClassScreen(classId: classId,refresh: true,)),
    ).then((_){
      _fetchClassName();
      _fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Exam for ${widget.testTitle}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_className != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Grading details for class: $_className and exam: ${widget.testTitle}',
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
                  _initializeQuestionMap();
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
      Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
      children: [
      ElevatedButton(
      onPressed: (_selectedStudentId != null && _questions.isNotEmpty)
      ? () {
      _saveGradingResults(); // Navigate to TeacherDashboard after saving results
      }
          : null,
      child: Text('Save Grades'),
      ),
      SizedBox(width: 42), // Add some space between the buttons
      ElevatedButton(
      onPressed: () {
      _goToTeacherDashboard(widget.classId); // Navigate to TeacherDashboard after saving results
      },
      child: Text('Go to Class'),
      ),
      ],
      ),
      )
      )
        ],
      ),
    );
  }
}