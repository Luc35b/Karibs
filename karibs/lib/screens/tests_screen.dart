import 'package:flutter/material.dart';
import 'package:karibs/main.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/screens/add_question_screen.dart';
import 'package:karibs/screens/test_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import '../overlay.dart';


class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

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
        const SnackBar(
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
              title: const Text('Add New Exam'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: testNameController,
                    decoration: const InputDecoration(labelText: 'Exam Title'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          hint: const Text('Select Subject'),
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
                        icon: const Icon(Icons.add),
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
                  child: const Text('Cancel', style: TextStyle(fontSize: 20)),
                ),
                TextButton(
                  onPressed: () {
                    if (testNameController.text.isNotEmpty && selectedSubjectId != null) {
                      _addTest(testNameController.text, selectedSubjectId!);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add', style: TextStyle(fontSize: 20)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddSubjectDialog([int? testId, String? testName]) {
    final TextEditingController subjectNameController = TextEditingController();


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Subject'),
          content: TextField(
            controller: subjectNameController,
            decoration: const InputDecoration(labelText: 'Subject Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: () async {
                if (subjectNameController.text.isNotEmpty) {
                  String newSubjectName = subjectNameController.text;
                  bool subjectExists = _subjects.any((subject) => subject['name'] == newSubjectName);
                  if (subjectExists) {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text('Subject with this name already exists. Please choose a different name.'),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
                      ),
                    );
                    return;
                  }
                  await DatabaseHelper().insertSubject({'name': subjectNameController.text});

                  _fetchSubjects();

                  int? id = await DatabaseHelper().getSubjectId(subjectNameController.text);
                  _selectedSubjectId = id;
                  Navigator.of(context).pop();
                  if(testId != null) {
                    _showEditTestDialog(testId, testName!, _selectedSubjectId!);
                  }
                  else {
                    _showAddTestDialog(testName: _testName,
                        subjectId: _selectedSubjectId); // Reopen the add test dialog after adding a new subject
                  }
                }
              },
              child: const Text('Add', style: TextStyle(fontSize: 20)),
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
              title: const Text('Edit Exam Name/Subject'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: testNameController,
                    decoration: const InputDecoration(labelText: 'Exam Title'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          hint: const Text('Select Subject'),
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
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddSubjectDialog(testId, testNameController.text);
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
                  child: const Text('Cancel', style: TextStyle(fontSize: 20)),
                ),
                TextButton(
                  onPressed: () {
                    if (testNameController.text.isNotEmpty && selectedSubjectId != null) {
                      _editTestName(testId, testNameController.text, selectedSubjectId!);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
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
        const SnackBar(
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
          title: const Text('Delete Exam'),
          content: const Text('Are you sure you want to delete this exam?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: () {
                _deleteTest(testId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(fontSize: 20)),
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
          backgroundColor: DeepPurple,
          foregroundColor: White,
          title: const Text('Exams'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child:Column(

              children: [
              const SizedBox(height: 70),
          Container(margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: MidPurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(3, 3), // Shadow position
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:40, vertical: 10),
                  child: Text(
                    'MY EXAMS',
                    style: GoogleFonts.raleway(fontSize: 30, fontWeight: FontWeight.bold,color: White),
                  ),
                ),
                Container(
                  height: 400,
                  margin: const EdgeInsets.only(left:20, right:20, bottom: 20),
                  decoration: BoxDecoration(
                    color: NotWhite,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(3, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: _tests.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No exams available.', style: GoogleFonts.raleway(fontSize: 32)),
                        Text('Please add!', style: GoogleFonts.raleway(fontSize: 32)),
                        const SizedBox(height: 20),

                      ],
                    ),
                  )
                      :ReorderableListView(
                    onReorder: _updateTestOrder,
                    padding: const EdgeInsets.only(bottom: 80.0), // Padding to avoid overlap with button
                    children: [
                      for (int index = 0; index < _tests.length; index++)
                        Container(
                          key: ValueKey(_tests[index]['id']),
                          margin: const EdgeInsets.only(top:12, left: 16, right: 16),
                          decoration: BoxDecoration(
                            color: White,
                            border: Border.all(color: DeepPurple, width: 1),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0,3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            key: ValueKey(_tests[index]['id']),
                            title: Text(_tests[index]['title']),
                            subtitle: Text(_subjects[_tests[index]['subject_id']-1]['name']),
                            onTap: () => _navigateToTestDetailScreen(_tests[index]['id'], _tests[index]['title'], _tests[index]['subject_id']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditTestDialog(_tests[index]['id'], _tests[index]['title'], _tests[index]['subject_id']),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red[900]),
                                  onPressed: () => _showDeleteConfirmationDialog(_tests[index]['id']),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

                //if (_tests.isNotEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _showAddTestDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: White,
                        foregroundColor: DeepPurple,
                        side: const BorderSide(width: 2, color: DeepPurple),
                        padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 12), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Add Exam', style: GoogleFonts.raleway(fontSize: 24)),
                          const SizedBox(width: 8),
                          const Icon(Icons.add),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }
}