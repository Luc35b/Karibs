import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/screens/report_detail_screen.dart';

class EditReportScreen extends StatefulWidget {
  final Map<String, dynamic> report;

  EditReportScreen({required this.report});

  @override
  _EditReportScreenState createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _scoreController;
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _titleController = TextEditingController(text: widget.report['title']);
    _notesController = TextEditingController(text: widget.report['notes']);
    _scoreController = TextEditingController(text: widget.report['score'].toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    String newTitle = _titleController.text;
    String newNotes = _notesController.text;
    int newScore = int.tryParse(_scoreController.text) ?? 0;

    // Update the report details in the database
    await _databaseHelper.updateReportTitle(widget.report['id'], newTitle);
    await _databaseHelper.updateReportNotes(widget.report['id'], newNotes);
    await _databaseHelper.updateReportScore(widget.report['id'], newScore);

    setState(() {
      widget.report['title'] = newTitle;
      widget.report['notes'] = newNotes;
      widget.report['score'] = newScore;
    });
  }

  void _deleteReport() async {
    // Show a confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Student'),
        content: Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: Text('Delete'),
          ),
        ],
      ),
    );
    // Delete the student if confirmed
    if (confirmDelete == true) {
      await DatabaseHelper().deleteReport(widget.report['id']);
      Navigator.pop(context, true);
      Navigator.pop(context, true);// Navigate back to the previous screen
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Report'),
        actions: [
          IconButton(onPressed: _deleteReport, icon: Icon(Icons.delete))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _scoreController,
              decoration: InputDecoration(labelText: 'Score'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveChanges();
                Navigator.of(context).pop(widget.report);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
