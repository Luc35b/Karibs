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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTests();
  }

  Future<void> _fetchTests() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.queryAllTests();
    setState(() {
      _tests = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  }

  void _addTest(String testName) async {
    if (_tests.any((test) => test['title'] == testName)) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Test with this name already exists. Please choose a different name.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );
      return;
    }

    await DatabaseHelper().insertTest({'title': testName});
    _fetchTests();
  }

  void _showAddTestDialog() {
    final TextEditingController testNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Test'),
          content: TextField(
            controller: testNameController,
            decoration: InputDecoration(labelText: 'Test Title'),
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
                if (testNameController.text.isNotEmpty) {
                  _addTest(testNameController.text);
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

  void _showEditTestDialog(int testId, String currentTitle) {
    final TextEditingController testNameController = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Test Name'),
          content: TextField(
            controller: testNameController,
            decoration: InputDecoration(labelText: 'Test Title'),
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
                if (testNameController.text.isNotEmpty) {
                  _editTestName(testId, testNameController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editTestName(int testId, String newTitle) async {
    if (_tests.any((test) => test['title'] == newTitle && test['id'] != testId)) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Test with this name already exists. Please choose a different name.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );
      return;
    }

    await DatabaseHelper().updateTest(testId, {'title': newTitle});
    _fetchTests();
  }

  void _showDeleteConfirmationDialog(int testId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Test'),
          content: Text('Are you sure you want to delete this test?'),
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

  void _navigateToTestDetailScreen(int testId, String testTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestDetailScreen(
          testId: testId,
          testTitle: testTitle,
        ),
      ),
    );
  }

  void _navigateToAddQuestionScreen(int testId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(
          testId: testId,
          onQuestionAdded: _fetchTests,
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
          foregroundColor: White,
          backgroundColor: DeepPurple,
          title: Text('Tests'),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            :Stack(
          children: [
            _tests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No tests available.', style: GoogleFonts.raleway(fontSize: 36)),
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
                    onTap: () => _navigateToTestDetailScreen(_tests[index]['id'], _tests[index]['title']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _navigateToAddQuestionScreen(_tests[index]['id']),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showEditTestDialog(_tests[index]['id'], _tests[index]['title']),
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
                      side: BorderSide(width: 2, color: DeepPurple),
                      padding: EdgeInsets.symmetric(horizontal: 55, vertical: 12), // Button padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Add Test', style: GoogleFonts.raleway(fontSize: 24),),
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
