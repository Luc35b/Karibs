import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to KLAS'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16.0, color: Colors.black),
              children: [
                TextSpan(
                  text: 'This is a tutorial to guide you through the app features. \n\n You can view these '
                      'instructions again at any time by clicking the ',
                ),
                WidgetSpan(
                  child: Icon(Icons.help_outline, size: 16.0),
                ),
                TextSpan(
                  text: ' icon at the top of every page.',
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            '1. Choose your user type by tapping on either "I\'m a Teacher" or "I\'m a Student".',
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Got it'),
        ),
      ],
    );
  }
}



class TeacherDashboardTutorialDialog extends StatefulWidget {
  @override
  _TeacherDashboardTutorialDialogState createState() =>
      _TeacherDashboardTutorialDialogState();
}

class _TeacherDashboardTutorialDialogState
    extends State<TeacherDashboardTutorialDialog> {
  int _currentIndex = 0;

  final List<Widget> _instructions = [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to the Teacher Dashboard',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        Text(
          'This screen allows you to view all of your classes, add new ones, and manage your exams.',
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16.0, color: Colors.black87),
            children: [
              TextSpan(text: '1. '),
              TextSpan(
                text: 'Add a class',
                style: TextStyle(
                    color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' by clicking on the '),
              TextSpan(
                  text: ' ADD CLASS button at the bottom of the screen.\n'),
              TextSpan(
                  text:
                  '  \n a. Select a desired class and subject from the dropdown, or create your own name by clicking on the '),
              WidgetSpan(
                child: Icon(Icons.add,
                    size: 24.0, color: Colors.black, semanticLabel: 'Add Icon'),
              ),
              TextSpan(text: ' icon on the right.'),
            ],
          ),
        ),
      ],
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '2. To '),
          TextSpan(
            text: 'view your classes',
            style: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ', click inside the rectangle with your class name.'),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '3. To '),
          TextSpan(
            text: 'edit your class name',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          TextSpan(text: ', click on the '),
          WidgetSpan(
            child: Icon(Icons.edit,
                size: 24.0, color: Colors.black, semanticLabel: 'Edit Icon'),
          ),
          TextSpan(text: ' icon next to the class name.'),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '4. To '),
          TextSpan(
            text: 'delete a class',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          TextSpan(text: ', click on the '),
          WidgetSpan(
            child: Icon(Icons.delete,
                size: 24.0, color: Colors.black, semanticLabel: 'Delete Icon'),
          ),
          TextSpan(
            text: ' icon next to the class name. '
                'You will see a confirmation message asking if you want to delete the class.',
          ),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '5. To '),
          TextSpan(
            text: 'view or create your exams, ',
            style: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: 'click on the MANAGE EXAMS button at the bottom of the screen.'),
        ],
      ),
    ),
  ];

  void _nextInstruction() {
    if (_currentIndex < _instructions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousInstruction() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _goToNextScreen() {
    // Simulate navigation to the next screen
    print('Navigating to the next screen');
    // Replace with actual navigation logic as needed
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tutorial'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: _instructions[_currentIndex],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentIndex > 0)
              IconButton(
                onPressed: _previousInstruction,
                icon: Icon(Icons.arrow_back),
              ),
            if (_currentIndex < _instructions.length - 1)
              IconButton(
                onPressed: _nextInstruction,
                icon: Icon(Icons.arrow_forward),
              ),
            if (_currentIndex == _instructions.length - 1)
              TextButton(
                onPressed: () {
                  _goToNextScreen(); // Navigate to the next screen
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Got it'),
              ),
          ],
        ),
      ],
    );
  }
}



class TeacherClassScreenTutorialDialog extends StatefulWidget {
  @override
  _TeacherClassScreenTutorialDialogState createState() =>
      _TeacherClassScreenTutorialDialogState();
}

