import 'package:flutter/material.dart';
import 'package:karibs/main.dart';
import 'package:karibs/screens/student_info_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../main.dart';
import '../overlay.dart';
import '../providers/student_grading_provider.dart';

class RegradeTestScreen extends StatefulWidget {
  final int reportId;


  const RegradeTestScreen({Key? key, required this.reportId}) : super(key: key);


  @override
  _RegradeTestScreenState createState() => _RegradeTestScreenState();
}

class _RegradeTestScreenState extends State<RegradeTestScreen> {
  String? _className;
  Map<String, dynamic>? _student;
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _categories = [];
  Map<int, int> question_answer_map = {};
  int? _selectedStudentId;
  bool _isLoading = true;
  bool _testDeleted = false;
  Map<int, double?> categoryScores = {}; // Updated to store category scores
  Map<int, int> questionCorrectness = {};
  String? _testTitle;
  int? _testId;
  int? _studentTestId;

  @override
  void initState() {
    super.initState();
    _fetchReportDetails(); //fetch report details when screen initializes
  }

  //fetch report details based on report id
  Future<void> _fetchReportDetails() async {
    Map<String, dynamic>? report = await DatabaseHelper().getReportById(widget.reportId);
    if (report != null) {
      _selectedStudentId = report['student_id'];
      _testId = report['test_id'];
      _testTitle = report['title'];
      _studentTestId =
      await DatabaseHelper().getStudentTestIdFromReport(widget.reportId);
    }
      // Fetch student details, questions, class name, and categories
    _student = await DatabaseHelper().getStudentById(_selectedStudentId!);
    _questions = await DatabaseHelper().getQuestionsByTestId(_testId!);
    _className = await DatabaseHelper().getClassName(_student!['class_id']);
    _categories = await DatabaseHelper().getCategoriesByTestId(_testId!);

      // Fetch questions details in the correct order based on stored preferences
      final data = await DatabaseHelper().queryAllQuestionsWithChoices(_testId!);
      final prefs = await SharedPreferences.getInstance();
      final orderList = prefs.getStringList('test_${_testId!}_order'); // Corrected method

      List<Map<String, dynamic>> orderedQuestions = data;

    // Sort questions based on the retrieved order list
      if (orderList != null) {
        final orderIntList = orderList.map((e) => int.parse(e)).toList();
        orderedQuestions.sort((a, b) => orderIntList.indexOf(a['id']).compareTo(orderIntList.indexOf(b['id'])));
      }


      // Initialize categoryScores and questionCorrectness based on saved data
      await _initializeSavedResults();

    // If no categories are found, indicate that the test has been deleted
    if(_categories.isEmpty) {
      setState(() {
        _testDeleted = true;
        _isLoading = false;
      });
      return;
    }

      setState(() {
        _questions = orderedQuestions;
        _isLoading = false;
      });

  }

  Future<void> _initializeSavedResults() async {
    // Get saved regrading results for the current student and test
    Map<String, dynamic>? savedResults = await DatabaseHelper().getStudentTestResults(_selectedStudentId!, _testId!);
    if (savedResults != null) {
      // Initialize questionCorrectness based on saved results
      _initializeQuestionCorrectness(savedResults);
      // Initialize categoryScores based on saved results
      await _initializeCategoryScores(savedResults);
    }
  }

  Future<void> _initializeCategoryScores(Map<String, dynamic> savedResults) async {
    categoryScores.clear();
    Map<int, double?> cats = await DatabaseHelper().getCategoryScoresbyIndexbyStudentTestId(_studentTestId!);

    // Convert percentage scores to raw scores based on the number of questions
    for (var entry in cats.entries) {
      if (entry.value != null) {
        int categoryId = entry.key;
        double? percentageScore = entry.value;
        int categoryQuestions = _questions.where((question) => question['category_id'] == categoryId).length;
        cats[categoryId] = (percentageScore! / 100.0) * categoryQuestions;
      }
    }

    setState(() {
      categoryScores = cats;
    });

    print(categoryScores); // Ensure correct initialization

  }

  //saves correct answers
  void _initializeQuestionCorrectness(Map<String, dynamic> savedResults) {
    questionCorrectness.clear();
    savedResults['question_correctness'].forEach((questionId, correctness) {
      questionCorrectness[int.parse(questionId)] = correctness;
    });
    print(questionCorrectness);
  }

  //marks a question correct by the teacher
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

  //marks a question incorrect by the teacher
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

