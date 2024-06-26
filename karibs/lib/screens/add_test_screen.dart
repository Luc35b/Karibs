import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';

class AddTestScreen extends StatefulWidget {
  final Function onTestAdded;

  const AddTestScreen({super.key, required this.onTestAdded});

  @override
  _AddTestScreenState createState() => _AddTestScreenState();
}

class _AddTestScreenState extends State<AddTestScreen> {
  final TextEditingController _titleController = TextEditingController();

  /// Function to add a new test/exam to the database.
  /// Validates input and shows appropriate error messages if conditions are not met.
  void _addTest() async {
    if (_titleController.text.isNotEmpty) {
      // Insert test into the database
      await DatabaseHelper().insertTest({
        'title': _titleController.text,
      });

      // Call the callback function provided by the parent widget
      widget.onTestAdded();

      // Close the current screen and navigate back
      Navigator.of(context).pop();
    } else {
      // Show error message if title field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Exam'), // Set app bar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'), // Input field for exam title
            ),
            const SizedBox(height: 16), // Add spacing between text field and button
            ElevatedButton(
              onPressed: _addTest,
              child: const Text('Add Exam'), // Button to add the exam/test
            ),
          ],
        ),
      ),
    );
  }
}