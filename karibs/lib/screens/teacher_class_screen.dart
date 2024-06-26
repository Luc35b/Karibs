import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/overlay.dart';
import 'package:karibs/providers/student_grading_provider.dart';
import 'package:provider/provider.dart';
import '../pdf_gen.dart';
import 'student_info_screen.dart';
import 'teacher_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TeacherClassScreen extends StatefulWidget {
  final int classId;
  final bool refresh;

  const TeacherClassScreen({super.key, required this.classId, required this.refresh});

  @override
  _TeacherClassScreenState createState() => _TeacherClassScreenState();
}

//returns color based on student status
Color getStatusColor(String currStatus) {
  switch (currStatus) {
    case 'Doing well':
      return Colors.green;
    case 'Doing okay':
      return const Color(0xFFe6cc00);
    case 'Doing poorly':
      return Colors.orange;
    case 'Needs help':
      return Colors.red;
    case 'No status':
      return LightPurple;
    default:
      return Colors.white;
  }
}

//returns fill color based on student status
Color getStatusColorFill(String currStatus) {
  switch (currStatus) {
    case 'Doing well':
      return const Color(0xFFBBFABB);
    case 'Doing okay':
      return const Color(0xFFFAECBB);
    case 'Doing poorly':
      return const Color(0xFFFFB68F);
    case 'Needs help':
      return const Color(0xFFFABBBB);
    case 'No status':
      return const Color(0xFFD8D0DB);
    default:
      return Colors.white;
  }
}

//returns status based on student average score
String changeStatus(double avgScore) {
  if (avgScore >= 70) {
    return 'Doing well';
  } else if (avgScore >= 50) {
    return 'Doing okay';
  } else if(avgScore >= 20) {
    return 'Doing poorly';
  } else {
    return 'Needs help';
  }
}

