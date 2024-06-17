import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/screens/teacher_class_screen.dart';
import 'package:karibs/screens/tests_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    final cData = await DatabaseHelper().queryAllClasses();
    final tData = await DatabaseHelper().queryAllTests();
    setState(() {
      _classes = cData;
      _tests = tData;
      _isLoading = false;
    });
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
    }
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
          title: const Text('Add New Class'),
          content: TextField(
            controller: classNameController,
            decoration: const InputDecoration(labelText: 'Class Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: const Text(
                  'Cancel', style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (classNameController.text.isNotEmpty) {
                  _addClass(classNameController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Text(
                  'Add',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditClassDialog(int classId, String currentClassName) {
    final TextEditingController classNameController = TextEditingController(text: currentClassName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Class Name'),
          content: TextField(
            controller: classNameController,
            decoration: const InputDecoration(labelText: 'Class Name'),
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
                if (classNameController.text.isNotEmpty) {
                  _editClassName(classId, classNameController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  void _editClassName(int classId, String newClassName) async {
    await DatabaseHelper().updateClass(classId, {'name': newClassName});
    _fetchClasses();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        backgroundColor: DeepPurple,
        foregroundColor: White,
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
                    style: GoogleFonts.raleway(fontSize: 30, fontWeight: FontWeight.bold,color: White),
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
                      style: GoogleFonts.raleway(fontSize: 24),
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
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {_showEditClassDialog(_classes[index]['id'], _classes[index]['name']);},
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () {_deleteClass(_classes[index]['id']);},
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
                    style: GoogleFonts.raleway(fontSize: 25),
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
              );
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
              '  MANAGE TESTS  ',
              style: GoogleFonts.raleway(fontSize: 25, color: DeepPurple),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
      ),
    );
  }
}
