import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/main.dart';
import 'edit_question_screen.dart';

class QuestionDetailScreen extends StatefulWidget {
  final int questionId;
  final int subjectId; // Added subjectId to pass to EditQuestionScreen

  const QuestionDetailScreen({super.key, required this.questionId, required this.subjectId});

  @override
  _QuestionDetailScreenState createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  Map<String, dynamic>? _question;
  List<Map<String, dynamic>> _choices = [];
  bool _isLoading = true;
  String? category;

  @override
  void initState() {
    super.initState();
    _fetchQuestionDetails();
    _fetchCategory();
  }

  //fetch category name from database
  Future<void> _fetchCategory() async {
    String? cat = await DatabaseHelper().getCategoryNameFromQuestion(widget.questionId);
    setState(() {
      category = cat;
    });
  }

  //fetch question details and choices from database
  Future<void> _fetchQuestionDetails() async {
    final question = await DatabaseHelper().queryQuestion(widget.questionId);
    final choices = await DatabaseHelper().queryAllQuestionChoices(widget.questionId);
    setState(() {
      _question = question;
      _choices = choices;
      _isLoading = false;
    });
  }

  //Navigate to EditQuestionScreen for editing the current question
  void _navigateToEditQuestionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuestionScreen(
          questionId: widget.questionId,
          onQuestionUpdated: _fetchQuestionDetails,
          subjectId: widget.subjectId, // Pass subjectId to EditQuestionScreen
        ),
      ),
    ).then((_){
      _fetchQuestionDetails();
      _fetchCategory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: White,
        backgroundColor: DeepPurple,
        title: const Text('Question Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditQuestionScreen,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _question == null
          ? const Center(child: Text('Question not found'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //displays question text and choices
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Question: ${_question!['text']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '$category',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_choices.isNotEmpty)
              const Text(
                'Choices:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ..._choices.map((choice) {
              return ListTile(
                title: Text(choice['choice_text']),
                trailing: choice['is_correct'] == 1 ? const Icon(Icons.check, color: Colors.green) : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
