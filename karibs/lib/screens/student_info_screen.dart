import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/main.dart';
import 'package:karibs/pdf_gen.dart'; // Import your PdfGenerator class
import 'package:karibs/screens/edit_student_screen.dart';
import 'add_report_screen.dart';
import 'teacher_class_screen.dart';
import 'report_detail_screen.dart';
import 'package:karibs/overlay.dart';

class StudentInfoScreen extends StatefulWidget {
  final int studentId;
  //static const routeName = '/student_info';

  const StudentInfoScreen({super.key, required this.studentId});

  @override
  _StudentInfoScreenState createState() => _StudentInfoScreenState();
}

///returns color based on student score
Color getReportColor(double currScore) {
  if (currScore >= 70) {
    return const Color(0xFFBBFABB);
  } else if (currScore >= 50) {
    return const Color(0xFFe6cc00);
  } else if (currScore >=20) {
    return const Color(0xFFFFB68F);
  }else {
    return const Color(0xFFFA6478);
  }
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  Map<String, dynamic>? _student;
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  double? _averageScore = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  ///navigates to add report screen
  void _navigateToAddReportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReportScreen(studentId: widget.studentId),
      ),
    ).then((result) {
      if (result != null && result == true) {
        _fetchStudentData();
      }
    });
  }

  ///navigates to edit student screen
  void _navigateToEditStudentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentScreen(studentId: widget.studentId),
      ),
    ).then((result) {
      if (result != null && result == true) {
        _fetchStudentData();
      }
    });
  }

  ///fetches the student information from the database
  Future<void> _fetchStudentData() async {
    final student = await DatabaseHelper().queryStudent(widget.studentId);
    final reports = await DatabaseHelper().queryAllReports(widget.studentId);
    final averageScore = await DatabaseHelper().queryAverageScore(widget.studentId);
    if (averageScore != null) {
      String newStatus = changeStatus(averageScore);
      final status = await DatabaseHelper().updateStudentStatus(widget.studentId, newStatus);
    }
    //sort reports by date
    final mutableReports = List<Map<String, dynamic>>.from(reports);
    mutableReports.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
    setState(() {
      _student = student;
      _reports = mutableReports;
      _averageScore = averageScore;
      _isLoading = false;
    });
  }

  ///adds report to database
  void _addReport(String title, String notes, int? score) async {
    await DatabaseHelper().insertReport({
      'date': DateTime.now().toIso8601String(),
      'title': title,
      'notes': notes,
      'score': score,
      'student_id': widget.studentId,
    });
    _fetchStudentData();
  }

  ///generates pdf of all reports under a student
  void _generatePdfAllReports() async {
    if (_student != null && _reports.isNotEmpty) {
      await PdfGenerator(context).generateStudentReportPdf(_student!, _reports);
    } else {
      // Show a snackbar or dialog indicating no reports available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Reports. Add a Report!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  ///lets users select an individual report to be saved
  void _selectIndividualReport() {
    if(_reports.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Report'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _reports.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(_reports[index]['title']),
                    onTap: () {
                      Navigator.pop(context);
                      _generatePdfIndividualReport(_reports[index]);
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Reports. Add a Report!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  ///generates a pdf of the selected individual report
  void _generatePdfIndividualReport(Map<String, dynamic> report) async {
    if (_student != null && report.isNotEmpty) {
      await PdfGenerator(context).generateIndividualReportPdf(_student!, report);
    } else {
      // Show a snackbar or dialog indicating report not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Reports. Add a Report!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  ///displays tutorial dialog for the student info screen
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StudentInfoScreenTutorialDialog();
      },
    );
  }

  ///adds report data to the graph
  List<FlSpot> _prepareDataForChart() {
    List<FlSpot> spots = [];
    for (int i = 0; i < _reports.length; i++) {
      var report = _reports[i];
      if (report['score'] != null) {
        double score = report['score'];
        spots.add(FlSpot(i.toDouble(), score)); // Use the index as the X value
      }
    }
    return spots;
  }

  ///returns the report title to be displayed on the x-axis of the graph
  String _getReportTitle(int index) {
    if (index >= 0 && index < _reports.length) {
      return _reports[index]['title'] ?? '';
    }
    return '';
  }

  ///returns the maximum x-value
  double _getMaxX() {
    if (_reports.isEmpty) {
      return 0.0;
    }
    return (_reports.length - 1).toDouble(); // Maximum X is the last index
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Student Info'),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to TeacherClassScreen with a custom zoom-out transition
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return TeacherClassScreen(classId: _student?['class_id'], refresh: true);
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
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          :SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 20),
                if (_student != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        _student!['name'],
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _navigateToEditStudentScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: DeepPurple,
                    side: const BorderSide(width: 1, color: DeepPurple),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Edit', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 20),
              ],
            ),
            if (_averageScore != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Average Score: ${_averageScore!.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            SizedBox(
              height: 300, // Provide a fixed height for the chart
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0, top: 8.0, left: 8.0, bottom: 8.0),
                child: _reports.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 35), // Padding inside the container
                        decoration: BoxDecoration(
                          color: DeepPurple,
                          border: Border.all(width: 2, color: DeepPurple),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(30),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(3, 3), // Shadow position
                            ),
                          ],
                        ),
                        child: const Text(
                          'No reports available. \nPlease add!',
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
                    : LineChart(
                  LineChartData(
                    minX: 0.0,
                    maxX: _getMaxX(),
                    minY: 0,
                    maxY: 100,
                    gridData: FlGridData(show: _reports.isNotEmpty),
                    titlesData: FlTitlesData(
                      bottomTitles: SideTitles(
                        showTitles: true,
                        getTitles: (value) {
                          return _getReportTitle(value.toInt());
                        },
                        reservedSize: 22,
                        margin: 10,
                      ),
                      leftTitles: SideTitles(showTitles: true),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _prepareDataForChart(),
                        isCurved: false,
                        colors: [const Color(0xFF245209)],
                        barWidth: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: _navigateToAddReportScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: DeepPurple,
                      side: const BorderSide(width: 1, color: DeepPurple),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Add Report', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Generate PDF'),
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListTile(
                                    title: const Text('All Reports'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _generatePdfAllReports();
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('Individual Report'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _selectIndividualReport();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: DeepPurple,
                      side: const BorderSide(width: 1, color: DeepPurple),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('PDF', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Shaded background color
                  borderRadius: BorderRadius.circular(10), // Rounded corners for the box
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // Shadow position
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to another screen when a report is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetailScreen(
                              reportId: _reports[index]['id'],
                            ),
                          ),
                        ).then((_) {
                          _fetchStudentData();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: (_reports[index]['score'] != null)
                              ? getReportColor(_reports[index]['score']).withOpacity(0.7)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8), // Rounded corners for the box
                        ),
                        margin: const EdgeInsets.only(bottom: 8), // Margin between boxes
                        child: ListTile(
                          title: Text(
                            _reports[index]['title'],
                            style: const TextStyle(fontSize: 24),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            _reports[index]['notes'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            _reports[index]['score']?.toStringAsFixed(2) ?? '',
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
