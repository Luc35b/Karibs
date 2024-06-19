import 'package:flutter/material.dart';

class MainTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to KLAS'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'This is a tutorial to guide you through the app features. \n\n You can view these '
                'instructions again at any time by clicking the question mark icon at the top right corner of every page.',
            style: TextStyle(fontSize: 16.0),
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

class TeacherDashboardTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Welcome to the Teacher Dashboard'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'This screen allows you to view all of your classes, add new ones, and manage your exams.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '1. Add a class by clicking on the Add Class button at the bottom of the screen.',
                style: TextStyle(fontSize: 16.0),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\n a. Select a desired class and subject from the dropdown, or create your own name by clicking on the + icon on the right.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      '\n b. Click the Add button to add your class to the dashboard.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                '2. To view your classes, click inside the rectangle with your class name.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '3. To edit your class name, click on the pencil icon next to the class name.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '4. To delete a class, click on the trash bin icon next to the class name.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                '5. To view or create your exams, click on the Manage Exams button at the bottom of the screen.',
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

