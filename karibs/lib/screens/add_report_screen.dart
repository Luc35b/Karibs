import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';

class AddReportScreen extends StatefulWidget {
  final int studentId;

  AddReportScreen({required this.studentId});

  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();

  void _addReport() async {
    if (titleController.text.isNotEmpty && notesController.text.isNotEmpty) {
      await DatabaseHelper().insertReport({
        'date': DateTime.now().toIso8601String(),
        'title': titleController.text,
        'notes': notesController.text,
        'score': scoreController.text.isNotEmpty ? int.parse(scoreController.text) : null,
        'student_id': widget.studentId,
      });
      Navigator.of(context).pop(true); // Pop the screen and pass true as result
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(labelText: 'Notes'),
            ),
            SizedBox(height: 32),
            TextField(
              controller: scoreController,
              decoration: InputDecoration(labelText: 'Score (optional)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Cancel action
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addReport,
                  child: Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
