import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';

class TestGradeScreen extends StatefulWidget {
  final int classId;
  final String testTitle;

  TestGradeScreen({required this.classId, required this.testTitle});

  @override
  _TestGradeScreenState createState() => _TestGradeScreenState();
}

class _TestGradeScreenState extends State<TestGradeScreen> {
  String? _className;
  bool _isLoading = true;
  List<Map<String, dynamic>> _students = [];
  String? _selectedStudent;

  @override
  void initState() {
    super.initState();
    _fetchClassName();
    _fetchStudents();
  }

  Future<void> _fetchClassName() async {
    String? className = await DatabaseHelper().getClassName(widget.classId);
    setState(() {
      _className = className;

    });
  }

  Future<void> _fetchStudents() async {
    List<Map<String, dynamic>> studentsRetrieved = await DatabaseHelper().queryAllStudents(widget.classId);

    setState(() {
      _students = studentsRetrieved;
      _isLoading = false;
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Test for ${widget.testTitle}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_className != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Grading details for class $_className and test ${widget.testTitle}',
                style: TextStyle(fontSize: 20),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: Text("Select Student"),
              value: _selectedStudent,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStudent = newValue;
                });
              },
              items: _students.map<DropdownMenuItem<String>>((Map<String, dynamic> student) {
                return DropdownMenuItem<String>(
                  value: student['name'],
                  child: Text(student['name']),
                );
              }).toList(),
            ),
          ),
          if (_selectedStudent != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Selected Student: $_selectedStudent',
                style: TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }
}