class _TeacherClassScreenState extends State<TeacherClassScreen> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  List<Map<String, dynamic>> _originalStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _className = '';
  String _selectedSortOption = 'Low Score';

  @override
  void initState() {
    super.initState();
    _loadSortOption();
    _fetchStudents();
  }

  @override
  void didChangeDependencies() {
    if (widget.refresh) {
      _fetchStudents();
    }
    super.didChangeDependencies();
  }

  // Load sorting option from SharedPreferences
  Future<void> _loadSortOption() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSortOption = prefs.getString('sortOption') ?? 'Low Score';
    });
  }

  // Save sorting option to SharedPreferences
  Future<void> _saveSortOption(String option) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sortOption', option);
  }

  // Fetch students data from database
  Future<void> _fetchStudents() async {
    _className = await DatabaseHelper().getClassName(widget.classId) ?? '';
    var data = await DatabaseHelper().queryAllStudents(widget.classId);

    // Update student status based on average score
    if (data.isNotEmpty) {
      for (var i = 0; i < data.length; i++) {
        var x = await DatabaseHelper().queryAverageScore(data[i]['id']);
        if (x != null) {
          String stat = changeStatus(x);
          await DatabaseHelper().updateStudentStatus(data[i]['id'], stat);
        } else {
          String stat = "No status";
          await DatabaseHelper().updateStudentStatus(data[i]['id'], stat);
        }
      }
    }

    // Retrieve updated student data from database
    data = await DatabaseHelper().queryAllStudents(widget.classId);
    setState(() {
      _students = data;
      _originalStudents = List<Map<String, dynamic>>.from(_students);
      _filteredStudents = List<Map<String, dynamic>>.from(_students);
      _isLoading = false;
    });

    //apply saved sort option
    _sortStudents(_selectedSortOption);
  }

  //add new student to database
  void _addStudent(String studentName) async {
    await DatabaseHelper().insertStudent({
      'name': studentName,
      'class_id': widget.classId,
      'status': "No status"
    });
    _fetchStudents();
  }

  // Show dialog to add a new student
  void _showAddStudentDialog() {
    final TextEditingController studentNameController = TextEditingController();
    final FocusNode focusNode = FocusNode();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Student'),
          content: TextField(
            controller: studentNameController,
            focusNode: focusNode,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Student Name'),
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
                if (studentNameController.text.isNotEmpty) {
                  _addStudent(studentNameController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    ).then((_) {
      focusNode.dispose();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  //navigate to student info screen
  Future<void> _navigateToStudentInfoScreen(int studentId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentInfoScreen(studentId: studentId),
      ),
    ).then((_) {
      _fetchStudents();
    });

    if (result == true) {
      _fetchStudents();
    }
  }

  // Filter students based on search query and status
  void _filterStudents(String query) {
    setState(() {
      _filteredStudents = List<Map<String, dynamic>>.from(_students); // Start with a copy of _students

      if (_selectedStatus != 'All') {
        _filteredStudents = _filteredStudents.where((student) {
          return student['status'] == _selectedStatus;
        }).toList();
      }

      if (query.isNotEmpty) {
        _filteredStudents = _filteredStudents.where((student) {
          return student['name'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // Filter students by status
  void _filterByStatus(String status) {
    setState(() {
      _selectedStatus = status;
      _filterStudents(_searchController.text);
    });
  }

  // Show dialog to filter students by status
  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <String>[
              'All',
              'Doing well',
              'Doing okay',
              'Doing poorly',
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

  // Generate and print PDF report for the class
  Future<void> _generateAndPrintPdf() async {
    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students available to generate PDF.'),
        ),
      );
      return;
    }

    final pdfGenerator = PdfGenerator(context);
    double averageGrade = 0;
    final scores = _students
        .map<double?>((student) => student['average_score'])
        .where((score) => score != null && score is num) // Filter out null and non-numerical scores
        .cast<double>();
    if (scores.isNotEmpty) {
      averageGrade = scores.reduce((a, b) => a + b) / scores.length;
    }
    await pdfGenerator.generateClassReportPdf(_className, averageGrade, _students);
  }

  // Sort students based on selected criteria
  void _sortStudents(String criteria) {
    setState(() {

      _selectedSortOption = criteria;
      _saveSortOption(criteria);

      //sort by name
      if (criteria == 'Name') {
        _filteredStudents.sort((b, a) => a['name'].compareTo(b['name']));
      } else if (criteria == 'Low Score') {
        _filteredStudents.sort((b, a) {
          // Handle case where average_score is null or 'No status'
          if (a['average_score'] == null && b['average_score'] == null) {
            return 0;
          } else if (a['average_score'] == null || a['average_score'] == 'No status') {

            return -1; // a is considered lesser (null or 'No status' is considered lesser)
          } else if (b['average_score'] == null || b['average_score'] == 'No status') {
            return 1; // b is considered lesser (null or 'No status' is considered lesser)

          } else {
            // Sort by average_score ascending
            return a['average_score'].compareTo(b['average_score']);
          }
        });
      }

      //sort by score
      else if (criteria == 'High Score') {
        _filteredStudents.sort((a, b) {
          // Handle case where average_score is null or 'No status'
          if (a['average_score'] == null && b['average_score'] == null) {
            return 0;
          } else if (a['average_score'] == null || a['average_score'] == 'No status') {
            return -1; // a is considered lesser (null or 'No status' is considered lesser)
          } else if (b['average_score'] == null || b['average_score'] == 'No status') {
            return 1; // b is considered lesser (null or 'No status' is considered lesser)
          } else {
            // Sort by average_score ascending
            return a['average_score'].compareTo(b['average_score']);
          }
        });
      }
    });
  }

  //displays the dialog to choose the sort preferences
  void _showSortOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort by'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Name'),
                value: 'Name',
                groupValue: _selectedSortOption,
                onChanged: (String? value) {
                  if (value != null) {
                    _sortStudents(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Low Score'),
                value: 'Low Score',
                groupValue: _selectedSortOption,
                onChanged: (String? value) {
                  if (value != null) {
                    _sortStudents(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('High Score'),
                value: 'High Score',
                groupValue: _selectedSortOption,
                onChanged: (String? value) {
                  if (value != null) {
                    _sortStudents(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //displays tutorial dialog for the teacher class screen
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TeacherClassScreenTutorialDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentGradingProvider>(
        builder: (context, studentGradingProvider, child) {
      if (studentGradingProvider.update > 0) {
        _fetchStudents();
        studentGradingProvider.reset();
      }

      return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back), // Use the back arrow icon
                  onPressed: () {
                    Navigator.push(
                      context,
                      //zoom out animation between pages
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return TeacherDashboard();
                        },
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          // Define the zoom out animation
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
                const Text('Class Viewing'),
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
    child: Stack(
    children: [
    Column(
    children: [
    const SizedBox(height: 10),
    Container(
    margin: const EdgeInsets.all(10),
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
    offset: Offset(3, 3),
    ),
    ],
    ),
    child: Column(
    children: [
    const SizedBox(height: 10),
    Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
    children: [
    IconButton(
    icon: const Icon(
    Icons.filter_alt,
    color: White,
      size: 30,
    ),
    onPressed: _showStatusFilterDialog,
    ),
    const SizedBox(width: 8),
    Expanded(
    child: TextField(
    controller: _searchController,
    onChanged: _filterStudents,
    decoration: const InputDecoration(
    filled: true,
    fillColor: NotWhite,
    labelText: 'Search by student name',
    prefixIcon: Icon(Icons.search),
    border: OutlineInputBorder(),
    ),
    ),
    ),
    const SizedBox(width: 8),
      IconButton(
        icon: const Icon(
          Icons.settings,
          color: White,
          size: 30,
        ),
        onPressed: _showSortOptionsDialog,
      ),
    ],
    ),
    ),
    Container(
    height: 450,
    margin: const EdgeInsets.all(15),
    decoration: BoxDecoration(
    color: NotWhite,
    borderRadius: BorderRadius.circular(10),
    boxShadow: const [
    BoxShadow(
    color: Colors.black12,
    blurRadius: 10,
    offset: Offset(3, 3),
    ),
    ],
    ),
    child: _students.isNotEmpty
    ? ListView.builder(
    itemCount: _filteredStudents.length,
    itemBuilder: (context, index) {
      int reverseIndex = _filteredStudents.length - 1 - index;
    return Container(

    decoration: BoxDecoration(
    color: White,
    border: Border.all(
    color: DeepPurple, width: 1),
    borderRadius:
    BorderRadius.circular(8),
    ),
    margin: const EdgeInsets.all(10),
    child: ListTile(
    title: Row(
    children: [
    SizedBox(
    width: 85,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //displays student names, status, and scores
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: getStatusColor(
                    _filteredStudents[reverseIndex]
                    ['status']),
                width: 2),
            color:
            getStatusColorFill(
                _filteredStudents[reverseIndex]
                ['status']),
          ),
          child: Center(
            child: Text(
              '${_filteredStudents[reverseIndex]['average_score']
                  ?.round() ?? ''}',
              style: const TextStyle(
                color: DeepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        FittedBox(
          child: Text(
              _filteredStudents[reverseIndex]['status'] ?? 'No status',
              textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
    ),
      const SizedBox(width: 40),
      Expanded(
        child: Text(
          '${_filteredStudents[reverseIndex]['name']}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 30,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
    ),
      onTap: () {
        _navigateToStudentInfoScreen(
            _filteredStudents[reverseIndex]['id']);
      },
    ),
    );
    },
    )
        : const Center(
      child: Text(
        'No students available. \nPlease add!',
        style: TextStyle(fontSize: 30),
      ),
    ),
    ),
      const SizedBox(height: 10),
    ],
    ),
    ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _showAddStudentDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: White,
              foregroundColor: DeepPurple,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              side: const BorderSide(width: 1, color: DeepPurple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Add Student +',
              style: TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: _generateAndPrintPdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: White,
              foregroundColor: DeepPurple,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              side: const BorderSide(width: 1, color: DeepPurple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Class Report',
              style: TextStyle(fontSize: 22),
            ),
          ),
        ],
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

