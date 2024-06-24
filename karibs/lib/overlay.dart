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
                  text: 'This is a tutorial to guide you through the app features. \n\n You can ',
                ),
                TextSpan(
                  text: 'view these instructions again',
                  style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' at any time by clicking the ',
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
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16.0, color: Colors.black),
              children: [
                TextSpan(
                  text: '1. Choose your user type by tapping on either ',
                ),
                TextSpan(
                  text: 'I\'m a Teacher',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' or ',
                ),
                TextSpan(
                  text: 'I\'m a Student',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '.',
                ),
              ],
            ),
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
                  text: 'ADD CLASS button',
                  style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                  text: ' at the bottom of the screen.\n'),
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
          TextSpan(text: 'click on the '),
          TextSpan(
            text: 'MANAGE EXAMS button',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' at the bottom of the screen.'),
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
                child: Icon(Icons.filter_alt, size: 16.0, color: Colors.black),
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
            child: Icon(Icons.settings, size: 16.0, color: Colors.black),
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
            text: 'CLASS REPORT Button',
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
                text: 'ADD REPORT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' button at the middle right area of the screen.'),
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
          TextSpan(text: ' of the individual student, click on the '),
          TextSpan(
            text: 'PDF Button',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' at the center right of the screen.'),
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
              TextSpan(text: ', click on the '),
              TextSpan(
                text: 'EDIT Button',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' at the top right of the screen.'),
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



class AddReportScreenTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to the Add Report Screen'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
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



class EditStudentScreenTutorialDialog extends StatefulWidget {
  @override
  _EditStudentScreenTutorialDialogState createState() =>
      _EditStudentScreenTutorialDialogState();
}

class _EditStudentScreenTutorialDialogState
    extends State<EditStudentScreenTutorialDialog> {
  int _currentIndex = 0;

  final List<Widget> _instructions = [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to the Edit Student Screen',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        Text(
          'This screen allows you to edit student information and manage their reports.',
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '1. To '),
          TextSpan(
            text: 'edit a student’s name',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ', select the ',
          ),
          TextSpan(
            text: 'Student Name',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ' text box at the top of the screen and type in your desired name.',
          ),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '2. To '),
          TextSpan(
            text: 'delete a report',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ', click on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.delete),
          ),
          TextSpan(
            text: ' icon to the right of a given report, or swipe all the way to the left on a report.',
          ),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '3. To '),
          TextSpan(
            text: 'delete a student',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ', click on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.delete),
          ),
          TextSpan(
            text: ' icon at the top right of the screen. Confirm the deletion when prompted.',
          ),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '4. To '),
          TextSpan(
            text: 'save your changes',
            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ', click on the ',
          ),
          WidgetSpan(
            child: Icon(Icons.check_box),
          ),
          TextSpan(
            text: ' icon in the top right corner of the screen.',
          ),
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



class ReportDetailsScreenTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to the Report Detail Screen'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
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
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  children: [
                    TextSpan(text: '1. To '),
                    TextSpan(
                      text: 'edit the title, notes, or score',
                      style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' for a given report, click on the '),
                    TextSpan(
                      text: 'EDIT REPORT button',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' at the top right of the screen.'),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  children: [
                    TextSpan(text: '2. To '),
                    TextSpan(
                      text: 'view the correct and incorrect answers',
                      style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' from the graded exam, click on the '),
                    TextSpan(
                      text: 'VIEW TEST GRADE button',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' at the bottom of the screen.'),
                  ],
                ),
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
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'The title, notes, and score of the report can be changed here.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  children: [
                    TextSpan(text: '1. To '),
                    TextSpan(
                      text: 'save your changes',
                      style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ', click the '),
                    TextSpan(
                      text: 'SAVE CHANGES button.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  children: [
                    TextSpan(text: '2. To '),
                    TextSpan(
                      text: 'delete a report',
                      style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ', select the '),
                    WidgetSpan(
                      child: Icon(Icons.delete),
                    ),
                    TextSpan(text: '  icon at the top right of the screen. '
                        'Confirm the deletion when prompted.'),
                  ],
                ),
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


class TestsScreenTutorialDialog extends StatefulWidget {
  @override
  _TestsScreenTutorialDialogState createState() =>
      _TestsScreenTutorialDialogState();
}