class _TeacherClassScreenTutorialDialogState
    extends State<TeacherClassScreenTutorialDialog> {
  int _currentIndex = 0;

  final List<Widget> _instructions = [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to the Class Viewing Screen',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        Text(
          'This screen allows you to view all of your students for a given class, '
              'search and filter for specific students, add new students, '
              'and create a PDF document for an entire class.',
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16.0, color: Colors.black87),
            children: [
              TextSpan(text: '1. '),
              TextSpan(
                text: 'Add a student',
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' by clicking on the '),
              TextSpan(
                text: 'ADD STUDENT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' button in the bottom left corner of the screen.'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\n a. Type in your student’s name and click the add button to add your student to the class.',
                style: TextStyle(fontSize: 16.0),
              ),
              Text(
                '\n b. You should now be able to view your students, their average score, and '
                    'status in the circle to the left of the student’s name.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ],
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '2. To '),
          TextSpan(
            text: 'view a student',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ', click inside the rectangle with your student’s name.'),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '3. To '),
          TextSpan(
            text: 'search for a student',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' by name, click on the '),
          WidgetSpan(
            child: Icon(Icons.search, size: 16.0, color: Colors.black),
          ),
          TextSpan(text: ' icon at the top of the screen and type the desired student’s name.'),
        ],
      ),
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16.0, color: Colors.black87),
            children: [
              TextSpan(text: '4. To '),
              TextSpan(
                text: 'filter the students',
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' by their status, click on the '),
              WidgetSpan(
                child: Icon(Icons.filter_list, size: 16.0, color: Colors.black),
              ),
              TextSpan(text: ' icon at the top left of the screen next to the search bar.'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\n a. You should now be able to view all the students with the selected status.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ],
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '5. To '),
          TextSpan(
            text: 'sort the students',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' alphabetically or by their average score, click on the '),
          WidgetSpan(
            child: Icon(Icons.build_rounded, size: 16.0, color: Colors.black),
          ),
          TextSpan(text: ' icon at the top right of the screen next to the search bar.'),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '6. To '),
          TextSpan(
            text: 'save or print a PDF',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' document of all of your students within your class, click on the '),
          TextSpan(
            text: 'PDF Button',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' at the bottom right of the screen.'),
        ],
      ),
    ),
  ];

  void _nextInstruction() {
    if (_currentIndex < _instructions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousInstruction() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _goToNextScreen() {
    // Simulate navigation to the next screen
    print('Navigating to the next screen');
    // Replace with actual navigation logic as needed
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tutorial'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: _instructions[_currentIndex],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentIndex > 0)
              IconButton(
                onPressed: _previousInstruction,
                icon: Icon(Icons.arrow_back),
              ),
            if (_currentIndex < _instructions.length - 1)
              IconButton(
                onPressed: _nextInstruction,
                icon: Icon(Icons.arrow_forward),
              ),
            if (_currentIndex == _instructions.length - 1)
              TextButton(
                onPressed: () {
                  _goToNextScreen(); // Navigate to the next screen
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Got it'),
              ),
          ],
        ),
      ],
    );
  }
}



class StudentInfoScreenTutorialDialog extends StatefulWidget {
  @override
  _StudentInfoScreenTutorialDialogState createState() =>
      _StudentInfoScreenTutorialDialogState();
}

class _StudentInfoScreenTutorialDialogState
    extends State<StudentInfoScreenTutorialDialog> {
  int _currentIndex = 0;

  final List<Widget> _instructions = [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to the Student Information Screen',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        Text(
          'This screen allows you to view all of the previous reports for a '
              'student and track their progress throughout many terms.',
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16.0, color: Colors.black87),
            children: [
              TextSpan(text: '1. To '),
              TextSpan(
                text: 'add a custom report',
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' to your student, click on the '),
              TextSpan(
                text: 'Add Report button',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' at the middle right area of the screen.'),
            ],
          ),
        ),
      ],
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '2. To '),
          TextSpan(
            text: 'view a report',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ', click inside the rectangle with the given report’s name.'),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '3. To '),
          TextSpan(
            text: 'save or print a PDF',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' of the individual student, click on the PDF button at the center right of the screen.'),
        ],
      ),
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16.0, color: Colors.black87),
            children: [
              TextSpan(text: '4. To '),
              TextSpan(
                text: 'edit a student’s name',
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ', '),
              TextSpan(
                text: 'delete a student',
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ', or '),
              TextSpan(
                text: 'delete reports',
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ', click on the Edit button at the top right of the screen.'),
            ],
          ),
        ),
      ],
    ),
  ];

  void _nextInstruction() {
    if (_currentIndex < _instructions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousInstruction() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _goToNextScreen() {
    // Simulate navigation to the next screen
    print('Navigating to the next screen');
    // Replace with actual navigation logic as needed
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tutorial'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: _instructions[_currentIndex],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentIndex > 0)
              IconButton(
                onPressed: _previousInstruction,
                icon: Icon(Icons.arrow_back),
              ),
            if (_currentIndex < _instructions.length - 1)
              IconButton(
                onPressed: _nextInstruction,
                icon: Icon(Icons.arrow_forward),
              ),
            if (_currentIndex == _instructions.length - 1)
              TextButton(
                onPressed: () {
                  _goToNextScreen(); // Navigate to the next screen
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Got it'),
              ),
          ],
        ),
      ],
    );
  }
}



