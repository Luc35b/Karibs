import 'package:flutter/material.dart';

class p1t3 extends StatelessWidget {
  final String examName;

  p1t3(this.examName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Primary 1: Exam 3'),
      ),
      body: Center(
        child: Text('Details for $examName'),
      ),
    );
  }
}