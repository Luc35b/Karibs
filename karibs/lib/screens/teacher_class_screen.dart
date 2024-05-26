import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'student_info_screen.dart';
import 'add_student_screen.dart';

class TeacherClassScreen extends StatefulWidget {
  final int classId;

  TeacherClassScreen({required this.classId});

  @override
  _TeacherClassScreenState createState() => _TeacherClassScreenState();
}

class _TeacherClassScreenState extends State<TeacherClassScreen> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final data = await DatabaseHelper().queryAllStudents(widget.classId);
    setState(() {
      _students = data;
      _isLoading = false;
    });
  }

  void _addStudent(Map<String, dynamic> student) async {
    await DatabaseHelper().insertStudent(student);
    _fetchStudents();
  }

  void _navigateToAddStudentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStudentScreen(
          classId: widget.classId,
          onStudentAdded: (student) {
            _addStudent(student);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Class Screen'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _students.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No students available. Please add!'),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _navigateToAddStudentScreen,
              child: Icon(Icons.add),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          ListView.builder(
            itemCount: _students.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_students[index]['name']),
                subtitle: Text(_students[index]['status'] ?? 'No status'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentInfoScreen(studentId: _students[index]['id']),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _navigateToAddStudentScreen,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
