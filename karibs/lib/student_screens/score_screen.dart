import 'package:flutter/material.dart';
import 'package:karibs/screens/student_screen.dart';

class ScoreScreen extends StatelessWidget {
  final double grade;

  ScoreScreen({required this.grade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Score: ${(grade * 100).toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentScreen(),
                  ),
                ); // Navigate back to the previous screen (home page)
              },
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
