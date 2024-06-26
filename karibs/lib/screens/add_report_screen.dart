import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/main.dart';
import 'package:karibs/overlay.dart';

class AddReportScreen extends StatefulWidget {
  final int studentId;

  const AddReportScreen({super.key, required this.studentId});

  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();

  /// Function to add a new report to the database.
  /// Validates input and shows appropriate error messages if conditions are not met.
  void _addReport() async {
    String scoreText = scoreController.text;
    double? score = scoreText.isNotEmpty ? double.tryParse(scoreText) : null;
    // Validate title is not empty
    if (titleController.text.isNotEmpty) {
      if( score != null && (score < 0 || score > 100)){
        // Validate score is within the valid range
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Score must be a number between 0 and 100'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      // Validate that either notes or score is provided
      if(notesController.text.isEmpty && scoreController.text.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report must have either notes or a exam score'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Insert report into the database
      await DatabaseHelper().insertReport({
        'date': DateTime.now().toIso8601String(),
        'title': titleController.text,
        'notes': notesController.text,
        'score': score,
        //'score': scoreController.text.isNotEmpty ? int.parse(scoreController.text) : null,
        'student_id': widget.studentId,
      });
      Navigator.of(context).pop(true); // Pop the screen and pass true as result
    }
  }

  /// Function to show a tutorial dialog when the help icon is pressed.
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddReportScreenTutorialDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back), // Use the back arrow icon
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            const Text('Add New Report'),
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
        backgroundColor: DeepPurple,
        foregroundColor: White,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                keyboardType: TextInputType.multiline,
                maxLines: 5,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: scoreController,
                decoration: const InputDecoration(labelText: 'Score (optional)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,2})?')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      side: const BorderSide(width: 2, color: Colors.deepPurple),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false); // Cancel action
                    },
                    child: const Text('Cancel', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      side: const BorderSide(width: 2, color: Colors.deepPurple),
                    ),
                    onPressed: _addReport,
                    child: const Text('Add', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
