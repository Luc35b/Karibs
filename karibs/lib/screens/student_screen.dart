import 'package:flutter/material.dart';

class StudentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Screen'),
      ),
      body: Center(
        child: Text(
          'Welcome, Student!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
