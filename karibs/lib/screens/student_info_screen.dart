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

  Future<void> _fetchStudentData() async {
    final student = await DatabaseHelper().queryStudent(widget.studentId);
    final reports = await DatabaseHelper().queryAllReports(widget.studentId);
    final averageScore = await DatabaseHelper().queryAverageScore(widget.studentId);
    if (averageScore != null) {
      String newStatus = changeStatus(averageScore);
      final status = await DatabaseHelper().updateStudentStatus(widget.studentId, newStatus);
    }
    final mutableReports = List<Map<String, dynamic>>.from(reports);
    mutableReports.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
    setState(() {
      _student = student;
      _reports = mutableReports;
      _averageScore = averageScore;
      _isLoading = false;
    });
  }

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

  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StudentInfoScreenTutorialDialog();
      },
    );
  }


  List<FlSpot> _prepareDataForChart() {
    List<FlSpot> spots = [];
    for (var report in _reports) {
      int id = report['id'];
      if(report['score'] != null){
        double score = report['score'];
        spots.add(FlSpot(id.toDouble(), score));
      }
      //double score = report['score'] != null ? report['score'].toDouble(): 0.0;

    }
    return spots;
  }

  double _getMinX() {
    if (_reports.isEmpty) {
      return 0.0;
    }
    //int min = _reports.first['id'];
    int min = _reports.map((report) => report['id']).reduce((a, b) => a < b ? a : b);
    return min.toDouble();
  }

  double _getMaxX() {
    if (_reports.isEmpty) {
      return 0.0;
    }
    //int max = _reports.last['id'];
    int max = _reports.map((report) => report['id']).reduce((a, b) => a >= b ? a : b);
    return max.toDouble();
  }

  String _formatDate(double value) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return '${date.day}/${date.month}';
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
            // Navigate back to TeacherClassScreen using popUntil
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherClassScreen(classId: _student?['class_id'], refresh: true),
              ),
            );
          },
        ),
        automaticallyImplyLeading: false,

      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          :Column(
        children: [
          //SizedBox(height: 10,),
          Row(
            children: [
              const SizedBox(width: 20,),
              if(_student !=null)
                Expanded(child:
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _student!['name'],
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ),
                ),
              ElevatedButton(
                onPressed: _navigateToEditStudentScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: White,
                  foregroundColor: DeepPurple,
                  side: const BorderSide(width: 1, color: DeepPurple),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Edit', style: TextStyle(fontSize: 16),),
              ),
              const SizedBox(width: 20,),
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

                        //borderRadius: BorderRadius.circular(30), // Rounded corners for all
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(3, 3), // Shadow position
                          ),
                        ],
                      ),
                      child:const Text('No reports available. \nPlease add!', style: TextStyle(fontSize: 30, color: White),),
                    ),

                    const SizedBox(height: 20),

                  ],
                ),
              )
                  : LineChart(
                LineChartData(
                  minX: _getMinX(),
                  maxX: _getMaxX(),
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(show: _reports.isNotEmpty),
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) {
                        value-=1;
                        int index = value.toInt();
                        if(value >=0 && value< _reports.length){
                          return _reports[index]['title'] ?? '';
                        }
                        return '';
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
                    child: Text('Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                  ),
                  ElevatedButton(
                    onPressed: _navigateToAddReportScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: White,
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
                      backgroundColor: White,
                      foregroundColor: DeepPurple,
                      side: const BorderSide(width: 1, color: DeepPurple),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('PDF', style: TextStyle(fontSize: 20)),
                  ),
                ]

            ),
          ),
          Expanded(
            child:Padding(
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
                          ).then((_){
                            _fetchStudentData();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: (_reports[index]['score'] != null)
                                ? getReportColor(_reports[index]['score']).withOpacity(0.7)
                                : NotWhite,
                            borderRadius: BorderRadius.circular(8), // Rounded corners for the box
                          ),
                          margin: const EdgeInsets.only(bottom: 8), // Margin between boxes
                          child: ListTile(
                            title: Text(_reports[index]['title'],
                              style: const TextStyle(fontSize: 24),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                            ),
                            subtitle: Text(_reports[index]['notes'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(_reports[index]['score']?.toStringAsFixed(2) ?? '', style: const TextStyle(fontSize: 30),),
                          ),
                        ));
                  },
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }
}
