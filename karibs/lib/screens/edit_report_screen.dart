import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/overlay.dart';

class EditReportScreen extends StatefulWidget {
  final int reportId;

  const EditReportScreen({Key? key, required this.reportId}) : super(key: key);

  @override
  _EditReportScreenState createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  late Map<String, dynamic> report = {};
  late int studentId = 0;

  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _scoreController;
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
    _scoreController = TextEditingController();
    _databaseHelper = DatabaseHelper();
    _fetchReport();
  }

  // Fetches the report data from the database and updates the state
  void _fetchReport() async {
    var fetchedReport = await _databaseHelper.queryReport(widget.reportId);

    if (fetchedReport != null) {
      setState(() {
        report = fetchedReport;
        _titleController.text = report['title'];
        _notesController.text = report['notes'];
        _scoreController.text = report['score'].toString();
        studentId = report['student_id'];
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  // Saves the changes made to the report
  void _saveChanges() async {
    String newTitle = _titleController.text;
    String newNotes = _notesController.text;
    double newScore = double.tryParse(_scoreController.text) ?? report['score'];

    // Updates the report details in the database
    await _databaseHelper.updateReportTitle(widget.reportId, newTitle);
    await _databaseHelper.updateReportNotes(widget.reportId, newNotes);
    await _databaseHelper.updateReportScore(widget.reportId, newScore);

    // Navigate back with result
    Navigator.of(context).pop(true);
  }

  // Deletes the report after confirmation
  void _deleteReport() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      // Delete report from database and navigate back with result
      await _databaseHelper.deleteReport(widget.reportId);
      Navigator.of(context).pop(true);
      Navigator.of(context).pop(true); // Pop twice to go back to previous screen
    }
  }

  // Shows the tutorial dialog for the edit report screen
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditReportScreenTutorialDialog();
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
              icon: Icon(Icons.arrow_back), // Back arrow icon
              onPressed: () {
                Navigator.of(context).pop(true); // Pop with result true
              },
            ),
            const Text('Edit Report'), // Title of the app bar
            IconButton(
              icon: Icon(Icons.help_outline), // Help icon
              onPressed: () {
                // Show tutorial dialog
                _showTutorialDialog();
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _deleteReport,
            icon: Icon(Icons.delete), // Delete icon
          ),
        ],
        backgroundColor: Colors.deepPurple, // App bar background color
        foregroundColor: Colors.white, // App bar text color
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'), // Title input field
            ),
            const SizedBox(height: 16), // Spacer
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'), // Notes input field
              keyboardType: TextInputType.multiline,
              maxLines: 5,
            ),
            const SizedBox(height: 16), // Spacer
            TextField(
              controller: _scoreController,
              decoration: const InputDecoration(labelText: 'Score'), // Score input field
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16), // Spacer
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'), // Save changes button
            ),
          ],
        ),
      ),
    );
  }
}