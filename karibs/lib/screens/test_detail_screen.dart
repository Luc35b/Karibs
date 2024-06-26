import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/overlay.dart';
import 'package:karibs/screens/teacher_dashboard.dart';
import 'package:karibs/screens/tests_screen.dart';
import 'edit_question_screen.dart';
import 'add_question_screen.dart';
import 'question_detail_screen.dart';
import 'package:karibs/pdf_gen.dart';
import 'test_grade_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestDetailScreen extends StatefulWidget {
  final int testId;
  final String testTitle;
  final int subjectId;

  const TestDetailScreen({super.key, required this.testId, required this.testTitle, required this.subjectId});

  @override
  _TestDetailScreenState createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends State<TestDetailScreen> {
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  ///fetch questions for the current test from the database
  Future<void> _fetchQuestions() async {
    final data = await DatabaseHelper().queryAllQuestions(widget.testId);
    List<Map<String, dynamic>> questions = List<Map<String, dynamic>>.from(data);

    // Load order from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedOrder = prefs.getStringList('test_${widget.testId}_order');

    ///sort questions based on custom order if available
    if (savedOrder != null) {
      questions.sort((a, b) {
        int aIndex = savedOrder.indexOf(a['id'].toString());
        int bIndex = savedOrder.indexOf(b['id'].toString());
        return aIndex.compareTo(bIndex);
      });
    }

    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  ///navigation to add a new question
  void _navigateToAddQuestionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(
          testId: widget.testId,
          subjectId: widget.subjectId,
          onQuestionAdded: _handleQuestionAdded,
        ),
      ),
    );
  }

  ///navigation to add a new question
  void _handleQuestionAdded(int newQuestionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedOrder = prefs.getStringList('test_${widget.testId}_order') ?? [];
    savedOrder.add(newQuestionId.toString());
    await prefs.setStringList('test_${widget.testId}_order', savedOrder);

    // Fetch the newly added question and add it to the end of the questions list
    final newQuestion = await DatabaseHelper().getQuestionById(newQuestionId);
    setState(() {
      _questions.add(newQuestion);
    });
  }

  ///navigation method to view details of a question
  void _navigateToQuestionDetailScreen(int questionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionDetailScreen(
          questionId: questionId,
          subjectId: widget.subjectId,
        ),
      ),
    );
  }

  /// Navigation method to edit a question
  void _navigateToEditQuestionScreen(int questionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuestionScreen(
          questionId: questionId,
          onQuestionUpdated: _fetchQuestions,
          subjectId: widget.subjectId,
        ),
      ),
    );
  }

  /// Method to show a confirmation dialog before deleting a question
  void _showDeleteConfirmationDialog(int questionId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Question'),
          content: const Text('Are you sure you want to delete this question?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: () {
                _deleteQuestion(questionId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  /// Method to delete a question from the database
  void _deleteQuestion(int questionId) async {
    await DatabaseHelper().deleteQuestion(questionId);
    _fetchQuestions();
  }

  /// Method to generate and print a PDF of all question
  void _generateAndPrintQuestionsPdf() async {
    await _fetchQuestions();
    await PdfGenerator(context).generateTestQuestionsPdf(widget.testId, widget.testTitle);
  }

  /// Method to generate and print a PDF of the answer key
  void _generateAndPrintAnswerKeyPdf() async {
    await _fetchQuestions();
    await PdfGenerator(context).generateTestAnswerKeyPdf(widget.testId, widget.testTitle);
  }

  /// Navigation method to grade the test for a specific class
  void _navigateToGradeTestScreen(int classId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestGradeScreen(
          classId: classId,
          testTitle: widget.testTitle,
          testId: widget.testId,
        ),
      ),
    );
  }

  /// Method to show a dialog to choose a class for grading
  void _showChooseClassDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ChooseClassDialog(
          onClassSelected: (classId) {
            Navigator.of(context).pop();
            _navigateToGradeTestScreen(classId);
          },
          subjectId: widget.subjectId,
        );
      },
    );
  }

  /// Method to update the order of questions
  void _updateQuestionOrder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _questions.removeAt(oldIndex);
      _questions.insert(newIndex, item);

      // Update the order in the database and SharedPreferences
      _updateOrderInDatabase();
      _saveOrderToPreferences();
    });
  }

  /// Method to update question order in the database
  Future<void> _updateOrderInDatabase() async {
    for (int i = 0; i < _questions.length; i++) {
      await DatabaseHelper().updateQuestionOrder(_questions[i]['id'], i);
    }
  }

  /// Method to save question order to SharedPreferences
  Future<void> _saveOrderToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> order = _questions.map((question) => question['id'].toString()).toList();
    await prefs.setStringList('test_${widget.testId}_order', order);
  }

  /// show tutorial dialog for test detail screen
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TestDetailScreenTutorialDialog();
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: DeepPurple,
        foregroundColor: White,
        title: Row(
          children: [
          Text(widget.testTitle),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Use the back arrow icon
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => TestsScreen()),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: _showChooseClassDialog,
            style: TextButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              'GRADE',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
          children: [
      SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80.0), // Padding to avoid overlap with buttons
      child: _questions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text('No questions available. Please add!', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: White,
                foregroundColor: DeepPurple,
                side: const BorderSide(width: 2, color: DeepPurple),
                padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 12), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _navigateToAddQuestionScreen,
              child: Text('Add Question +', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      )
          : Column(
        children: [
        ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Disable scrolling for ReorderableListView
        onReorder: _updateQuestionOrder,
        children: [
          for (int index = 0; index < _questions.length; index++)
            ListTile(
              key: ValueKey(_questions[index]['id']),
              title: Text(_questions[index]['text']),
              subtitle: Text('Type: ${_questions[index]['type']}'),
              onTap: () => _navigateToQuestionDetailScreen(_questions[index]['id']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToEditQuestionScreen(_questions[index]['id']),
                  ),
                  const SizedBox(height: 20),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmationDialog(_questions[index]['id']),
                    ),

                ],
              ),
            ),
        ],
      ),
      const SizedBox(height: 20),
      ElevatedButton(
      style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: DeepPurple,
      side: const BorderSide(width: 2, color: DeepPurple),
      padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 12), // Button padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
      onPressed: _navigateToAddQuestionScreen,
      child: Text('Add Question +', style: TextStyle(fontSize: 20)),
    ),
    ],
    ),
    ),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton(
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  MediaQuery.of(context).size.width - 48, // 48 is the size of the FAB plus some margin
                  MediaQuery.of(context).size.height - 112, // Position the menu above the FAB
                  16, // Padding from right
                  16, // Padding from bottom
                ),
                items: [
                  PopupMenuItem<int>(
                    value: 0,
                    child: TextButton(
                      onPressed: _generateAndPrintQuestionsPdf,
                      child: const Row(
                        children: [
                          Icon(Icons.print),
                          SizedBox(width: 8),
                          Text('Print Questions'),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: TextButton(
                      onPressed: _generateAndPrintAnswerKeyPdf,
                      child: const Row(
                        children: [
                          Icon(Icons.print),
                          SizedBox(width: 8),
                          Text('Print Answer Key'),
                        ],
                      ),
                    ),
                  ),
                ],
                elevation: 8.0,
              );
            },
            child: const Icon(Icons.print),
          ),
        ),
      ),
    ],
    ),
    );
  }
}

