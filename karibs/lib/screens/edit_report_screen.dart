import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/main.dart';
import 'package:karibs/overlay.dart';


class EditReportScreen extends StatefulWidget {
  final int reportId;

  const EditReportScreen({super.key, required this.reportId});

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
      await _databaseHelper.deleteReport(widget.reportId);

      Navigator.of(context).pop(true);
      Navigator.of(context).pop(true);
    }
  }

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
                Navigator.of(context).pop(true);
              },
            ),
            const Text('Edit Report'),
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                // Show tutorial dialog
                _showTutorialDialog();
              },
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: _deleteReport, icon: Icon(Icons.delete)),
        ],
        backgroundColor: DeepPurple,
        foregroundColor: White,
        automaticallyImplyLeading: false,
      ),
      // appBar: AppBar(
      //   title: const Text('Edit Report'),
      //   backgroundColor: DeepPurple,
      //   foregroundColor: White,
      //   actions: [
      //
      //     IconButton(onPressed: _deleteReport, icon: const Icon(Icons.delete)),
      //   ],
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              keyboardType: TextInputType.multiline,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _scoreController,
              decoration: const InputDecoration(labelText: 'Score'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: DeepPurple,
                side: const BorderSide(
                    width: 2, color: DeepPurple),
              ),
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
