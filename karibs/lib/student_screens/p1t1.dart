import 'package:flutter/material.dart';
import 'package:karibs/screens/student_screen.dart';
import 'score_screen.dart';

class P1T1 extends StatefulWidget {
  @override
  _P1T1State createState() => _P1T1State();
}

class _P1T1State extends State<P1T1> {
  List<Map<String, dynamic>> questions = [
    {
      'section': 'Kofi has a pet. It is a cat. The cat is black. Kofi feeds the cat. The cat purrs.',
      'type': 'multiple_choice',
      'question': 'Who has a pet?',
      'options': ['Akua', 'Kofi', 'Kwame'],
      'answer': 'Kofi',
      'selectedOption': '',
    },
    {
      'section': 'Kofi has a pet. It is a cat. The cat is black. Kofi feeds the cat. The cat purrs.',
      'type': 'multiple_choice',
      'question': 'What kind of pet does Kofi have?',
      'options': ['Dog', 'Cat', 'Fish'],
      'answer': 'Cat',
      'selectedOption': '',
    },
    {
      'section': 'Kofi has a pet. It is a cat. The cat is black. Kofi feeds the cat. The cat purrs.',
      'type': 'multiple_choice',
      'question': 'What color is the cat?',
      'options': ['Black', 'White', 'Brown'],
      'answer': 'Black',
      'selectedOption': '',
    },
    {
      'section': 'Kofi has a pet. It is a cat. The cat is black. Kofi feeds the cat. The cat purrs.',
      'type': 'multiple_choice',
      'question': 'What does Kofi do to the cat?',
      'options': ['Feeds it', 'Plays with it', 'Ignores it'],
      'answer': 'Feeds it',
      'selectedOption': '',
    },
    {
      'section': 'Kofi has a pet. It is a cat. The cat is black. Kofi feeds the cat. The cat purrs.',
      'type': 'multiple_choice',
      'question': 'How does the cat express happiness?',
      'options': ['By wagging its tail', 'By purring', 'By barking'],
      'answer': 'By purring',
      'selectedOption': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': 'Ca_',
      'answer': 't',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '_un',
      'answer': 'S',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '_all',
      'answer': 'B',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': 'Ha_',
      'answer': 't',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '_ar',
      'answer': 'C',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank relating to the ball',
      'type': 'multiple_choice',
      'question': 'The ball is _ the box.',
      'options': ['on', 'in', 'under'],
      'answer': 'in',
      'selectedOption': '',
    },
    {
      'section': 'Fill in the blank relating to the ball',
      'type': 'multiple_choice',
      'question': 'The ball is _ the rug.',
      'options': ['under', 'in', 'on'],
      'answer': 'on',
      'selectedOption': '',
    },
    {
      'section': 'Type in all the small letters',
      'type': 'fill_in_the_blank',
      'question': 'GrApe',
      'answer': 'rpe',
      'userAnswer': '',
    },
    {
      'section': 'Type in all the capital letters',
      'type': 'fill_in_the_blank',
      'question': 'sQuARe',
      'answer': 'QAR',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of bird',
      'answer': 'Bird',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of flower',
      'answer': 'Flower',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of car',
      'answer': 'Car',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of star',
      'answer': 'Star',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of apple',
      'answer': 'Apple',
      'userAnswer': '',
    },
  ];

  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Primary 1: Exam 1'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var section in _getSections())
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    section['section'],
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  ..._buildQuestions(section['questions']),
                  SizedBox(height: 20),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                _checkSubmit();
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _checkSubmit() async {
    // Show a confirmation dialog
    bool confirmSubmit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submit'),
        content: Text('Are you sure you want to submit this exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: Text('Submit'),
          ),
        ],
      ),
    );
    // Delete the student if confirmed
    if (confirmSubmit == true) {
      double grade = calculateGrade();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScoreScreen(grade: grade),
        ),
      );// Navigate back to the previous screen
    }
  }

  List<Map<String, dynamic>> _getSections() {
    Set<String> sectionNames = questions.map<String>((question) => question['section']).toSet();
    List<Map<String, dynamic>> sections = [];
    for (var sectionName in sectionNames) {
      List<Map<String, dynamic>> sectionQuestions = questions.where((question) => question['section'] == sectionName).toList();
      sections.add({'section': sectionName, 'questions': sectionQuestions});
    }
    return sections;
  }

  List<Widget> _buildQuestions(List<Map<String, dynamic>> questions) {
    return [
      for (var question in questions)
        _buildQuestion(question),
    ];
  }

  Widget _buildQuestion(Map<String, dynamic> question) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['question'],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          if (question['type'] == 'multiple_choice')
            Column(
              children: List.generate(
                question['options'].length,
                    (index) => RadioListTile(
                  title: Text(question['options'][index]),
                  value: question['options'][index],
                  groupValue: question['selectedOption'],
                  onChanged: (value) {
                    setState(() {
                      question['selectedOption'] = value;
                    });
                  },
                ),
              ),
            )
          else if (question['type'] == 'fill_in_the_blank')
            TextField(
              onChanged: (value) {
                setState(() {
                  question['userAnswer'] = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter your answer',
                border: OutlineInputBorder(),
              ),
            ),
        ],
      ),
    );
  }

  double calculateGrade() {
    int correctAnswers = 0;
    for (var question in questions) {
      if (question['type'] == 'multiple_choice') {
        if (question['selectedOption'] == question['answer']) {
          correctAnswers++;
        }
      } else if (question['type'] == 'fill_in_the_blank') {
        if (question['userAnswer'] == question['answer']) {
          correctAnswers++;
        }
      }
    }
    return correctAnswers / questions.length;
  }
}