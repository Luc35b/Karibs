import 'package:flutter/material.dart';
import 'package:karibs/screens/teacher_dashboard.dart';
import 'package:karibs/screens/tests_screen.dart';

const Color DeepPurple = Color(0xFF250A4E);
const Color MidPurple = Color(0xFFCBB5D6);
const Color LightPurple = Color(0xFFEFDAF9);
const Color NotWhite = Color(0xFFEFEBF1);
const Color White = Colors.white;

class TeacherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Screen'),
        backgroundColor: DeepPurple,
        foregroundColor: White,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background color
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text('My Classes',
                style: TextStyle(fontSize: 24),
              ),

            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background color
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text('  My Tests  ',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
