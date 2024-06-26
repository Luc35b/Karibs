import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/screens/add_question_screen.dart';
import 'package:karibs/screens/test_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
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
    });
  }

  Future<void> _fetchSubjects() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.queryAllSubjects();
    setState(() {
      _subjects = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
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
                  child: const Text('Save', style: TextStyle(fontSize: 20)),
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

  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TestsScreenTutorialDialog();
      },
    );
  }

  Future<void> _importPDF() async {
    // Use a file picker to choose a PDF file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      String filePath = result.files.single.path!;
      // Call the import and validation method
      await parsePDFAndInsertIntoDatabase(filePath);
    }
  }

// Function to parse PDF content and format data for database insertion
  Future<void> parsePDFAndInsertIntoDatabase(String filePath) async {
    final File file = File(filePath);
    final data = await file.readAsBytes();

    // Parse PDF content using pdf package
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(
        child: pw.Text('Parsing...'),
      );
    }));

    // Write the parsed content to a temporary file
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/parsed.pdf');
    await tempFile.writeAsBytes(await pdf.save());

    // Read the text content from the temporary file
    final content = await tempFile.readAsString();

    // Initialize variables to store parsed data
    String testTitle = '';
    int subjectId = 0;
    List<Map<String, dynamic>> questionsData = [];

    // Validate the import format
    if (!content.startsWith('_Import Format_')) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('PDF format does not match the required structure.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );
      throw Exception('Invalid PDF format');
    }

    // Split the content into lines
    final lines = content.split('\n');

    // Example parsing logic (replace with your actual PDF parsing logic)
    for (var line in lines) {
      // Example: Parse test title and subject ID
      if (line.startsWith('')) {
        var header = line.split(',').map((e) => e.trim()).toList();
        testTitle = header[0].split(':')[1].trim();
        subjectId = int.tryParse(header[1].split(':')[1].trim()) ?? 0;
      }

      // Example: Parse questions and choices
      if (line.startsWith('Q. ')) {
        var questionParts = line.split(',').map((e) => e.trim()).toList();
        if (questionParts.length >= 4) {
          var questionText = questionParts[1];
          var type = questionParts[2];
          var categoryId = int.tryParse(questionParts[3]) ?? 0;
          var essaySpaces = int.tryParse(questionParts[4]) ?? null;

          // Collect choices for the question
          List<Map<String, dynamic>> choices = [];
          for (var j = lines.indexOf(line) + 1; j < lines.length; j++) {
            var choiceLine = lines[j].trim();
            if (choiceLine.startsWith('A.')) {
              var choiceParts = choiceLine.split(',').map((e) => e.trim()).toList();
              if (choiceParts.length >= 3) {
                var choiceText = choiceParts[1];
                var isCorrect = choiceParts[2].toLowerCase() == 'true';
                choices.add({
                  'choice_text': choiceText,
                  'is_correct': isCorrect ? 1 : 0,
                });
              }
            } else {
              break; // End of choices
            }
          }

          // Store question data
          questionsData.add({
            'text': questionText,
            'type': type,
            'category_id': categoryId,
            'essay_spaces': essaySpaces,
            'choices': choices,
          });
        }
      }
    }

    await insertTestData(testTitle, subjectId, questionsData);
  }

  Future<void> insertTestData(String testTitle, int subjectId, List<Map<String, dynamic>> questionsData) async {
    // Replace with your actual database insertion logic
    int tId = await DatabaseHelper().insertTest({'title': testTitle, 'subject_id': subjectId});

    for (var questionData in questionsData) {
      await insertQuestion(tId, questionData);
    }
  }

// Example function to insert question into questions table
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

// Example function to insert question choices into question_choices table
  Future<void> insertQuestionChoices(int questionId, List<Map<String, dynamic>> choices) async {
    for (var choice in choices) {
      await DatabaseHelper().insertQuestionChoice({
        'question_id': questionId,
        'choice_text': choice['choice_text'],
        'is_correct': choice['is_correct'],
      });
    }
  }





  /*Future<void> importAndValidatePDF(String filePath) async {
    File file = File(filePath);

    if () {

    } else {
      // Show error Snackbar indicating incorrect format
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('PDF format does not match the required structure.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: DeepPurple,
          foregroundColor: White,
          title: Row(
            children:[
              Text('Exams'),
              SizedBox(width: 8),
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
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TeacherDashboard()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.file_download),
              onPressed: _importPDF,
            ),
            IconButton(
              icon: Icon(Icons.file_upload),
              onPressed: _importPDF,
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
                    style: GoogleFonts.raleway(fontSize: 30, fontWeight: FontWeight.bold,color: White),
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