// class StudentInfoScreenTutorialDialog extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Welcome to the Student Information Screen'),
//       content: SingleChildScrollView(
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.9, // 80% of screen width
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Text(
//                 'This screen allows you to view all of the previous reports for a '
//                     'student and track their progress throughout many terms',
//                 style: TextStyle(fontSize: 16.0),
//               ),
//               SizedBox(height: 16.0),
//               Text(
//                 '1. To add a custom report to your student, click on the Add '
//                     'Report button at the middle right area of the screen.',
//                 style: TextStyle(fontSize: 16.0),
//               ),
//               SizedBox(height: 16.0),
//               Text(
//                 '2. To view a report, click inside the rectangle with the given report’s name.',
//                 style: TextStyle(fontSize: 16.0),
//               ),
//               SizedBox(height: 16.0),
//               Text(
//                 '3. To save or print a PDF of the individual student, click on the'
//                     ' PDF button at the center right of the screen',
//                 style: TextStyle(fontSize: 16.0),
//               ),
//               SizedBox(height: 16.0),
//               Text(
//                 '4. To edit a student’s name, delete a student, or delete reports, '
//                     'click on the Edit button at the top right of the screen.',
//                 style: TextStyle(fontSize: 16.0),
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: Text('Got it'),
//         ),
//       ],
//     );
//   }
// }

class AddReportScreenTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to the Add Report Screen'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // 80% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '1. You are able to type in a title for your report, any notes '
                    'you would like to write, and the option to add a score to your report.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '2. Once this information is filled in, click on the Add button to'
                    ' save the report to your student.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '3. You should now be able to view a list of the student’s reports '
                    'and see their progress displayed on the graph at the top of the screen.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Got it'),
        ),
      ],
    );
  }
}

class EditStudentScreenTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to the Edit Student Screen'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // 80% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '1. To edit a student’s name, select the Student Name text box at '
                    'the top of the screen and type in your desired name.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '2. To delete a report, click on the Trash Bin icon to the right'
                    'of a given report, or swipe all the way to the left on a given report.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '3. To delete a student, click on the Trash Bin icon at the top '
                    'right of the screen. You will see a confirmation message asking '
                    'if you want to delete the student.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '4. To save your edited changes to the student, click on the square'
                    ' icon in the top right corner of the screen next to the trash bin.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Got it'),
        ),
      ],
    );
  }
}

class ReportDetailsScreenTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to the Report Detail Screen'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // 80% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'This screen allows you to view the grade that your student has '
                    'received for a given report. You can see the total grade as '
                    'well as various categories for an exam.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '1. To edit the title, notes, or score for a given report, click '
                    'on the Edit Report button at the top right of the screen.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '2. To view the correct and incorrect answers from the graded exam, '
                    'click on the View Test Grade button at the bottom of the screen.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Got it'),
        ),
      ],
    );
  }
}

class EditReportScreenTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to the Edit Report Screen'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // 80% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '1. The title, notes, and score of the report can be changed here.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '2. To save your changes, click the Save Changes button.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '3. To delete a report, select the trash bin icon at the top right '
                    'of the screen. You will see a confirmation message asking if '
                    'you want to delete the report.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Got it'),
        ),
      ],
    );
  }
}

class TestsScreenTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to the Exam Viewing Screen'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // 80% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'This screen allows you to view all of your exams created within '
                    'the app. You can create, edit, and delete exams here.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '1. To add a new exam, click on the Add Exam button at the bottom of the screen.',
                style: TextStyle(fontSize: 16.0),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\n a. To name your exam, start typing in the Exam Title box.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      '\n b. To select a subject for the exam, select from the dropdown '
                          'menu or create a custom subject name by clicking on the '
                          '+ icon next to the subject dropdown.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      '\n c. Click the Add button to successfully create the new exam.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                '2. To view an exam and add questions, click inside the rectangle '
                    'with the desired exam name.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '3. To edit the name or subject of an already created exam, click '
                    'on the pencil icon to the right side of the desired exam.',
                style: TextStyle(fontSize: 16.0),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\n a. Here you can rename your exam, select a different '
                          'subject from the dropdown, or create a new subject name for your exam.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      '\n b. Click on the Save button to save your new changes.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                '4. To delete an exam, click on the trash bin icon on the right side of the desired exam. '
                    'You will see a confirmation message asking if you want to delete the exam.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Got it'),
        ),
      ],
    );
  }
}