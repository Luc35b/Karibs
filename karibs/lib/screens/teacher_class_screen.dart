import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'student_info_screen.dart';
import 'add_student_screen.dart';

class TeacherClassScreen extends StatefulWidget {
  final int classId;

  TeacherClassScreen({required this.classId});

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
      return Colors.blueGrey;
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
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final data = await DatabaseHelper().queryAllStudents(widget.classId);
    setState(() {
      _students = data;
      _filteredStudents = List.from(_students);
      _isLoading = false;
    });
  }

  void _addStudent(Map<String, dynamic> student) async {
    await DatabaseHelper().insertStudent(student);
    _fetchStudents();
  }

  void _navigateToAddStudentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStudentScreen(
          classId: widget.classId,
          onStudentAdded: (student) {
            _addStudent(student);
          },
        ),
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Class Screen'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: _showStatusFilterDialog,
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterStudents,
                        decoration: InputDecoration(
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
              Expanded(
                child: _students.isNotEmpty
                    ? ListView.builder(
                  itemCount: _filteredStudents.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: getStatusColor(
                                    _filteredStudents[index]['status']),
                              ),
                              child: Center(
                                child: Text(
                                  '${_filteredStudents[index]['average_score']?.round() ?? ''}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              '${_filteredStudents[index]['name']}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(_filteredStudents[index]['status'] ?? 'No status'),
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
            ],
          ),
          Positioned(
            left: 115,
            bottom: 10,
            child: ElevatedButton(
              onPressed: _navigateToAddStudentScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Add Student +',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
