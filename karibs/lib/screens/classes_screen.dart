import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/screens/teacher_class_screen.dart';

class ClassesScreen extends StatefulWidget {
  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    final data = await DatabaseHelper().queryAllClasses();
    setState(() {
      _classes = data;
      _isLoading = false;
    });
  }

  void _addClass(String className) async {
    await DatabaseHelper().insertClass({'name': className});
    _fetchClasses();
  }

  void _showAddClassDialog() {
    final TextEditingController classNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Class'),
          content: TextField(
            controller: classNameController,
            decoration: InputDecoration(labelText: 'Class Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (classNameController.text.isNotEmpty) {
                  _addClass(classNameController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _classes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No classes available. Please add!'),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _showAddClassDialog,
              child: Icon(Icons.add),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          ListView.builder(
            itemCount: _classes.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_classes[index]['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherClassScreen(classId: _classes[index]['id']),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _showAddClassDialog,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
