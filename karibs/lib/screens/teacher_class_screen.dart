import 'package:flutter/material.dart';
import 'student_info_screen.dart';

class TeacherClassScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Class Screen'),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(students[index]),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentInfoScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}

List<String> students = [
  'Student 1',
  'Student 2',
  'Student 3',
  // Add more students here
];
