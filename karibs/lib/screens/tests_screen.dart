import 'package:flutter/material.dart';
import 'package:karibs/main.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/screens/add_question_screen.dart';
import 'package:karibs/screens/test_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class TestsScreen extends StatefulWidget {
  @override
  _TestsScreenState createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  List<Map<String, dynamic>> _tests = [];
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;
  String? _testName; // To retain the test name
  int? _selectedSubjectId; // To retain the selected subject

  @override
  void initState() {
    super.initState();
    _fetchTests();
    _fetchSubjects();
  }

  Future<void> _fetchTests() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.queryAllTests();
    setState(() {
      _tests = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  }

  Future<void> _fetchSubjects() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.queryAllSubjects();
    setState(() {
      _subjects = List<Map<String, dynamic>>.from(data);
    });
  }

  void _addTest(String testName, int subjectId) async {
    if (_tests.any((test) => test['title'] == testName)) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Exam with this name already exists. Please choose a different name.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );
      return;
    }

    await DatabaseHelper().insertTest({'title': testName, 'subject_id': subjectId});
    _fetchTests();
  }

  void _showAddTestDialog({String? testName, int? subjectId}) {

    final TextEditingController testNameController = TextEditingController(text: testName);
    int? selectedSubjectId = subjectId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Exam'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: testNameController,
                    decoration: InputDecoration(labelText: 'Exam Title'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          hint: Text('Select Subject'),
                          value: selectedSubjectId,
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedSubjectId = newValue;
                            });
                          }
                          ,
                          items: _subjects.map<DropdownMenuItem<int>>((subject) {
                            return DropdownMenuItem<int>(
                              value: subject['id'],
                              child: Text(subject['name']),
                            );
                          }).toList(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _testName = testNameController.text;
                          _selectedSubjectId = selectedSubjectId;
                          Navigator.pop(context);
                          _showAddSubjectDialog();
                        },
                      ),
                    ],
                  ),
                ],
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
                    if (testNameController.text.isNotEmpty && selectedSubjectId != null) {
                      _addTest(testNameController.text, selectedSubjectId!);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddSubjectDialog() {
    final TextEditingController subjectNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Subject'),
          content: TextField(
            controller: subjectNameController,
            decoration: InputDecoration(labelText: 'Subject Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (subjectNameController.text.isNotEmpty) {
                  await DatabaseHelper().insertSubject({'name': subjectNameController.text});
                  _fetchSubjects();
                  Navigator.of(context).pop();
                  _showAddTestDialog(testName: _testName, subjectId: _selectedSubjectId); // Reopen the add test dialog after adding a new subject
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTestDialog(int testId, String currentTitle, int currentSubjectId) {
    final TextEditingController testNameController = TextEditingController(text: currentTitle);
    int? selectedSubjectId = currentSubjectId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Exam Name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: testNameController,
                    decoration: InputDecoration(labelText: 'Exam Title'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          hint: Text('Select Subject'),
                          value: selectedSubjectId,
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedSubjectId = newValue;
                            });
                          },
                          items: _subjects.map<DropdownMenuItem<int>>((subject) {
                            return DropdownMenuItem<int>(
                              value: subject['id'],
                              child: Text(subject['name']),
                            );
                          }).toList(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddSubjectDialog();
                        },
                      ),
                    ],
                  ),
                ],
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
                    if (testNameController.text.isNotEmpty && selectedSubjectId != null) {
                      _editTestName(testId, testNameController.text, selectedSubjectId!);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editTestName(int testId, String newTitle, int subjectId) async {
    if (_tests.any((test) => test['title'] == newTitle && test['id'] != testId)) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Exam with this name already exists. Please choose a different name.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );
      return;
    }

    await DatabaseHelper().updateTest(testId, {'title': newTitle, 'subject_id': subjectId});
    _fetchTests();
  }

  void _showDeleteConfirmationDialog(int testId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Exam'),
          content: Text('Are you sure you want to delete this exam?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteTest(testId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTest(int testId) async {
    await DatabaseHelper().deleteTest(testId);
    _fetchTests();
  }

  void _navigateToTestDetailScreen(int testId, String testTitle, int subjId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestDetailScreen(
          testId: testId,
          testTitle: testTitle,
          subjectId: subjId,
        ),
      ),
    );
  }

  void _navigateToAddQuestionScreen(int testId, int subjId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(
          testId: testId,
          onQuestionAdded: _fetchTests,
          subjectId: subjId,
        ),
      ),
    );
  }

  void _updateTestOrder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _tests.removeAt(oldIndex);
      _tests.insert(newIndex, item);

      // Update the order in the database
      _updateOrderInDatabase();
    });
  }

  Future<void> _updateOrderInDatabase() async {
    for (int i = 0; i < _tests.length; i++) {
      await DatabaseHelper().updateTestOrder(_tests[i]['id'], i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurple,
          title: Text('Exams'),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            _tests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No exams available.', style: GoogleFonts.raleway(fontSize: 36)),
                  Text('Please add!', style: GoogleFonts.raleway(fontSize: 36)),
                  SizedBox(height: 20),
                ],
              ),
            )
                : ReorderableListView(
              onReorder: _updateTestOrder,
              padding: const EdgeInsets.only(bottom: 80.0), // Padding to avoid overlap with button
              children: [
                for (int index = 0; index < _tests.length; index++)
                  ListTile(
                    key: ValueKey(_tests[index]['id']),
                    title: Text(_tests[index]['title']),
                    subtitle: Text(_subjects[_tests[index]['subject_id']-1]['name']),
                    onTap: () => _navigateToTestDetailScreen(_tests[index]['id'], _tests[index]['title'], _tests[index]['subject_id']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _navigateToAddQuestionScreen(_tests[index]['id'], _tests[index]['subject_id']),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showEditTestDialog(_tests[index]['id'], _tests[index]['title'], _tests[index]['subject_id']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _showDeleteConfirmationDialog(_tests[index]['id']),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _showAddTestDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    side: BorderSide(width: 2, color: Colors.deepPurple),
                    padding: EdgeInsets.symmetric(horizontal: 55, vertical: 12), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Add Exam', style: GoogleFonts.raleway(fontSize: 24)),
                      SizedBox(width: 8),
                      Icon(Icons.add),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
