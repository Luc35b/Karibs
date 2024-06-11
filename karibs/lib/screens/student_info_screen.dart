import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:karibs/main.dart';
import 'package:karibs/pdf_gen.dart'; // Import your PdfGenerator class
import 'package:karibs/screens/edit_student_screen.dart';
import 'add_report_screen.dart';
import 'teacher_class_screen.dart';
import 'report_detail_screen.dart';

class StudentInfoScreen extends StatefulWidget {
  final int studentId;

  StudentInfoScreen({required this.studentId});

  @override
  _StudentInfoScreenState createState() => _StudentInfoScreenState();
}

Color getReportColor(double currScore) {
  if (currScore >= 70) {
    return Colors.green;
  } else if (currScore >= 50) {
    return Color(0xFFe6cc00);
  } else {
    return Colors.red;
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

  Future<void> _generatePdf() async {
    if (_student != null) {
      await PdfGenerator().generateStudentReportPdf(_student!, _reports);
    }
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
    int min = _reports.map((report) => report['id']).reduce((a, b) => a < b ? a : b);
    return min.toDouble();
  }

  double _getMaxX() {
    if (_reports.isEmpty) {
      return 0.0;
    }
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
        title: Text('Student Info'),
        backgroundColor: DeepPurple,
        foregroundColor: White,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          :Column(
          children: [
            //SizedBox(height: 10,),
            Row(
              children: [
                SizedBox(width: 20,),
                if(_student !=null)
                  Expanded(child:
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      _student!['name'],
                      style: TextStyle(
                          fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ),
                ElevatedButton(
                  onPressed: _navigateToEditStudentScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: White,
                    foregroundColor: DeepPurple,
                    side: BorderSide(width: 1, color: DeepPurple),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Edit Student', style: TextStyle(fontSize: 16),),
                ),
                SizedBox(width: 20,),
              ],
            ),
            if (_averageScore != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Average Score: ${_averageScore!.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            SizedBox(
              height: 300, // Provide a fixed height for the chart
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _reports.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 35.0, horizontal: 35), // Padding inside the container
                        decoration: BoxDecoration(
                          color: DeepPurple,
                          border: Border.all(width: 2, color: DeepPurple),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(30),
                          ),

                          //borderRadius: BorderRadius.circular(30), // Rounded corners for all
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(3, 3), // Shadow position
                            ),
                          ],
                        ),
                        child:Text('No reports available. \nPlease add!', style: TextStyle(fontSize: 30, color: White),),
                      ),

                      SizedBox(height: 20),

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
                        colors: [Color(0xFF245209)],
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
                    Expanded(
                      child: Text('Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                    ),
                    ElevatedButton(
                      onPressed: _navigateToAddReportScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: White,
                        foregroundColor: DeepPurple,
                        side: BorderSide(width: 1, color: DeepPurple),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text('Add Report', style: TextStyle(fontSize: 20)),
                    ),
                  ]

              ),
            ),
            Expanded(
              child:Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Shaded background color
                    border: Border.all(color: DeepPurple, width: 1),
                    borderRadius: BorderRadius.circular(10), // Rounded corners for the box
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // Shadow position
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
                          margin: EdgeInsets.only(bottom: 8), // Margin between boxes
                          child: ListTile(
                            title: Text(_reports[index]['title'], style: TextStyle(fontSize: 24)),
                            subtitle: Text(_reports[index]['notes']),
                            trailing: Text(_reports[index]['score']?.toString() ?? '', style: TextStyle(fontSize: 30),),
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