class ChooseClassDialog extends StatefulWidget {
  final Function(int) onClassSelected;
  final int subjectId;

  const ChooseClassDialog({super.key, required this.onClassSelected, required this.subjectId});

  @override
  _ChooseClassDialogState createState() => _ChooseClassDialogState();
}

class _ChooseClassDialogState extends State<ChooseClassDialog> {
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;
  String subjName = "";

  @override
  void initState() {
    super.initState();
    _fetchClassesBySubjectId();
  }

  ///fetch classes from database based on subject id
  Future<void> _fetchClassesBySubjectId() async {
    final data = await DatabaseHelper().getClassesBySubjectId(widget.subjectId);
    String? name = await DatabaseHelper().getSubjectName(widget.subjectId);
    setState(() {
      _classes = data;
      _isLoading = false;
      subjName = name!;
    });
  }

  ///navigate to teacher dashboard
  void _navigateToTeacherDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const TeacherDashboard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Class'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No Classes Available For This Subject'),
          const SizedBox(height: 10),
          Text(subjName, style: const TextStyle(
              fontSize: 24, color: Colors.deepPurpleAccent)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: DeepPurple,
              side: const BorderSide(
                  width: 2, color: DeepPurple),
            ),
            onPressed: _navigateToTeacherDashboard,
            child: const Text('Go to Teacher Dashboard'),
          ),
        ],
      )
          : SizedBox(
        width: double.minPositive, // Adjust the width to fit the content
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _classes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_classes[index]['name']),
              onTap: () {
                widget.onClassSelected(_classes[index]['id']);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}