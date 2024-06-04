import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';

class EditReportScreen extends StatefulWidget {
  final int reportId;

  EditReportScreen({required this.reportId});

  @override
  _EditReportScreenState createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  Map<String, dynamic> report = {};
  int studentId = 0;
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

  void _fetchReport() async {
    var x = await _databaseHelper.queryReport(widget.reportId);

    if (x != null) {

      setState(() {

        report = x;

        _titleController.text = report['title'];
        _notesController.text = report['notes'];
        _scoreController.text = report['score'].toString();
        studentId = x['student_id'];
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

  void _saveChanges() async {
    String newTitle = _titleController.text;
    String newNotes = _notesController.text;
    double newScore = double.tryParse(_scoreController.text) ?? report['score'];


    await _databaseHelper.updateReportTitle(widget.reportId, newTitle);
    await _databaseHelper.updateReportNotes(widget.reportId, newNotes);
    await _databaseHelper.updateReportScore(widget.reportId, newScore);



    Navigator.of(context).pop(true);
  }

  void _deleteReport() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Report'),
        content: Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _databaseHelper.deleteReport(widget.reportId);

      Navigator.of(context).pop(true);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Report'),
        actions: [
          IconButton(onPressed: _deleteReport, icon: Icon(Icons.delete)),
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
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