class _TestsScreenTutorialDialogState
    extends State<TestsScreenTutorialDialog> {
  int _currentIndex = 0;

  final List<Widget> _instructions = [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to the Tests Screen.',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        Text(
          'This screen allows you to view all of your exams created within the app. You can create, edit, and delete exams here.',
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
                text: 'Add an exam',
                style: TextStyle(
                    color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' by clicking on the'),
              TextSpan(text: ' ADD EXAM button', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' at the bottom of the screen.\n'),
              TextSpan(text: '  \n a. To name your exam, start typing in the Exam Title box. \n '
                              '\n b. To select a subject for the exam, select from the dropdown menu or'
                              'create a custom subject name by clicking on the '),
              WidgetSpan(
                child: Icon(Icons.add,
                    size: 24.0, color: Colors.black, semanticLabel: 'Add Icon'),
              ),
              TextSpan(text:'icon next to the subject dropdown.\n \n c. Click the '),
              TextSpan(text: 'ADD button ', style: TextStyle(fontWeight: FontWeight.bold),),
              TextSpan(text:'to successfully create the new exam.'),
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
            text: 'view an exam',
            style: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'add questions',
            style: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ', click inside the rectangle with the exam name.'),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '3. To '),
          TextSpan(
            text: 'edit your exam',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          TextSpan(text: ' name or subject, click on the '),
          WidgetSpan(
            child: Icon(Icons.edit,
                size: 24.0, color: Colors.black, semanticLabel: 'Edit Icon'),
          ),
          TextSpan(text: ' icon to the right of the exam.'
          '\n \n a. Here you can rename your exam, select a different subject from the dropdown,'
              'or create a new subject name for your exam. \n'
              '\n b. Click on the '),
          TextSpan(text: 'SAVE button', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' to save your new changes.'),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '4. To '),
          TextSpan(
            text: 'delete an exam',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          TextSpan(text: ', click on the '),
          WidgetSpan(
            child: Icon(Icons.delete,
                size: 24.0, color: Colors.black, semanticLabel: 'Delete Icon'),
          ),
          TextSpan(
            text: ' icon next to the exam. '
                'You will see a confirmation message asking if you want to delete the exam.',
          ),
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



class TestDetailScreenTutorialDialog extends StatefulWidget {
  @override
  _TestDetailScreenTutorialDialogState createState() =>
      _TestDetailScreenTutorialDialogState();
}

class _TestDetailScreenTutorialDialogState
    extends State<TestDetailScreenTutorialDialog> {
  int _currentIndex = 0;

  final List<Widget> _instructions = [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to the Test Detail Screen.',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        Text('This screen allows you to add questions to your exam. '
            'You can grade the exam, print out the questions, and print out the answer key. ',
            style: TextStyle(fontSize: 16.0)),
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
                text: 'Add a new question',
                style: TextStyle(
                    color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' by clicking on the '),
              TextSpan(text: 'ADD QUESTION + ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: 'button in the center of the screen.\n'),
              ],
          ),
        ),
      ],
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '2. '),
          TextSpan(
            text: 'Grade an exam',
            style: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' by clicking on the '),
          TextSpan(text: 'GRADE button', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text:' in the top right of the screen.\n \n a. Choose and click on the class you would like to grade the exam for.'),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '3. To '),
          TextSpan(
            text: 'print the exam',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          TextSpan(text: ' name or subject, click on the '),
          WidgetSpan(
            child: Icon(Icons.print,
                size: 24.0, color: Colors.black, semanticLabel: 'Print Icon'),
          ),
          TextSpan(text: ' icon at the bottom right of the screen. '
              'You will have the option to print out the questions or the answer key.'
              '\n \n a. Click '),
          TextSpan(text: 'Print Questions', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' to hand out blank exams to students to fill out. \n \n b. Click '),
          TextSpan(text: 'Print Answer Key', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' to print out the questions along with the correct answer for easy grading.'),
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



class AddQuestionScreenTutorialDialog extends StatefulWidget {
  @override
  _AddQuestionScreenTutorialDialogState createState() =>
      _AddQuestionScreenTutorialDialogState();
}

class _AddQuestionScreenTutorialDialogState
    extends State<AddQuestionScreenTutorialDialog> {
  int _currentIndex = 0;

  final List<Widget> _instructions = [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to the Add Question Screen.',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        Text('This screen allows you to input questions to your exam. ',
            style: TextStyle(fontSize: 16.0)),
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16.0, color: Colors.black87),
            children: [
              TextSpan(text: '1. The question you are adding goes in the '),
              TextSpan(
                text: 'Question Text ',
                style: TextStyle(
                    color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: 'box. \n \n 2. Select the type of question (multiple choice, fill in the blank, etc.) using the '),
              TextSpan(
                text: 'middle dropdown ',
                style: TextStyle(
                    color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: 'box. \n \n 3. Select the  question category using the '),
              TextSpan(
                text: 'bottom dropdown.',
                style: TextStyle(
                    color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: '\n \n If you do not have any categories created, you can add one using the '),
              WidgetSpan(
                child: Icon(Icons.add,
                    size: 24.0, color: Colors.black, semanticLabel: 'Add Icon'),
              ),
              TextSpan(text: ' icon to the right of the dropdown. This will allow you to break down your students’ scores'
                'by categories such as vocabulary, grammar, and comprehension.  '),
            ],
          ),
        ),
      ],
    ),
    RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.0, color: Colors.black87),
        children: [
          TextSpan(text: '4. If you create a '),
          TextSpan(
            text: 'multiple choice question',
            style: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ', add the multiple answers by clicking the Add Choice button. Mark the correct answer by '
            'selecting the checkbox next to the answer. You can delete a choice by clicking the'),
          WidgetSpan(
            child: Icon(Icons.delete,
                size: 24.0, color: Colors.black, semanticLabel: 'Delete Icon'),
          ),
          TextSpan(text: ' icon to the right. \n \n 5. If you create a '),
          TextSpan(
            text: 'fill in the blank question',
            style: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ', type in the correct answer in the Correct Answer box at the bottom. \n '
            '\n 6. Finish adding the question by clicking the '),
          TextSpan(text: 'SAVE button', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' at the bottom.'),
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



class TestGradeScreenTutorialDialog extends StatefulWidget {
  @override
  _TestGradeScreenTutorialDialogState createState() =>
      _TestGradeScreenTutorialDialogState();
}

class _TestGradeScreenTutorialDialogState
    extends State<TestGradeScreenTutorialDialog> {
  int _currentIndex = 0;

  final List<Widget> _instructions = [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to the Test Grading Screen.',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        Text('This screen allows you to mark questions correct and incorrect to automatically grade the exam for a student.',
            style: TextStyle(fontSize: 16.0)),
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16.0, color: Colors.black87),
            children: [
              TextSpan(text: '1. Choose the student that you are grading the exam for, using the '),
              TextSpan(
              text: 'dropdown',
              style: TextStyle(
              color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' at the top of the screen. \n \n 2. For each question, you can click the '),
              WidgetSpan(
              child: Icon(Icons.check,
              size: 24.0, color: Colors.green[900], semanticLabel: 'Add Icon'),
              ),
              TextSpan(text: ' icon if the student got the question correct, or the '),
              WidgetSpan(
              child: Icon(Icons.clear,
              size: 24.0, color: Colors.red[900], semanticLabel: 'Add Icon'),
              ),
              TextSpan(text: ' icon if the student got the question incorrect. \n \n 3. '
                  'After finishing grading each question, click the'),
              TextSpan(text: ' SAVE GRADE ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: 'button at the bottom left of the screen.'),
            ],
          ),
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
              TextSpan(text: '4. You can grade the exam for a different student by selecting a new student in the drop down.'
                  '\n \n 5. You can view the class that took the exam by clicking the'),
              TextSpan(text: ' GO TO CLASS ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: 'button at the bottom of the screen. \n \n 6. Click  the '),
              WidgetSpan(
                child: Icon(Icons.print,
                    size: 24.0, color: Colors.black, semanticLabel: 'Print Icon'),
              ),
              TextSpan(text: ' icon at the bottom right of the screen to print a PDF of all of the students\' scores for the exam.'),

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



class EditQuestionScreenTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to the Edit Question Screen'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.9, // 90% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'The question text, type, category, and answer can be changed here.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  children: [
                    TextSpan(text: 'To '),
                    TextSpan(
                      text: 'save your changes',
                      style: TextStyle(color: Colors.deepPurple,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ', click the '),
                    TextSpan(
                      text: 'SAVE button.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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



class ViewTestGradeScreenTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to the View Exam Grade Screen'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'You can see the specific questions the student got correct or incorrect here.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  children: [
                    TextSpan(text: 'To '),
                    TextSpan(
                      text: 'regrade an exam',
                      style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ', click the '),
                    WidgetSpan(
                      child: Icon(Icons.refresh),
                    ),
                    TextSpan(
                      text: ' icon at the top right corner of the screen.',
                    ),
                  ],
                ),
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



class RegradeTestScreenTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to the Regrade Exam Screen'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  children: [
                    TextSpan(text: '1. For each question, you can click the '),
                    WidgetSpan(
                      child: Icon(Icons.check,
                          size: 24.0, color: Colors.green[900], semanticLabel: 'Add Icon'),
                    ),
                    TextSpan(text: ' icon if the student got the question correct, or the '),
                    WidgetSpan(
                      child: Icon(Icons.clear,
                          size: 24.0, color: Colors.red[900], semanticLabel: 'Add Icon'),
                    ),
                    TextSpan(text: ' icon if the student got the question incorrect. \n \n 2. '
                        'After finishing grading each question, click the '),
                    TextSpan(text: ' SAVE GRADE ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' at the bottom left of the screen.'),
                    TextSpan(text: '\n \n 3. To return back to the student’s information screen, click the '),
                    TextSpan(text: 'RETURN TO STUDENT button', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' at the bottom right of the screen.'),
                  ],
                ),
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