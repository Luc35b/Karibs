import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karibs/database/database_helper.dart';
import 'edit_question_screen.dart';
import 'add_question_screen.dart';
import 'question_detail_screen.dart';
import 'package:karibs/pdf_gen.dart';
import 'test_grade_screen.dart';

class TestDetailScreen extends StatefulWidget {
  final int testId;
  final String testTitle;

  const TestDetailScreen({super.key, required this.testId, required this.testTitle});

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

  Future<void> _fetchQuestions() async {
    final data = await DatabaseHelper().queryAllQuestions(widget.testId);
    setState(() {
      _questions = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  }

  void _navigateToAddQuestionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(
          testId: widget.testId,
          onQuestionAdded: _fetchQuestions,
        ),
      ),
    );
  }

  void _navigateToQuestionDetailScreen(int questionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionDetailScreen(questionId: questionId),
      ),
    );
  }

  void _navigateToEditQuestionScreen(int questionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuestionScreen(
          questionId: questionId,
          onQuestionUpdated: _fetchQuestions,
        ),
      ),
    );
  }

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

  void _deleteQuestion(int questionId) async {
    await DatabaseHelper().deleteQuestion(questionId);
    _fetchQuestions();
  }

  void _generateAndPrintQuestionsPdf() async {
    await _fetchQuestions();
    await PdfGenerator().generateTestQuestionsPdf(widget.testId, widget.testTitle);
  }

  void _generateAndPrintAnswerKeyPdf() async {
    await _fetchQuestions();
    await PdfGenerator().generateTestAnswerKeyPdf(widget.testId, widget.testTitle);
  }

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

  void _showChooseClassDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ChooseClassDialog(
          onClassSelected: (classId) {
            Navigator.of(context).pop();
            _navigateToGradeTestScreen(classId);
          },
        );
      },
    );
  }

  void _updateQuestionOrder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _questions.removeAt(oldIndex);
      _questions.insert(newIndex, item);

      // Update the order in the database
      _updateOrderInDatabase();
    });
  }

  Future<void> _updateOrderInDatabase() async {
    for (int i = 0; i < _questions.length; i++) {
      await DatabaseHelper().updateQuestionOrder(_questions[i]['id'], i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        title: Text(widget.testTitle),
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
                  Text('No questions available. Please add!', style: GoogleFonts.raleway(fontSize: 20)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      side: const BorderSide(width: 2, color: Colors.deepPurple),
                      padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 12), // Button padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _navigateToAddQuestionScreen,
                    child: Text('Add Question +', style: GoogleFonts.raleway(fontSize: 20)),
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
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteConfirmationDialog(_questions[index]['id']),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _questions.isNotEmpty
                  ? ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.deepPurple,
    side: const BorderSide(width: 2, color: Colors.deepPurple),
    padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 12), // Button padding
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
    ),
    ),
    onPressed: _navigateToAddQuestionScreen,
    child: Text('Add Question +', style: GoogleFonts.raleway(fontSize: 20)),
    )
                  : Container(),
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
                    position: const RelativeRect.fromLTRB(0.0, 0.0, 1.0, 1.0),
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
                      PopupMenuItem<int>(
                        value: 2,
                        child: TextButton(
                          onPressed: _showChooseClassDialog,
                          child: const Row(
                            children: [
                              Icon(Icons.grade),
                              SizedBox(width: 8),
                              Text('Grade'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    elevation: 8.0,
                  );
                },
                child: const Icon(Icons.menu),
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

  const ChooseClassDialog({super.key, required this.onClassSelected});

  @override
  _ChooseClassDialogState createState() => _ChooseClassDialogState();
}

class _ChooseClassDialogState extends State<ChooseClassDialog> {
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    final data = await DatabaseHelper().queryAllClasses();
    setState(() {
      _classes = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Choose Class'),
    content: _isLoading
        ? const Center(child: CircularProgressIndicator())
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

