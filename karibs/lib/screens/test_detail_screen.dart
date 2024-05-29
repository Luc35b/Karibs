import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'add_question_screen.dart';
import 'question_detail_screen.dart';
import 'package:karibs/pdf_gen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testTitle),
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
      bottomNavigationBar: BottomAppBar(
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
      ),
    );
  }
}