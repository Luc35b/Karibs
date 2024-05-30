import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'add_question_screen.dart';
import 'question_detail_screen.dart';
import 'package:karibs/pdf_gen.dart';
import 'test_grade_screen.dart';

class TestDetailScreen extends StatefulWidget {
  final int testId;
  final String testTitle;

  TestDetailScreen({required this.testId, required this.testTitle});

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
      _questions = data;
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
          builder: (context) => TestGradeScreen(classId: classId, testTitle: widget.testTitle, testId: widget.testId)
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testTitle),
        actions: [IconButton(
          onPressed: _showChooseClassDialog,
          icon: Icon(Icons.class_),
        )],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _questions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No questions available. Please add!'),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _navigateToAddQuestionScreen,
              child: Icon(Icons.add),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_questions[index]['text']),
            subtitle: Text('Type: ${_questions[index]['type']}'),
            onTap: () => _navigateToQuestionDetailScreen(_questions[index]['id']),
          );
        },
      ),
      bottomNavigationBar: _questions.isNotEmpty
          ? BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: _generateAndPrintQuestionsPdf,
                  child: FittedBox(
                    child: Row(
                      children: [
                        Icon(Icons.print),
                        SizedBox(width: 4),
                        Text('Print Questions'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: ElevatedButton(
                  onPressed: _generateAndPrintAnswerKeyPdf,
                  child: FittedBox(
                    child: Row(
                      children: [
                        Icon(Icons.print),
                        SizedBox(width: 4),
                        Text('Print Answer Key'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : null,
      floatingActionButton: _questions.isEmpty
          ? null
          : FloatingActionButton(
        onPressed: _navigateToAddQuestionScreen,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ChooseClassDialog extends StatefulWidget {
  final Function(int) onClassSelected;

  ChooseClassDialog({required this.onClassSelected});

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
      title: Text('Choose Class'),
      content: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
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
          child: Text('Cancel'),
        ),
      ],
    );
  }
}

