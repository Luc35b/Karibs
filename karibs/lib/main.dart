import 'package:flutter/material.dart';
import 'package:karibs/overlay.dart';
import 'package:karibs/providers/student_grading_provider.dart';
import 'screens/teacher_dashboard.dart';
import 'student_screens/student_screen.dart';
import 'database/database_helper.dart';
import 'package:provider/provider.dart';

//color scheme across the app
const Color DeepPurple = Color(0xFF250A4E);
const Color MidPurple = Color(0xFF7c6c94);
const Color LightPurple = Color(0xFFD3BEFA);
const Color NotWhite = Color(0xFFEFEBF1);
const Color White = Colors.white;

//runs the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().deleteDatabaseFile(); // Delete the existing database, remove when done testing
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StudentGradingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KLAS Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
      routes: {
        '/teacherDashboard': (context) => const TeacherDashboard(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  bool _isAnimating = false;
  bool _showTutorial = true; // Flag to control showing tutorial dialog

  @override
  void initState() {
    super.initState();
    // Show the tutorial dialog when the screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showTutorial) {
        _showMainTutorialDialog();
        _showTutorial = false; // Set to false to prevent showing again on subsequent launches
      }
    });
  }

  //displays the tutorial dialog for the main screen
  void _showMainTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MainTutorialDialog();

      },
    );
  }

  //navigate to a given screen
  void _navigateToScreen(Widget screen) {
    setState(() {
      _isAnimating = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ).then((_) {
        setState(() {
          _isAnimating = false;
        });
      });
    });
  }

  //chooses user type and navigates to teacher dashboard or student dashboard
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Choose User Type'),
            SizedBox(width: 8), // Adjust spacing between title and icon
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                // Show tutorial dialog
                _showMainTutorialDialog();
              },
            ),
          ],
        ),
        backgroundColor: DeepPurple,
        foregroundColor: White,

      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            transform: Matrix4.translationValues(0, _isAnimating ? 600 : 0, 0),
            child: AnimatedOpacity(
              opacity: _isAnimating ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 45),
                          Image.asset('images/logo.jpg'),
                          Text(
                            'WELCOME TO',
                            style: TextStyle(fontSize: 34, color: DeepPurple),
                          ),
                          Text(
                            'KLAS',
                            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: DeepPurple),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20.0),
                            padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 35),
                            decoration: BoxDecoration(
                              color: DeepPurple,
                              border: Border.all(width: 2, color: DeepPurple),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(5),
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(30),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'CHOOSE USER TYPE',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _navigateToScreen(const TeacherDashboard()),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(width: 2, color: DeepPurple),
                                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      child: Text(
                                        'I\'m a Teacher',
                                        style: TextStyle(fontSize: 28, color: DeepPurple, fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    ElevatedButton(
                                      onPressed: () => _navigateToScreen(const StudentScreen()),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(width: 2, color: DeepPurple),
                                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      child: Text(
                                        'I\'m a Student',
                                        style: TextStyle(fontSize: 28, color: DeepPurple, fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
