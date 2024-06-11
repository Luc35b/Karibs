import 'package:flutter/material.dart';
import 'package:karibs/student_screens/student_screen.dart';
import 'score_screen.dart';

class P1T3 extends StatefulWidget {
  @override
  _P1T3State createState() => _P1T3State();
}

class _P1T3State extends State<P1T3> {
  List<Map<String, dynamic>> questions = [
    {
      'section': 'Kwaku has a puzzle. It is a big one. Kwaku works on it with his mom. They finish it together. Kwaku feels proud.',
      'type': 'multiple_choice',
      'question': 'What does Kwaku have?',
      'options': ['Ball', 'Toy', 'Puzzle'],
      'answer': 'Puzzle',
      'selectedOption': '',
    },
    {
      'section': 'Kwaku has a puzzle. It is a big one. Kwaku works on it with his mom. They finish it together. Kwaku feels proud.',
      'type': 'multiple_choice',
      'question': 'What size is Kwaku\'s puzzle?',
      'options': ['Small', 'Big', 'Medium'],
      'answer': 'Big',
      'selectedOption': '',
    },
    {
      'section': 'Kwaku has a puzzle. It is a big one. Kwaku works on it with his mom. They finish it together. Kwaku feels proud.',
      'type': 'multiple_choice',
      'question': 'Who does Kwaku work on the puzzle with?',
      'options': ['Mom', 'Dad', 'Sister'],
      'answer': 'Mom',
      'selectedOption': '',
    },
    {
      'section': 'Kwaku has a puzzle. It is a big one. Kwaku works on it with his mom. They finish it together. Kwaku feels proud.',
      'type': 'multiple_choice',
      'question': 'How do they finish the puzzle?',
      'options': ['Alone', 'Together', 'With friends'],
      'answer': 'Together',
      'selectedOption': '',
    },
    {
      'section': 'Kwaku has a puzzle. It is a big one. Kwaku works on it with his mom. They finish it together. Kwaku feels proud.',
      'type': 'multiple_choice',
      'question': 'How does Kwaku feel when they finish the puzzle?',
      'options': ['Proud', 'Sad', 'Angry'],
      'answer': 'Proud',
      'selectedOption': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '_ug',
      'answer': 'B',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '_at',
      'answer': 'M',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '_ox',
      'answer': 'B',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '_am',
      'answer': 'J',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '_og',
      'answer': 'D',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank relating to the ball',
      'type': 'multiple_choice',
      'question': 'The ball is _ the table.',
      'options': ['on', 'between', 'under'],
      'answer': 'under',
      'selectedOption': '',
    },
    {
      'section': 'Type in all the small letters',
      'type': 'fill_in_the_blank',
      'question': 'tAbLE',
      'answer': 'tb',
      'userAnswer': '',
    },
    {
      'section': 'Type in all the capital letters',
      'type': 'fill_in_the_blank',
      'question': 'AppLe',
      'answer': 'AL',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of sun',
      'answer': 'Sun',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of moon',
      'answer': 'Moon',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of book',
      'answer': 'Book',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of hat',
      'answer': 'Hat',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of fish',
      'answer': 'Fish',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of tree',
      'answer': 'Tree',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of house',
      'answer': 'House',
      'userAnswer': '',
    },
  ];

