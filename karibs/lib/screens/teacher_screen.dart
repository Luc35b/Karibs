import 'package:flutter/material.dart';
import 'package:karibs/screens/classes_screen.dart';
import 'package:karibs/screens/tests_screen.dart';

class TeacherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClassesScreen()),
                );
              },
              child: Text('Classes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestsScreen()),
                );
              },
              child: Text('Tests'),
            ),
          ],
        ),
      ),
    );
  }
}