  void _saveRegradingResults() async {
    // Retrieve existing total score and score from the database
    double? existingTotalScore = await DatabaseHelper().getStudentTestTotalScore(_selectedStudentId!, _testId!);
    double? existingScore = await DatabaseHelper().getReportScore(widget.reportId);

    // Calculate total score and category scores
    int totalQuestions = _questions.length;
    double totalScore = (categoryScores.values.where((score) => score != null).fold(0.0, (sum, score) => sum + score!) / totalQuestions) * 100;
    print('totalScore: $totalScore');
    print(categoryScores);


    // Ensure total score is not negative
    totalScore = totalScore.clamp(0.0, 100.0);

    Map<int, double> categoryScoresPercentage = {};
    for (var category in _categories) {
      int categoryId = category['id'];
      int categoryQuestions = _questions.where((question) => question['category_id'] == categoryId).length;
      if (categoryScores[categoryId] != null) {
        double categoryScore = (categoryScores[categoryId]! / categoryQuestions) * 100;
        categoryScore = categoryScore.clamp(0, 100);
        categoryScoresPercentage[categoryId] = categoryScore;
      }
    }

    print(categoryScoresPercentage);


    // Save scores to the database
    if (_selectedStudentId != null) {
      await DatabaseHelper().updateStudentTest({
        'student_id': _selectedStudentId!,
        'test_id': _testId!,
        'total_score': totalScore,
      });
      await DatabaseHelper().updateReport(widget.reportId, {
        'date': DateTime.now().toIso8601String(),
        'title': _testTitle!,
        //'notes': 'Regraded test for student',
        'score': totalScore, // Keep the existing score if available
      });

      int? studentTestId = await DatabaseHelper().getStudentTestId(_selectedStudentId!, _testId!);

      // Update database with current values in question_answer_map if they exist,
      // otherwise keep the existing values from the database
      question_answer_map.forEach((key, value) async {
        int? existingValue = await DatabaseHelper().getStudentTestQuestionResult(studentTestId!, key);
        if (existingValue != null) {
          await DatabaseHelper().updateStudentTestQuestion({
            'student_test_id': studentTestId,
            'question_id': key,
            'got_correct': value,
          });
        }
      });

      // Update category scores in the database
      for (var entry in categoryScoresPercentage.entries) {
        await DatabaseHelper().updateStudentTestCategoryScore(studentTestId!, entry.key, {
          'student_test_id': studentTestId,
          'category_id': entry.key,
          'score': entry.value,
        });

        print({
          'category_id': entry.key,
          'score': entry.value,
        });
      }


      // Show a confirmation message or navigate back to the previous screen.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grades updated successfully'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );
      // Notify the provider that a student has been regraded
      Provider.of<StudentGradingProvider>(context, listen: false).grade();
    }
  }

  //displays the tutorial dialog for the regrade test screen
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RegradeTestScreenTutorialDialog();
      },
    );
  }


//navigates to the student info screen
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
        foregroundColor: White,
        backgroundColor: DeepPurple,
        title: Row(
          children: [
            Text('Regrade Test for $_testTitle'),
            SizedBox(width: 8), // Adjust spacing between title and icon
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                // Show tutorial dialog
                _showTutorialDialog();
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          //checks if test has been deleted
          _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _testDeleted
            ? const Center(
          child: Text(
            'The Test has been Deleted.',
            style: TextStyle(fontSize: 30),
          ),
        )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_className != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center( // Center the text widget
                child: Text(
                  'Regrading Exam: $_testTitle for "$_className" ',
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (_student != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center( // Center the text widget
                child: Text(
                  'Regrading Student: ${_student!['name']}',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Expanded(
            //changes colors and category score when test is marked correct or incorrect
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                int questionId = _questions[index]['id'];
                int categoryId = _questions[index]['category_id'];
                String categoryName = _categories.firstWhere((category) => category['id'] == categoryId)['name'];
                return ListTile(
                  title: Text(_questions[index]['text']),
                  subtitle: Text('Category: $categoryName'),
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
          ],
          ),

          //saves the regrade and allows navigation back to the student info screen
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
                    if (_testDeleted == false) ...[
                      ElevatedButton(
                        onPressed: (_selectedStudentId != null && _questions.isNotEmpty)
                            ? () {
                          _saveRegradingResults(); // Save regrading results
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                    backgroundColor: White,
                    foregroundColor: DeepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    side: const BorderSide(width: 1, color: DeepPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                        child: const Text('Save Regrade'),
                      ),
                      const SizedBox(width: 42), // Add some space between the buttons
                    ],
                    ElevatedButton(
                      onPressed: () {
                        _navigateToStudentInfoScreen(_selectedStudentId!);
                      },
                      style: ElevatedButton.styleFrom(
                    backgroundColor: White,
                    foregroundColor: DeepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    side: const BorderSide(width: 1, color: DeepPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                      child: const Text('Return to Student'),
                    ),
                  ],
                ),
              ),
            )
            ,
          ),
        ],
      ),
    );
  }
}