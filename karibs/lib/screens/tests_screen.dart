import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/screens/add_question_screen.dart';
import 'package:karibs/screens/test_detail_screen.dart';

class TestsScreen extends StatefulWidget {
  @override
  _TestsScreenState createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  List<Map<String, dynamic>> _tests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTests();
  }

  Future<void> _fetchTests() async {
    final data = await DatabaseHelper().queryAllTests();
    setState(() {
      _tests = data;
      _isLoading = false;
    });
  }

  void _addTest(String testName) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tests'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No tests available. Please add!'),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _showAddTestDialog,
              child: Icon(Icons.add),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          ListView.builder(
            itemCount: _tests.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_tests[index]['title']),
                onTap: () => _navigateToTestDetailScreen(_tests[index]['id'], _tests[index]['title']),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _navigateToAddQuestionScreen(_tests[index]['id']),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _showAddTestDialog,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
