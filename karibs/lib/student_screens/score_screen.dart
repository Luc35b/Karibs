import 'package:flutter/material.dart';
import 'package:karibs/student_screens/student_screen.dart';

class ScoreScreen extends StatelessWidget {
  final double grade;

  const ScoreScreen({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Score: ${(grade * 100).toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentScreen(),
                  ),
                ); // Navigate back to the previous screen (home page)
              },
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
