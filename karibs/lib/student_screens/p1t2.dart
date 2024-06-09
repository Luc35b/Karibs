import 'package:flutter/material.dart';
import 'package:karibs/screens/student_screen.dart';
import 'score_screen.dart';

class P1T2 extends StatefulWidget {
  @override
  _P1T2State createState() => _P1T2State();
}

class _P1T2State extends State<P1T2> {
  List<Map<String, dynamic>> questions = [
    {
      'section': 'Kwadwo has a bike. It is red. Kwadwo rides his bike to school. He wears a helmet. Kwadwo likes to go fast.',
      'type': 'multiple_choice',
      'question': 'What does Kwadwo have?',
      'options': ['Bike', 'Car', 'Bus'],
      'answer': 'Bike',
      'selectedOption': '',
    },
    {
      'section': 'Kwadwo has a bike. It is red. Kwadwo rides his bike to school. He wears a helmet. Kwadwo likes to go fast.',
      'type': 'multiple_choice',
      'question': 'What color is Kwadwo\'s bike?',
      'options': ['Blue', 'Green', 'Red'],
      'answer': 'Red',
      'selectedOption': '',
    },
    {
      'section': 'Kwadwo has a bike. It is red. Kwadwo rides his bike to school. He wears a helmet. Kwadwo likes to go fast.',
      'type': 'multiple_choice',
      'question': 'Where does Kwadwo ride his bike?',
      'options': ['To the park', 'To the store', 'To school'],
      'answer': 'To school',
      'selectedOption': '',
    },
    {
      'section': 'Kwadwo has a bike. It is red. Kwadwo rides his bike to school. He wears a helmet. Kwadwo likes to go fast.',
      'type': 'multiple_choice',
      'question': 'What does Kwadwo wear when he rides his bike?',
      'options': ['Hat', 'Helmet', 'Glasses'],
      'answer': 'Helmet',
      'selectedOption': '',
    },
    {
      'section': 'Kwadwo has a bike. It is red. Kwadwo rides his bike to school. He wears a helmet. Kwadwo likes to go fast.',
      'type': 'multiple_choice',
      'question': 'What does Kwadwo like to do?',
      'options': ['Go slow', 'Go fast', 'Walk'],
      'answer': 'Go fast',
      'selectedOption': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '__og',
      'answer': 'Fr',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '_ap',
      'answer': 'M',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '__ar',
      'answer': 'St',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '__ag',
      'answer': 'Fl',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank based on the picture',
      'type': 'fill_in_the_blank',
      'question': '_en',
      'answer': 'H',
      'userAnswer': '',
    },
    {
      'section': 'Fill in the blank relating to the ball',
      'type': 'multiple_choice',
      'question': 'The ball is _ the basket.',
      'options': ['on', 'in', 'under'],
      'answer': 'in',
      'selectedOption': '',
    },
    {
      'section': 'Fill in the blank relating to the ball',
      'type': 'multiple_choice',
      'question': 'The ball is _ the basket and chair.',
      'options': ['between', 'under', 'on'],
      'answer': 'between',
      'selectedOption': '',
    },
    {
      'section': 'Type in all the small letters',
      'type': 'fill_in_the_blank',
      'question': 'PiNk',
      'answer': 'ik',
      'userAnswer': '',
    },
    {
      'section': 'Type in all the capital letters',
      'type': 'fill_in_the_blank',
      'question': 'LeTtER',
      'answer': 'LTER',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of friend',
      'answer': 'Friend',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of jump',
      'answer': 'Jump',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of happy',
      'answer': 'Happy',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of rain',
      'answer': 'Rain',
      'userAnswer': '',
    },
    {
      'section': 'Match the picture to the correct name',
      'type': 'fill_in_the_blank',
      'question': 'pic of snow',
      'answer': 'Snow',
      'userAnswer': '',
    },
  ];

  bool submitted = false;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Primary 1: Exam 2'),
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
              border: OutlineInputBorder(),
            ),
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