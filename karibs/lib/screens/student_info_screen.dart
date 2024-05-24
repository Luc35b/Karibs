import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';

class StudentInfoScreen extends StatefulWidget {
  final int studentId;

  StudentInfoScreen({required this.studentId});

  @override
  _StudentInfoScreenState createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  Map<String, dynamic>? _student;
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    final student = await DatabaseHelper().queryStudent(widget.studentId);
    final reports = await DatabaseHelper().queryAllReports(widget.studentId);
    setState(() {
      _student = student;
      _reports = reports;
      _isLoading = false;
    });
  }

  void _addReport(String title, String notes, int? score) async {
    await DatabaseHelper().insertReport({
      'date': DateTime.now().toIso8601String(),
      'title': title,
      'notes': notes,
      'score': score,
      'student_id': widget.studentId,
    });
    _fetchStudentData();
  }

  void _showAddReportDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController scoreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Notes'),
              ),
              TextField(
                controller: scoreController,
                decoration: InputDecoration(labelText: 'Score (optional)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && notesController.text.isNotEmpty) {
                  _addReport(
                    titleController.text,
                    notesController.text,
                    scoreController.text.isNotEmpty ? int.parse(scoreController.text) : null,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_student != null ? _student!['name'] : 'Student Info'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _reports.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No reports available. Please add!'),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _showAddReportDialog,
              child: Icon(Icons.add),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          ListView.builder(
            itemCount: _reports.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_reports[index]['title']),
                subtitle: Text(_reports[index]['notes']),
                trailing: Text(_reports[index]['score']?.toString() ?? ''),
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _showAddReportDialog,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
