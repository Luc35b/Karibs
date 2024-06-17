import 'package:flutter/material.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/providers/student_grading_provider.dart';
import 'package:provider/provider.dart';
import '../pdf_gen.dart';
import 'student_info_screen.dart';
import 'teacher_dashboard.dart';


class TeacherClassScreen extends StatefulWidget {
  final int classId;
  final bool refresh;

  const TeacherClassScreen({super.key, required this.classId, required this.refresh});

  @override
  _TeacherClassScreenState createState() => _TeacherClassScreenState();
}

Color getStatusColor(String currStatus) {
  switch (currStatus) {
    case 'Doing well':
      return Colors.green;
    case 'Doing okay':
      return const Color(0xFFe6cc00);
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
      return const Color(0xFFBBFABB);
    case 'Doing okay':
      return const Color(0xFFFAECBB);
    case 'Needs help':
      return const Color(0xFFFABBBB);
    case 'No status':
      return const Color(0xFFD8D0DB);
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
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _className = '';

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
    _className = await DatabaseHelper().getClassName(widget.classId) ?? '';
    var data = await DatabaseHelper().queryAllStudents(widget.classId);
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

    data = await DatabaseHelper().queryAllStudents(widget.classId);
    setState(() {
      _students = data;
      _filteredStudents = List.from(data);
      _isLoading = false;
    });
  }

  void _addStudent(String studentName) async {
    await DatabaseHelper().insertStudent({
      'name': studentName,
      'class_id': widget.classId,
      'status': "No status"
    });
    _fetchStudents();
  }

  void _showAddStudentDialog() {
    final TextEditingController studentNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Student'),
          content: TextField(
            controller: studentNameController,
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
          title: const Text('Filter by Status'),
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

  Future<void> _generateAndPrintPdf() async {
    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students available to generate PDF.'),
        ),
      );
      return;
    }

    final pdfGenerator = PdfGenerator();
    double averageGrade = 0;
    if (_students.isNotEmpty) {
      averageGrade = _students
          .map((student) => student['average_score'])
          .reduce((a, b) => a + b) /
          _students.length;
    }
    await pdfGenerator.generateClassReportPdf(_className, averageGrade, _students);
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
          title: const Text('Teacher Class Screen'),
          backgroundColor: DeepPurple,
          foregroundColor: White,
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
    Icons.filter_list,
    color: White,
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
    children: [
    Row(
    children: [
    const SizedBox(width: 15),
      Container(
        width: 45,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: getStatusColor(
                  _filteredStudents[index]
                  ['status']),
              width: 2),
          color:
          getStatusColorFill(
              _filteredStudents[index]
              ['status']),
        ),
        child: Center(
          child: Text(
            '${_filteredStudents[index]['average_score']
                ?.round() ?? ''}',
            style: const TextStyle(
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
      const SizedBox(width: 25),
      Text(
        '${_filteredStudents[index]['name']}',
        style: const TextStyle(
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

