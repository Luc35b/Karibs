import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:karibs/database/database_helper.dart';
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

Color getReportColor(double currScore){
  if(currScore >= 70){
    return Colors.green;
  }
  else if(currScore >=50){
    return Color(0xFFe6cc00);
  }
  else{
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
        // Refresh the screen or perform any other action after adding a report
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
        // Refresh the screen or perform any other action after adding a report
        _fetchStudentData();
      }
    });
  }


  Future<void> _fetchStudentData() async {
    final student = await DatabaseHelper().queryStudent(widget.studentId);
    final reports = await DatabaseHelper().queryAllReports(widget.studentId);
    final averageScore = await DatabaseHelper().queryAverageScore(widget.studentId);
    if(averageScore != null){
      String newStatus = changeStatus(averageScore);
      final status = await DatabaseHelper().updateStudentStatus(widget.studentId, newStatus);
    }
    // Convert the read-only list to a mutable list before sorting
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


  void _showAddReportDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController scoreController = TextEditingController();
   }

  List<FlSpot> _prepareDataForChart() {
    List<FlSpot> spots = [];
    for (var report in _reports) {
      int id = report['id'];
      double score = report['score'] != null ? report['score'].toDouble(): 0.0;
      spots.add(FlSpot(id.toDouble(), score));
    }
    return spots;
  }

  double _getMinX() {
    if(_reports.isEmpty){
      return 0.0;
    }
    int min = _reports.map((report) => report['id']).reduce((a, b) => a < b ? a : b);
    return min.toDouble();
  }

  double _getMaxX() {
    if(_reports.isEmpty){
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
        title: Text(_student != null ? _student!['name'] : 'Student Info'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(true);
          }
        )
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
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
                            fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ElevatedButton(
                onPressed: _navigateToEditStudentScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
                    Text('No reports available. \nPlease add!', style: TextStyle(fontSize: 30),),
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
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text('Add Report'),
                ),
              ]

            ),
          ),
          Expanded(
            child:Padding(
              padding: const EdgeInsets.all(8),
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
                          report: _reports[index],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: getReportColor(_reports[index]['score']).withOpacity(0.7), // Background color of the box
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
        ],
      ),
    );
  }
}