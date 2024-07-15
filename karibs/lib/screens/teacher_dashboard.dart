import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/overlay.dart';
import 'package:karibs/screens/teacher_class_screen.dart';
import 'package:karibs/screens/tests_screen.dart';

const Color DeepPurple = Color(0xFF250A4E);
const Color MidPurple = Color(0xFF7c6c94);
const Color LightPurple = Color(0xFFEFDAF9);
const Color NotWhite = Color(0xFFEFEBF1);
const Color White = Colors.white;

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

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
    'None'
  ];

  bool _isLoading = true;

  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TeacherDashboardTutorialDialog();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchClasses();
    _fetchSubjects();
    _getOrCreateSubjectId('Math');
    _getOrCreateSubjectId('Science');
    _getOrCreateSubjectId('History');
    _getOrCreateSubjectId('English');
    _getOrCreateSubjectId('None');
  }

  Future<void> _fetchSubjects() async {
    final sData = await DatabaseHelper().queryAllSubjects();

    // Extract subject names from sData
    List<String> fetchedSubjects = [];
    for (var subject in sData) {
      fetchedSubjects.add(subject['name'].toString());
    }

    setState(() {
      _subjects = sData;
      subjectsList.clear(); // Clear existing subjectsList
      subjectsList.addAll(fetchedSubjects); // Add fetched subject names to subjectsList
    });
  }


  Future<void> _fetchClasses() async {
    final cData = await DatabaseHelper().queryAllClassesWithSubjects();
    final tData = await DatabaseHelper().queryAllTests();
    setState(() {
      _classes = cData.reversed.toList();
      _tests = tData;
      _isLoading = false;
    });
    print(_classes);
  }

  void _deleteClass(int classId) async{
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text('Are you sure you want to delete this class?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('Cancel', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: const Text('Delete', style: TextStyle(fontSize: 20)),
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

    // Check if a class with the same name and subject already exists
    bool classExists = await DatabaseHelper().classExists(className, subjectId);

    if (classExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Class $className for subject $subjectName already exists.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Now insert the class into the classes table
    await DatabaseHelper().insertClass({
      'name': className,
      'subject_id': subjectId,
    });

    _fetchClasses(); // Refresh the UI or list of classes
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
              title: const Text('Add New Class'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          hint: const Text('Select Class'),
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
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  if (selectedClass == 'Add New Class')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: customClassController,
                          decoration: const InputDecoration(labelText: 'Enter custom class'),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Enter additional details for custom class...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          hint: const Text('Select Subject'),
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
                        icon: const Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () async {
                          await _showManageSubjectsDialog();
                          _fetchSubjects();
                        },
                        icon: const Icon(Icons.remove),
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
                    String classToAdd = selectedClass ?? '';
                    String subjectToAdd = selectedSubject ?? '';

                    if (classToAdd.isNotEmpty && subjectToAdd.isNotEmpty) {
                      _addClass(classToAdd, subjectToAdd);
                    }

                    Navigator.of(context).pop();
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


  Future<String?> _showCustomClassDialog() async {
    TextEditingController customClassController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Custom Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: customClassController,
                decoration: const InputDecoration(labelText: 'Enter custom class'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without adding
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: () {
                String customClassName = customClassController.text.trim();
                Navigator.of(context).pop(customClassName); // Return custom class name
              },
              child: const Text('Add', style: TextStyle(fontSize: 20)),
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
          title: const Text('Add Custom Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: customSubjectController,
                decoration: const InputDecoration(labelText: 'Enter custom subject'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without adding
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: () {
                String customSubjectName = customSubjectController.text.trim();
                Navigator.of(context).pop(customSubjectName); // Return custom subject name
              },
              child: const Text('Add', style: TextStyle(fontSize: 20)),
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

  Future<void> _showManageSubjectsDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Manage Subjects'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: subjectsList.length,
                  itemBuilder: (context, index) {
                    bool isNoneSubject = subjectsList[index] == 'None';
                    return ListTile(
                      title: Text(subjectsList[index]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: isNoneSubject ? null : () async {
                              await _showEditSubjectDialog(index, subjectsList[index]);
                            },
                            color: isNoneSubject ? Colors.grey : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: isNoneSubject ? null : () async {
                              await _showConfirmDeleteDialog(index);
                            },
                            color: isNoneSubject ? Colors.grey : Colors.red,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    _showAddClassDialog();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }




  Future<String?> _showEditSubjectDialog(int index, String currentName) async {
    TextEditingController _nameController = TextEditingController(text: currentName);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Subject'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Subject Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper().updateSubject(_subjects[index]['id'], _nameController.text);
                Navigator.of(context).pop(_nameController.text.trim());
                await _fetchSubjects(); // Refresh the subjects list
                Navigator.of(context).pop(); // Close the manage dialog
                _showManageSubjectsDialog(); // Reopen the manage dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }


  Future<bool?> _showConfirmDeleteDialog(int index) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: const Text('Are you sure you want to delete this subject?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                    await DatabaseHelper().deleteSubject(_subjects[index]['id']);
                    Navigator.of(context).pop(true);
                    await _fetchSubjects(); // Refresh the subjects list
                    Navigator.of(context).pop(); // Close the manage dialog
                    _showManageSubjectsDialog();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
              title: const Text('Edit Class Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          hint: const Text('Select Class'),
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
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          hint: const Text('Select Subject'),
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
                        icon: const Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () async {
                          await _showManageSubjectsDialog();
                          _fetchSubjects();
                        },
                        icon: const Icon(Icons.remove),
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
                    String newClassName = selectedClass;
                    String newSubjectName = selectedSubject;

                    if (newClassName.isNotEmpty && newSubjectName.isNotEmpty) {
                      _editClassDetails(classId, newClassName, newSubjectName);
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



  void _editClassDetails(int classId, String newClassName, String newSubjectName) async {
    print('Updating class with ID: $classId');
    print('New class name: $newClassName');
    print('New subject name: $newSubjectName');
    int? newSubjectId = await DatabaseHelper().getSubjectId(newSubjectName);
    print('new subject id: $newSubjectId');
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

        title: Row(
          children: [
            const Text('Teacher Dashboard'),
            SizedBox(width: 8), // Adjust spacing between title and icon
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                // Show tutorial dialog
                _showTutorialDialog();
              },
            ),
          ],
        ),

        backgroundColor: DeepPurple,
        foregroundColor: White,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child:Column(
          children: [
            const SizedBox(height: 100),
            Container(margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
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
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: White),
                    ),
                  ),
                  Container(
                    height: 250, // Adjust height as needed
                    margin: const EdgeInsets.symmetric(horizontal: 20),
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

                    child: _classes.isEmpty
                        ? Center(
                      child: Text(
                        'No classes available. \n Please add a class.',
                        style: TextStyle(fontSize: 28),
                      ),
                    ) :SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _classes.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: White, // Background color of the box
                                  //borderRadius: BorderRadius.circular(20), // Rounded corners for the box
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                  border: Border.all(color: MidPurple, width: 2),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                child: ListTile(
                                  title: Text(
                                    _classes[index]['name'],
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  subtitle: Text(
                                    _classes[index]['subjectName'],
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {_showEditClassDialog(_classes[index]['id'], _classes[index]['name'], _classes[index]['subjectName']);},
                                        icon: const Icon(Icons.edit),
                                      ),
                                      IconButton(
                                        onPressed: () {_deleteClass(_classes[index]['id']);},
                                        color: Colors.red[900],
                                        icon: const Icon(Icons.delete),
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
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddClassDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: White,
                      foregroundColor: DeepPurple,
                      side: const BorderSide(width: 2, color: DeepPurple),
                      padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 12), // Button padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'ADD CLASS +',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  const SizedBox(height: 20),

                ],
              ),
            ),


            const SizedBox(height: 15),
            Container(margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
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
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TestsScreen()),
                ).then((_){
                  _fetchSubjects();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: White,
                side: const BorderSide(width: 2, color: DeepPurple),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                '  MANAGE EXAMS  ',
                style: TextStyle(fontSize: 25, color: DeepPurple),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}