import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/screens/teacher_class_screen.dart';
import 'package:karibs/screens/test_detail_screen.dart';
import 'package:karibs/screens/tests_screen.dart';
import 'package:google_fonts/google_fonts.dart';

const Color DeepPurple = Color(0xFF250A4E);
const Color MidPurple = Color(0xFF7c6c94);
const Color LightPurple = Color(0xFFEFDAF9);
const Color NotWhite = Color(0xFFEFEBF1);
const Color White = Colors.white;

class TeacherDashboard extends StatefulWidget {
  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _tests = [];
  List<Map<String, dynamic>> _subjects = [];

  List<String> classesList = [
    'Basic 1',
    'Basic 2',
    'Basic 3',
    'Basic 4',
    'Basic 5',
    'Basic 6',
    'Basic 7',
    'Basic 8',
    'Basic 9',
  ];

  List<String> subjectsList = [
    'Math',
    'Science',
    'History',
    'English',
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
    _fetchSubjects();
    _getOrCreateSubjectId('Math');
    _getOrCreateSubjectId('Science');
    _getOrCreateSubjectId('History');
    _getOrCreateSubjectId('English');
  }

  Future<void> _fetchSubjects() async {
    final sData = await DatabaseHelper().queryAllSubjects();

    // Extract subject names from sData
    List<String> fetchedSubjects = [];
    for (var subject in sData) {
      fetchedSubjects.add(subject['name'].toString());
    }

    setState(() {
      subjectsList.clear(); // Clear existing subjectsList
      subjectsList.addAll(fetchedSubjects); // Add fetched subject names to subjectsList
    });
  }


