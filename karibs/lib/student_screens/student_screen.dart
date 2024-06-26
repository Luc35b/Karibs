import 'package:flutter/material.dart';
import 'p1t1.dart';
import 'p1t2.dart';
import 'p1t3.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // total duration of all animations
    );
    _controller.forward(); // start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildSlideTransition(int index, String grade, List<String> exams) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double start = index * 0.1;
        double end = start + 0.2;
        if (end > 1.0) end = 1.0;

        final animation = Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.fastOutSlowIn),
          ),
        );

        return SlideTransition(
          position: animation,
          child: child,
        );
      },
      child: GradeLevelCard(
        grade: grade,
        exams: exams,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Screen'),
      ),
      body: ListView(
        children: [
          buildSlideTransition(0, 'Primary 1', ['Exam 1', 'Exam 2', 'Exam 3']),
          buildSlideTransition(1, 'Primary 2', ['Exam 1', 'Exam 2', 'Exam 3']),
          buildSlideTransition(2, 'Primary 3', ['Exam 1', 'Exam 2', 'Exam 3']),
          buildSlideTransition(3, 'Primary 4', ['Exam 1', 'Exam 2', 'Exam 3']),
          buildSlideTransition(4, 'Primary 5', ['Exam 1', 'Exam 2', 'Exam 3']),
          buildSlideTransition(5, 'Primary 6', ['Exam 1', 'Exam 2', 'Exam 3']),
          // Add more SlideTransition widgets for other grade levels
        ],
      ),
    );
  }
}

class GradeLevelCard extends StatelessWidget {
  final String grade;
  final List<String> exams;

  const GradeLevelCard({super.key, required this.grade, required this.exams});

  @override
  Widget build(BuildContext context) {
    void chooseScreen(int index) {
      if (grade == 'Primary 1' && index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const P1T1(),
          ),
        );
      } else if (grade == 'Primary 1' && index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const P1T2(),
          ),
        );
      } else if (grade == 'Primary 1' && index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const P1T3(),
          ),
        );
      }
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              grade,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: exams.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to new page when test box is clicked
                    chooseScreen(index);
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(15), // Adjust the radius as needed
                    ),
                    child: Center(
                      child: Text(
                        exams[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
