import 'package:flutter/material.dart';

class StudentInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Info'),
      ),
      body: const Column(
        children: [
          // Student's name
          Text(
            'Student Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Average score
          Text(
            'Average Score: 90',
            style: TextStyle(
              fontSize: 18,
            ),
          ),

          // Graph of score points
          // TODO: Implement the graph widget here

          // List of reports
          // TODO: Implement the list of reports widget here
        ],
      ),
    );
  }
}
