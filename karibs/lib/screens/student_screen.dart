import 'package:flutter/material.dart';
import 'package:karibs/database/database_students.dart';
import '../student_screens/p1t1.dart';
import '../student_screens/p1t2.dart';
import '../student_screens/p1t3.dart';

class StudentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Screen'),
      ),
      body: ListView(
        children: [
          GradeLevelCard(
            grade: 'Primary 1',
            exams: ['Exam 1', 'Exam 2', 'Exam 3'],
          ),
          GradeLevelCard(
            grade: 'Primary 2',
            exams: ['Exam 1', 'Exam 2', 'Exam 3'],
          ),
          GradeLevelCard(
            grade: 'Primary 3',
            exams: ['Exam 1', 'Exam 2', 'Exam 3'],
          ),
          GradeLevelCard(
            grade: 'Primary 4',
            exams: ['Exam 1', 'Exam 2', 'Exam 3'],
          ),
          GradeLevelCard(
            grade: 'Primary 5',
            exams: ['Exam 1', 'Exam 2', 'Exam 3'],
          ),
          GradeLevelCard(
            grade: 'Primary 6',
            exams: ['Exam 1', 'Exam 2', 'Exam 3'],
          ),
          // Add more GradeLevelCard widgets for other grade levels
        ],
      ),
    );
  }
}

class GradeLevelCard extends StatelessWidget {
  final String grade;
  final List<String> exams;

  GradeLevelCard({required this.grade, required this.exams});

  @override
  Widget build(BuildContext context) {

    void chooseScreen(int index){
      if(grade == 'Primary 1' && index==0){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => P1T1(),
          ),
        );
      }
      else if(grade == 'Primary 1' && index==1){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => P1T2(),
          ),
        );
      }
      else if(grade == 'Primary 1' && index==2){
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => P1T3(),
      //     ),
      //   );
      }
    }
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              grade,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
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
                    margin: EdgeInsets.all(8.0),
                    color: Colors.deepPurple,
                    child: Center(
                      child: Text(
                        exams[index],
                        style: TextStyle(color: Colors.white),
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