import 'package:flutter/material.dart';

class AddStudentScreen extends StatefulWidget {
  final int classId;
  final Function onStudentAdded;

  AddStudentScreen({required this.classId, required this.onStudentAdded});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final TextEditingController _studentNameController = TextEditingController();
  String? _selectedStatus = 'No status';


  void _addStudent() {
    if (_studentNameController.text.isNotEmpty && _selectedStatus != null) {
      widget.onStudentAdded({
        'name': _studentNameController.text,
        'class_id': widget.classId,
        'status': _selectedStatus,
      });
      Navigator.of(context).pop();
    } else {
      // Show an error message or handle form validation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _studentNameController,
              decoration: InputDecoration(labelText: 'Student Name'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _addStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background color
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text('Add Student', style: TextStyle(fontSize: 24),),
            ),
          ],
        ),
      ),
    );
  }
}
