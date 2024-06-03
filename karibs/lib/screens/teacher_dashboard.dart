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
        title: Text('My Dashboard'),
        backgroundColor: DeepPurple,
        foregroundColor: White,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          :
      Column(
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
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                              child: ListTile(
                                title: Text(
                                  _classes[index]['name'],
                                  style: TextStyle(fontSize: 32),
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
              );
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
    );
  }
}
