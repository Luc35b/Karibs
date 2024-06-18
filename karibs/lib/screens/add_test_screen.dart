import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';

class AddTestScreen extends StatefulWidget {
  final Function onTestAdded;

  AddTestScreen({required this.onTestAdded});

  @override
  _AddTestScreenState createState() => _AddTestScreenState();
}

class _AddTestScreenState extends State<AddTestScreen> {
  final TextEditingController _titleController = TextEditingController();

  void _addTest() async {
    if (_titleController.text.isNotEmpty) {
      await DatabaseHelper().insertTest({
        'title': _titleController.text,
      });
      widget.onTestAdded();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Exam'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTest,
              child: Text('Add Exam'),
            ),
          ],
        ),
      ),
    );
  }
}
