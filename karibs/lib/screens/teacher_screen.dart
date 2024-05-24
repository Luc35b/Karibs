import 'package:flutter/material.dart';
import 'package:karibs/screens/teacher_class_screen.dart';
import 'package:karibs/database/database_helper.dart';

class TeacherScreen extends StatefulWidget {
  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  List<Map<String, dynamic>> _classes = [];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    final data = await DatabaseHelper().queryAllClasses();
    print('Fetched classes: $data'); // Print fetched classes
    setState(() {
      _classes = data;
    });
  }

  void _addClass(String className) async {
    await DatabaseHelper().insertClass({'name': className});
    print('Added class: $className'); // Print added class
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
        title: Text('Teacher Screen'),
      ),
      body: _classes.isEmpty
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
                            builder: (context) => TeacherClassScreen(),
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
