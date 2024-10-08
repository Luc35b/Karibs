import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:karibs/main.dart';
import 'package:karibs/screens/regrade_test_screen.dart';
import 'package:karibs/overlay.dart';

/// The `ViewTestGradeScreen` displays the detailed grades of a particular test.
/// It displays details about the student's responses to the questions like whether they got it correct or incorrect,
/// along with the correct answers for the question for easy review
class ViewTestGradeScreen extends StatefulWidget {
  final int reportId;

  const ViewTestGradeScreen({super.key, required this.reportId});

  @override
  _ViewTestGradeScreenState createState() => _ViewTestGradeScreenState();
}

class _ViewTestGradeScreenState extends State<ViewTestGradeScreen> {
  bool _isLoading = true;  // Indicates if the data is still loading
  List<Map<String, dynamic>> _questions = [];  // List of questions related to the report
  Map<int, List<Map<String, dynamic>>> _choices = {};  // Choices grouped by question_id

  @override
  void initState() {
    super.initState();
    _fetchQuestionsAndAnswers();
  }

  /// Fetches questions and answers for the specific report from the database.
  Future<void> _fetchQuestionsAndAnswers() async {
    final dbHelper = DatabaseHelper();
    final result = await dbHelper.getQuestionsAndAnswersForReport(widget.reportId);

    setState(() {
      _questions = result['questions'];

      // Group relevant choices by question_id
      _choices = {};
      for (var choice in result['choices']) {
        int questionId = choice['question_id'];
        if (_choices[questionId] == null) {
          _choices[questionId] = [];
        }
        _choices[questionId]!.add(choice);
      }

      _isLoading = false;
    });
  }

  /// Navigates to the `RegradeTestScreen`.
  void _navigateToRegradeScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegradeTestScreen(
          reportId: widget.reportId,
        ),
      ),
    ).then((_){_fetchQuestionsAndAnswers();});
  }

  /// Shows a tutorial dialog.
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ViewTestGradeScreenTutorialDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: White,
        backgroundColor: DeepPurple,
        title: Row(
          children: [
            Text('Exam Grade Details'),
            SizedBox(width: 8), // Adjust spacing between title and icon
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: _showTutorialDialog, // Show tutorial dialog
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _navigateToRegradeScreen(context); // Navigate to RegradeScreen
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: Colors.green[100],
                    ),
                    SizedBox(width: 8),
                    Text('Correct', style: TextStyle(color: Colors.green)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: Colors.red[100],
                    ),
                    SizedBox(width: 8),
                    Text('Incorrect', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return Card(
                  margin: const EdgeInsets.all(10.0),
                  color: question['got_correct'] == 1 ? Colors.green[100] : Colors.red[100],
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question['question_text'],
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Category:  ${question['question_category']}'),
                        const Divider(),
                        const Text(
                          'Choices:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...(_choices[question['question_id']] ?? []).map((choice) {
                          return ListTile(
                            title: Text(choice['choice_text']),
                            trailing: Icon(
                              choice['is_correct'] == 1 ? Icons.check : Icons.close,
                              color: choice['is_correct'] == 1 ? Colors.green : Colors.red,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
