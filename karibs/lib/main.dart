import 'package:flutter/material.dart';
import 'screens/teacher_screen.dart';
import 'screens/student_screen.dart';
import 'database/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

const Color DeepPurple = Color(0xFF250A4E);
const Color MidPurple = Color(0xFFCBB5D6);
const Color LightPurple = Color(0xFFEFDAF9);
const Color NotWhite = Color(0xFFEFEBF1);
const Color White = Colors.white;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().deleteDatabaseFile(); // Delete the existing database
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KLAS Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: DeepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
            color: White
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 25),
              Image.asset('images/logo.jpg'),
              Text('WELCOME TO', style: GoogleFonts.raleway(fontSize: 34, color: DeepPurple)),
              Expanded(
                child: Text('KLAS', style: GoogleFonts.raleway(fontSize: 50, fontWeight: FontWeight.bold, color: DeepPurple)),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 35.0, horizontal: 35), // Padding inside the container
                decoration: BoxDecoration(
                  color: DeepPurple,
                  border: Border.all(width: 2, color: DeepPurple),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(30),
                  ),

                  //borderRadius: BorderRadius.circular(30), // Rounded corners for all
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(3, 3), // Shadow position
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('CHOOSE USER TYPE', style: GoogleFonts.raleway(fontSize: 28, fontWeight: FontWeight.bold, color: White)),
                    SizedBox(height: 24),
                    Column(
                      children:[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TeacherScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: White,
                            foregroundColor: Colors.white,
                            side: BorderSide(width: 2, color: MidPurple),
                            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 18), // Button padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: Text('I\'m a Teacher', style: GoogleFonts.raleway(fontSize: 28, color: DeepPurple)),
                        ),
                        SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => StudentScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: White,
                            foregroundColor: Colors.white,
                            side: BorderSide(width: 2, color: MidPurple),
                            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 18), // Button padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: Text('I\'m a Student', style: GoogleFonts.raleway(fontSize: 28, color: DeepPurple)),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              SizedBox(height: 10),

            ],
          ),
        ),
      ),
    );
  }
}