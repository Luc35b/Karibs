import 'dart:io';
import 'package:karibs/pdf_gen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/screens/test_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'teacher_dashboard.dart';
import 'package:karibs/overlay.dart';


class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  _TestsScreenState createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  List<Map<String, dynamic>> _tests = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  String? _testName; // To retain the test name
  int? _selectedSubjectId; // To retain the selected subject
  int? selectedTestId;
  String selectedTestTitle = '';

  @override
  void initState() {
    super.initState();
    _fetchTests();
    _fetchSubjects();
  }

  //fetch tests data from the database
  Future<void> _fetchTests() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.queryAllTests();
    setState(() {
      _tests = List<Map<String, dynamic>>.from(data);
    });
  }

  //fetch subjects data from the database
  Future<void> _fetchSubjects() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.queryAllSubjects();
    setState(() {
      _subjects = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  }

  //adds a new test to the database
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

  //show dialog for adding a new test
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

  //show dialog for adding a new subject
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

  // Method to show dialog for editing test name or subject
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
                  child: const Text('Save', style: TextStyle(fontSize: 20)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to edit test name in the database
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

  //show confirmation dialog
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

  //deletes test from database
  void _deleteTest(int testId) async {
    await DatabaseHelper().deleteTest(testId);
    _fetchTests();
  }

  //navigates to test detail screen
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

  //change the order of tests displayed
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

  //change the test order in the database
  Future<void> _updateOrderInDatabase() async {
    for (int i = 0; i < _tests.length; i++) {
      await DatabaseHelper().updateTestOrder(_tests[i]['id'], i);
    }
  }

  //show tutorial dialog for tests screen
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TestsScreenTutorialDialog();
      },
    );
  }

  Future<void> _importPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      String filePath = result.files.single.path!;
      await parsePDFAndInsertIntoDatabase(filePath);
    }
  }

  Future<void> parsePDFAndInsertIntoDatabase(String filePath) async {
    final PdfDocument document = PdfDocument(inputBytes: File(filePath).readAsBytesSync());

    String content = '';

    PdfTextExtractor textExtractor = PdfTextExtractor(document);
    content += '${textExtractor.extractText()}\n';

    print(content);

    // Initialize variables to store parsed data
    String testTitle = '';
    String subjectName = '';
    List<Map<String, dynamic>> questionsData = [];

    // Split the content into lines
    final lines = content.split('^');

    if (!content.startsWith('_Import_Format_')) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('PDF format does not match the required structure.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );
      throw Exception('Invalid PDF format');
    }

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim();

      // Parse test title and subject name
      if (line.startsWith('title')) {
        var header = line.split('|').map((e) => e.trim()).toList();
        testTitle = header[0].split(':')[1].trim().replaceAll('\n', '');
        subjectName = header[1].split(':')[1].trim().replaceAll('\n', '');
      }

      // Parse questions and choices
      if (line.startsWith('Q')) {
        var questionParts = line.split('|').map((e) => e.trim()).toList();
        if (questionParts.length >= 4) {
          var questionText = questionParts[0].split('.')[1].trim();
          var qt = questionText.replaceAll('\n', '');
          var type = questionParts[1];
          type = type == 'm_c' ? 'Multiple Choice' : 'Fill in the Blank';
          var categoryName = questionParts[2].trim().replaceAll('\n', ' ');;
          var essaySpaces = questionParts.length > 3 ? int.tryParse(questionParts[3]) : null;

          // Get or insert subject and category IDs
          int subjectId = await getOrInsertSubject(subjectName);
          int categoryId = await getOrInsertCategory(categoryName, subjectId);

          // Collect choices for the question
          List<Map<String, dynamic>> choices = [];
          for (var j = i + 1; j < lines.length; j++) {
            var choiceLine = lines[j].trim();
            if (choiceLine.startsWith('A')) {
              var choiceParts = choiceLine.split('|').map((e) => e.trim()).toList();
              if (choiceParts.length >= 2) {
                var choiceText = choiceParts[1];
                var ct = choiceText.replaceAll('\n', '');
                var isCorrect = choiceParts[2].toLowerCase() == 'true';
                choices.add({
                  'choice_text': ct,
                  'is_correct': isCorrect ? 1 : 0,
                });
              }
            } else {
              i = j - 1; // Update the outer loop index to continue from the correct position
              break; // End of choices
            }
          }

          // Store question data
          questionsData.add({
            'text': qt,
            'type': type,
            'category_id': categoryId,
            'essay_spaces': essaySpaces,
            'choices': choices,
          });
        }
      }
    }

    await insertTestData(testTitle, subjectName, questionsData);
    _fetchTests();
  }

  Future<int> getOrInsertSubject(String subjectName) async {
    final db = await DatabaseHelper().database;

    // Check if the subject already exists
    final result = await db.query(
      'subjects',
      where: 'name = ?',
      whereArgs: [subjectName],
    );

    if (result.isNotEmpty) {
      // Subject exists
      return result.first['id'] as int;
    } else {
      // Insert new subject
      final id = await db.insert('subjects', {'name': subjectName});
      return id;
    }
  }

  Future<int> getOrInsertCategory(String categoryName, int subjectId) async {
    final db = await DatabaseHelper().database;

    // Check if the category already exists
    final result = await db.query(
      'categories',
      where: 'name = ? AND subject_id = ?',
      whereArgs: [categoryName, subjectId],
    );

    if (result.isNotEmpty) {
      // Category exists
      return result.first['id'] as int;
    } else {
      // Insert new category
      final id = await db.insert('categories', {'name': categoryName, 'subject_id': subjectId});
      return id;
    }
  }


  Future<void> insertTestData(String testTitle, String subjectName, List<Map<String, dynamic>> questionsData) async {
    int subjectId = await getOrInsertSubject(subjectName);

    if (_tests.any((test) => test['title'] == testTitle)) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Exam with this name already exists. Please choose a different name.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );
      return;
    }

    int tId = await DatabaseHelper().insertTest({'title': testTitle, 'subject_id': subjectId});
    _fetchTests();

    for (var questionData in questionsData) {
      await insertQuestion(tId, questionData);
    }
  }


  Future<void> insertQuestion(int testId, Map<String, dynamic> questionData) async {
    int questionId = await DatabaseHelper().insertQuestion({
      'text': questionData['text'],
      'type': questionData['type'],
      'category_id': questionData['category_id'],
      'test_id': testId,
      'essay_spaces': questionData['essay_spaces'],
    });

    await insertQuestionChoices(questionId, questionData['choices']);
  }

  Future<void> insertQuestionChoices(int questionId, List<Map<String, dynamic>> choices) async {
    for (var choice in choices) {
      await DatabaseHelper().insertQuestionChoice({
        'question_id': questionId,
        'choice_text': choice['choice_text'],
        'is_correct': choice['is_correct'],
      });
    }
  }

  void _onExportPdfPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Test to Export'),
          content: _tests.isNotEmpty
              ? DropdownButtonFormField<Map<String, dynamic>>(
            items: _tests.map((test) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: test,
                child: Text(test['title']),
              );
            }).toList(),
            onChanged: (selectedTest) {
              if (selectedTest != null) {
                Navigator.pop(context);
                _fetchQuestions(selectedTest['id']);
                PdfGenerator(context).generateTestImportPdf(
                  selectedTest['id'],
                  selectedTest['title'],
                  selectedTest['subject_id'],
                );
              }
            },
            decoration: InputDecoration(labelText: 'Select Test'),
          )
              : Text('No tests available'),
        );
      },
    );
  }

  Future<void> _fetchQuestions(int selectedTestId) async {
    final data = await DatabaseHelper().queryAllQuestions(selectedTestId);
    List<Map<String, dynamic>> questions = List<Map<String, dynamic>>.from(data);

    // Load order from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedOrder = prefs.getStringList('test_${selectedTestId}_order');

    if (savedOrder != null) {
      questions.sort((a, b) {
        int aIndex = savedOrder.indexOf(a['id'].toString());
        int bIndex = savedOrder.indexOf(b['id'].toString());
        return aIndex.compareTo(bIndex);
      });
    }

    setState(() {
      _questions = questions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: DeepPurple,
          foregroundColor: White,
          title: Row(
            children: [
              Text('Exams'),
              SizedBox(width: 8), // Adjust spacing between title and icon
              IconButton(
                icon: Icon(Icons.help_outline),
                onPressed: () {
                  // Show tutorial dialog
                  _showTutorialDialog();
                },
              ),
            ]
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back), // Use the back arrow icon
            onPressed: () {
              Navigator.push(
                context,
                //zoom out page animation
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return TeacherDashboard();
                  },
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    // Define the zoom-out animation
                    var begin = 1.1; // Start with 1.5 times the normal size
                    var end = 1.0; // End with the normal size
                    var curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var scaleAnimation = animation.drive(tween);

                    return ScaleTransition(
                      scale: scaleAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.file_download),
              onPressed: _importPDF,
            ),
            IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: _onExportPdfPressed,
            ),
          ],
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
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: White),
                  ),
                ),
                Container(
                  height: 400,
                  margin: const EdgeInsets.only(left:20, right:20, bottom: 20),
                  decoration: BoxDecoration(
                    color: NotWhite,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
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
                        Text('No exams available.', style: TextStyle(fontSize: 32)),
                        Text('Please add!', style: TextStyle(fontSize: 32)),
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
                          //displays exams in the test dashboard
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
                                  icon:  Icon(Icons.delete, color: Colors.red[900],),
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
                          Text('ADD EXAM', style: TextStyle(fontSize: 28)),
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