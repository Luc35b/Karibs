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
  String? _selectedStatus;

  final List<String> _statuses = ['Doing well', 'Doing okay', 'Needs help'];

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
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: _statuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
              decoration: InputDecoration(labelText: 'Status'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addStudent,
              child: Text('Add Student'),
            ),
          ],
        ),
      ),
    );
  }
}
