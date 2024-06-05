import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/main.dart';
import 'package:karibs/providers/student_grading_provider.dart';
import 'package:provider/provider.dart';
import 'student_info_screen.dart';


class TeacherClassScreen extends StatefulWidget {
  final int classId;
  final bool refresh;


  TeacherClassScreen({required this.classId, required this.refresh});

  @override
  _TeacherClassScreenState createState() => _TeacherClassScreenState();
}

Color getStatusColor(String currStatus) {
  switch (currStatus) {
    case 'Doing well':
      return Colors.green;
    case 'Doing okay':
      return Color(0xFFe6cc00);
    case 'Needs help':
      return Colors.red;
    case 'No status':
      return LightPurple;
    default:
      return Colors.white;
  }
}
Color getStatusColorFill(String currStatus) {
  switch (currStatus) {
    case 'Doing well':
      return Color(0xFFBBFABB);
    case 'Doing okay':
      return Color(0xFFFAECBB);
    case 'Needs help':
      return Color(0xFFFABBBB);
    case 'No status':
      return Color(0xFFD8D0DB);
    default:
      return Colors.white;
  }
}

String changeStatus(double avgScore) {
  if (avgScore >= 70) {
    return 'Doing well';
  } else if (avgScore >= 50) {
    return 'Doing okay';
  } else {
    return 'Needs help';
  }
}

class _TeacherClassScreenState extends State<TeacherClassScreen> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  //final TextEditingController _studentNameController = TextEditingController();
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  @override
  void didChangeDependencies() {
    if (widget.refresh) {
      _fetchStudents();
    }
    super.didChangeDependencies();
  }

  Future<void> _fetchStudents() async {
    var data = await DatabaseHelper().queryAllStudents(widget.classId);
    if(data.length > 0) {
      for (var i = 0; i < data.length; i++) {
        var x = await DatabaseHelper().queryAverageScore(data[i]['id']);
        print("avg score for student " + data[i]['id'].toString() + " is: " +
            x.toString());
        if (x != null) {
          String stat = changeStatus(x);
          final status = await DatabaseHelper().updateStudentStatus(
              data[i]['id'], stat);
          print("status: " + data[i]['status']);
        }
        else {
          String stat = "No status";
          final status = await DatabaseHelper().updateStudentStatus(
              data[i]['id'], stat);
          print("status: " + data[i]['status']);
        }
      }
    }

    data = await DatabaseHelper().queryAllStudents(widget.classId);
    print('hi');
    setState(() {
      _students = data;
      _filteredStudents = List.from(data);
      _isLoading = false;
    });
  }

  void _addStudent(String studentName) async{
    await DatabaseHelper().insertStudent({'name': studentName, 'class_id': widget.classId, 'status': "No status"});
    _fetchStudents();
  }
  void _showAddStudentDialog() {
    final TextEditingController studentNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Student'),
          content: TextField(
            controller: studentNameController,
            decoration: InputDecoration(labelText: 'Student Name'),
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
                if (studentNameController.text.isNotEmpty) {
                  _addStudent(studentNameController.text);
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

  Future<void> _navigateToStudentInfoScreen(int studentId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentInfoScreen(studentId: studentId),
      ),
    );

    if (result == true) {
      _fetchStudents();
    }
  }

  void _filterStudents(String query) {
    setState(() {
      List<Map<String, dynamic>> filteredList = _students;
      if (_selectedStatus != 'All') {
        filteredList = filteredList.where((student) {
          return student['status'] == _selectedStatus;
        }).toList();
      }
      if (query.isNotEmpty) {
        filteredList = filteredList.where((student) {
          return student['name'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      _filteredStudents = filteredList;
    });
  }

  void _filterByStatus(String status) {
    setState(() {
      _selectedStatus = status;
      _filterStudents(_searchController.text);
    });
  }

  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter by Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <String>[
              'All',
              'Doing well',
              'Doing okay',
              'Needs help',
              'No status'
            ].map((String value) {
              return RadioListTile<String>(
                title: Text(value),
                value: value,
                groupValue: _selectedStatus,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _filterByStatus(newValue);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<StudentGradingProvider>(
      builder: (context, studentGradingProvider, child) {
        // Listen for changes and refresh data when 'grade' method is called
        if (studentGradingProvider.update > 0) {
          print(studentGradingProvider.update);
          _fetchStudents();
          print(_students);
          print('fetched students');
          studentGradingProvider.reset();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Teacher Class Screen'),
            backgroundColor: DeepPurple,
            foregroundColor: White,
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 10,),

                  Container(margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
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
                        SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.filter_list,
                                  color: White,
                                ),
                                onPressed: _showStatusFilterDialog,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _filterStudents,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: NotWhite,
                                    labelText: 'Search by student name',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                        ),
                        Container(
                          height: 450,
                          margin: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: NotWhite,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(3,3),
                              )
                            ]
                          ),
                          child: _students.isNotEmpty
                              ? ListView.builder(
                            itemCount: _filteredStudents.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: White,
                                  border: Border.all(color: DeepPurple, width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: EdgeInsets.all(10),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      SizedBox(
                                        width: 85,
                                        child: Column(
                                          //status column
                                          children: [
                                            Row( //to center the icon above status
                                              children: [
                                                SizedBox(width: 15,),
                                                Container(
                                                  width: 45,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: getStatusColor(
                                                        _filteredStudents[index]
                                                        ['status']), width: 2),
                                                    color:
                                                    getStatusColorFill(
                                                        _filteredStudents[index]
                                                        ['status']),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${_filteredStudents[index]['average_score']
                                                          ?.round() ?? ''}',
                                                      style: TextStyle(
                                                        color: DeepPurple,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Text(
                                                _filteredStudents[index]['status'] ??
                                                    'No status'
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(width: 25),
                                      Text(
                                    '${_filteredStudents[index]['name']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                      ),
                                    ), //Name
                                    ],
                                  ),

                              onTap: () {
                              _navigateToStudentInfoScreen(
                              _filteredStudents[index]['id']);
                              },
                                ),
                              );

                            },
                          )
                              : Center(
                            child: Text(
                              'No students available. \nPlease add!',
                              style: TextStyle(fontSize: 30),
                            ),
                          ),

                        ),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: _showAddStudentDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: White,
                      foregroundColor: DeepPurple,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      side: BorderSide(width: 1, color: DeepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Add Student +',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ],

              ),
            ],
          ),
          ),
        );
      },
    );
  }
}