  Future<void> _fetchClasses() async {
    final cData = await DatabaseHelper().queryAllClassesWithSubjects();
    final tData = await DatabaseHelper().queryAllTests();
    setState(() {
      _classes = cData;
      _tests = tData;
      _isLoading = false;
    });
    print(_classes);
  }
  void _deleteClass(int classId) async{
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Class'),
        content: Text('Are you sure you want to delete this class?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: Text('Delete'),
          ),
        ],
      ),
    );
    // Delete the student if confirmed
    if (confirmDelete == true) {
      await DatabaseHelper().deleteClass(classId);
      _fetchClasses();//refresh screen after delete
      _fetchSubjects();
    }
  }

  void _addClass(String className, String subjectName) async {
    // First, check if the subject already exists in the subjects table
    int subjectId = await _getOrCreateSubjectId(subjectName);

    // Now insert the class into the classes table
    await DatabaseHelper().insertClass({
      'name': className,
      'subject_id': subjectId,
    });

    _fetchClasses();// Refresh the UI or list of classes
    _fetchSubjects();
  }

  Future<int> _getOrCreateSubjectId(String subjectName) async {
    final db = await DatabaseHelper().database;

    // Check if the subject already exists
    List<Map<String, dynamic>> results = await db.query(
      'subjects',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [subjectName],
    );

    if (results.isNotEmpty) {
      // Subject exists, return its ID
      return results.first['id'];
    } else {
      // Subject does not exist, insert and return its ID
      int subjectId = await db.insert('subjects', {'name': subjectName});
      return subjectId;
    }
  }



  void _showAddClassDialog() {
    _fetchSubjects();

    String? selectedClass;
    String? selectedSubject;

    TextEditingController customClassController = TextEditingController();
    TextEditingController customSubjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Class'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          hint: Text('Select Class'),
                          value: selectedClass,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedClass = newValue;
                            });
                            if (newValue == 'Add New Class') {
                              customClassController.clear();
                            }
                          },
                          items: [
                            ...classesList.map((classItem) {
                              return DropdownMenuItem<String>(
                                value: classItem,
                                child: Text(classItem),
                              );
                            }),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          String? customClassName = await _showCustomClassDialog();
                          if (customClassName != null && customClassName.isNotEmpty) {
                            setState(() {
                              if (!classesList.contains(customClassName)) {
                                classesList.add(customClassName);
                              }
                              selectedClass = customClassName;
                            });
                          }
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                  if (selectedClass == 'Add New Class')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: customClassController,
                          decoration: InputDecoration(labelText: 'Enter custom class'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Enter additional details for custom class...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          hint: Text('Select Subject'),
                          value: selectedSubject,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSubject = newValue;
                            });
                            if (newValue == 'Add New Subject') {
                              customSubjectController.clear();
                            }
                          },
                          items: [
                            ...subjectsList.map((subject) {
                              return DropdownMenuItem<String>(
                                value: subject,
                                child: Text(subject),
                              );
                            }),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          String? customSubjectName = await _showCustomSubjectDialog();
                          if (customSubjectName != null && customSubjectName.isNotEmpty) {
                            setState(() {
                              if (!subjectsList.contains(customSubjectName)) {
                                subjectsList.add(customSubjectName);
                              }
                              selectedSubject = customSubjectName;
                            });
                          }
                        },
                        icon: Icon(Icons.add),
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
                    String classToAdd = selectedClass ?? '';
                    String subjectToAdd = selectedSubject ?? '';

                    if (classToAdd.isNotEmpty && subjectToAdd.isNotEmpty) {
                      _addClass(classToAdd, subjectToAdd);
                    }

                    Navigator.of(context).pop();
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


  Future<String?> _showCustomClassDialog() async {
    TextEditingController customClassController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Custom Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: customClassController,
                decoration: InputDecoration(labelText: 'Enter custom class'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without adding
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String customClassName = customClassController.text.trim();
                Navigator.of(context).pop(customClassName); // Return custom class name
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showCustomSubjectDialog() async {
    TextEditingController customSubjectController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Custom Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: customSubjectController,
                decoration: InputDecoration(labelText: 'Enter custom subject'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without adding
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String customSubjectName = customSubjectController.text.trim();
                Navigator.of(context).pop(customSubjectName); // Return custom subject name
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
    // ).then((_){
    //   focusNode.dispose();
    // });
    //
    // Future.delayed(Duration(milliseconds: 100), (){
    //   focusNode.requestFocus();
    // });
  }

  void _showEditClassDialog(int classId, String currentClassName, String currentSubjectName) {
    final TextEditingController classNameController = TextEditingController(text: currentClassName);
    String selectedClass = currentClassName; // Track selected class
    String selectedSubject = currentSubjectName; // Track selected subject

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Class Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          hint: Text('Select Class'),
                          value: selectedClass,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedClass = newValue!;
                            });
                          },
                          items: [
                            ...classesList.map((classItem) {
                              return DropdownMenuItem<String>(
                                value: classItem,
                                child: Text(classItem),
                              );
                            }),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          String? customClassName = await _showCustomClassDialog();
                          if (customClassName != null && customClassName.isNotEmpty) {
                            setState(() {
                              if (!classesList.contains(customClassName)) {
                                classesList.add(customClassName);
                                _fetchClasses();
                              }
                              selectedClass = customClassName;
                            });
                          }
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          hint: Text('Select Subject'),
                          value: selectedSubject,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSubject = newValue!;
                            });
                          },
                          items: [
                            ...subjectsList.map((subject) {
                              return DropdownMenuItem<String>(
                                value: subject,
                                child: Text(subject),
                              );
                            }),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          String? customSubjectName = await _showCustomSubjectDialog();
                          if (customSubjectName != null && customSubjectName.isNotEmpty) {
                            setState(() {
                              if (!subjectsList.contains(customSubjectName)) {
                                subjectsList.add(customSubjectName);
                                _getOrCreateSubjectId(customSubjectName);
                                _fetchSubjects();
                              }
                              selectedSubject = customSubjectName;
                            });
                          }
                        },
                        icon: Icon(Icons.add),
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
                    String newClassName = selectedClass;
                    String newSubjectName = selectedSubject;

                    if (newClassName.isNotEmpty && newSubjectName.isNotEmpty) {
                      _editClassDetails(classId, newClassName, newSubjectName);
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



  void _editClassDetails(int classId, String newClassName, String newSubjectName) async {
    print('Updating class with ID: $classId');
    print('New class name: $newClassName');
    print('New subject name: $newSubjectName');
    int? newSubjectId = await DatabaseHelper().getSubjectId(newSubjectName);
    print('new subject id: ' + newSubjectId.toString());
    _editClassName(classId, newClassName, newSubjectId!);

  }

  void _editClassName(int classId, String newClassName, int newSubjectId) async {
    await DatabaseHelper().updateClass(classId, {'name': newClassName, 'subject_id': newSubjectId});
    _fetchClasses();
    _fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Dashboard'),
        backgroundColor: DeepPurple,
        foregroundColor: White,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child:Column(
          children: [
            SizedBox(height: 100),
            Container(margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: MidPurple,
                //border: Border.all(width: 3),
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
                children:[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:40, vertical: 10),
                    child: Text(
                      'MY CLASSES',
                      style: GoogleFonts.raleway(fontSize: 30, fontWeight: FontWeight.bold,color: White),
                    ),
                  ),
                  Container(
                    height: 250, // Adjust height as needed
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: NotWhite,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(3, 3), // Shadow position
                        ),
                      ],
                    ),

                    child: _classes.isEmpty
                        ? Center(
                      child: Text(
                        'No classes available. \n Please add a class.',
                        style: GoogleFonts.raleway(fontSize: 24),
                      ),
                    ) :SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _classes.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: White, // Background color of the box
                                  //borderRadius: BorderRadius.circular(20), // Rounded corners for the box
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                  border: Border.all(color: MidPurple, width: 2),
                                ),
                                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                child: ListTile(
                                  title: Text(
                                    _classes[index]['name'],
                                    style: TextStyle(fontSize: 32),
                                  ),
                                  subtitle: Text(
                                    _classes[index]['subjectName'],
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {_showEditClassDialog(_classes[index]['id'], _classes[index]['name'], _classes[index]['subjectName']);},
                                        icon: Icon(Icons.edit),
                                      ),
                                      IconButton(
                                        onPressed: () {_deleteClass(_classes[index]['id']);},
                                        color: Colors.red[900],
                                        icon: Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TeacherClassScreen(
                                          classId: _classes[index]['id'],
                                          refresh: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),


                              );
                            },
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddClassDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: White,
                      foregroundColor: DeepPurple,
                      side: BorderSide(width: 2, color: DeepPurple),
                      padding: EdgeInsets.symmetric(horizontal: 55, vertical: 12), // Button padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'ADD CLASS +',
                      style: GoogleFonts.raleway(fontSize: 25),
                    ),
                  ),
                  SizedBox(height: 20),

                ],
              ),
            ),


            SizedBox(height: 15),
            Container(margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: MidPurple,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  //topLeft: Radius.circular(30),
                  //bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(3, 3), // Shadow position
                  ),
                ],
              ),


            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestsScreen()),
                ).then((_){
                  _fetchSubjects();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: White,
                side: BorderSide(width: 2, color: DeepPurple),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                '  MANAGE TESTS  ',
                style: GoogleFonts.raleway(fontSize: 25, color: DeepPurple),
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}