  bool submitted = false;
  int currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Primary 1: Exam 3'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    questions[currentIndex]['section'],
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildQuestion(questions[currentIndex]),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (submitted) {
                  setState(() {
                    if (currentIndex < questions.length - 1) {
                      currentIndex++; // Move to the next question
                      submitted = false;
                    }
                    else{
                      _checkSubmit();
                    }
                  });
                } else {
                  submitAnswer();
                }
              },
              child: Text(submitted ? 'Next' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildQuestion(Map<String, dynamic> question) {
    String? chosenAnswer = question['selectedOption'];
    String correctAnswer = question['answer'];
    bool isMultipleChoice = question['type'] == 'multiple_choice';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        if (isMultipleChoice)
          Column(
            children: List.generate(
              question['options'].length,
                  (index) {
                String option = question['options'][index];
                bool isChosen = chosenAnswer == option;
                bool isCorrect = submitted && option == correctAnswer;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color: submitColor(isChosen, isCorrect, submitted),
                    border: Border.all(
                      // color: isChosen
                      //     ? Colors.red
                      //     : (submitted && isCorrect ? Colors.green : Colors.grey),
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: chosenAnswer,
                    onChanged: submitted
                        ? null
                        : (value) {
                      setState(() {
                        question['selectedOption'] = value!;
                      });
                    },
                  ),
                );
              },
            ),
          )
        else if (question['type'] == 'fill_in_the_blank')
          TextField(
            enabled: !submitted,
            onChanged: (value) {
              setState(() {
                question['userAnswer'] = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter your answer',
              fillColor: (submitted && question['userAnswer'].trim().toLowerCase() ==
                correctAnswer.trim().toLowerCase()) ? Colors.green : Colors.red,
              border: OutlineInputBorder(),
            ),
          ),
        if (submitted && question['type'] == 'fill_in_the_blank')
          Text(
            question['userAnswer'].trim().toLowerCase() == correctAnswer.trim().toLowerCase()
                ? 'Good job! Correct answer is: $correctAnswer'
                : 'Correct Answer: $correctAnswer',
            style: TextStyle(color: question['userAnswer'].trim().toLowerCase() == correctAnswer.trim().toLowerCase() ? Colors.green : Colors.red),
          ),
        if (submitted && isMultipleChoice)
          if(chosenAnswer==correctAnswer)
            Text(
              'Good job! Correct answer is: $correctAnswer',
              style: TextStyle(color: Colors.green),
            ),
        if(chosenAnswer != correctAnswer && submitted && isMultipleChoice)
          Text(
            'Correct Answer: $correctAnswer',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  Color submitColor(bool chosen, bool correct, bool submit){
    if(submit){
      if(correct){
        return Color(0xFFAED581);
      }
      else if(chosen){
        return Color(0xFFFF8A65);
      }
    }
    return Colors.white;
  }

  void submitAnswer() {
    setState(() {
      submitted = true;
    });
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

  // List<Map<String, dynamic>> _getSections() {
  //   Set<String> sectionNames = questions.map<String>((question) => question['section']).toSet();
  //   List<Map<String, dynamic>> sections = [];
  //   for (var sectionName in sectionNames) {
  //     List<Map<String, dynamic>> sectionQuestions = questions.where((question) => question['section'] == sectionName).toList();
  //     sections.add({'section': sectionName, 'questions': sectionQuestions});
  //   }
  //   return sections;
  // }
  //
  // List<Widget> _buildQuestions(List<Map<String, dynamic>> questions) {
  //   return [
  //     for (var question in questions)
  //       _buildQuestion(question),
  //   ];
  // }
  //
  // Widget _buildQuestion(Map<String, dynamic> question) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           question['question'],
  //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         ),
  //         SizedBox(height: 10),
  //         if (question['type'] == 'multiple_choice')
  //           Column(
  //             children: List.generate(
  //               question['options'].length,
  //                   (index) => RadioListTile(
  //                 title: Text(question['options'][index]),
  //                 value: question['options'][index],
  //                 groupValue: question['selectedOption'],
  //                 onChanged: (value) {
  //                   setState(() {
  //                     question['selectedOption'] = value;
  //                   });
  //                 },
  //               ),
  //             ),
  //           )
  //         else if (question['type'] == 'fill_in_the_blank')
  //           TextField(
  //             onChanged: (value) {
  //               setState(() {
  //                 question['userAnswer'] = value;
  //               });
  //             },
  //             decoration: InputDecoration(
  //               hintText: 'Enter your answer',
  //               border: OutlineInputBorder(),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

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