import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:karibs/database/database_helper.dart';

class StudentInfoScreen extends StatefulWidget {
  final int studentId;

  StudentInfoScreen({required this.studentId});

  @override
  _StudentInfoScreenState createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  Map<String, dynamic>? _student;
  List<Map<String, dynamic>> _reports = [];
  double? _averageScore;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    final student = await DatabaseHelper().queryStudent(widget.studentId);
    final reports = await DatabaseHelper().queryAllReports(widget.studentId);
    final averageScore = await DatabaseHelper().queryAverageScore(widget.studentId);

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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Notes'),
              ),
              TextField(
                controller: scoreController,
                decoration: InputDecoration(labelText: 'Score (optional)'),
                keyboardType: TextInputType.number,
              ),
            ],
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
                if (titleController.text.isNotEmpty && notesController.text.isNotEmpty) {
                  _addReport(
                    titleController.text,
                    notesController.text,
                    scoreController.text.isNotEmpty ? int.parse(scoreController.text) : null,
                  );
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

  List<FlSpot> _prepareDataForChart() {
    List<FlSpot> spots = [];
    for (var report in _reports) {
      DateTime date = DateTime.parse(report['date']);
      double score = report['score'] != null ? report['score'].toDouble() : 0.0;
      spots.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), score));
    }
    return spots;
  }

  double _getMinX() {
    return _reports.isEmpty
        ? 0
        : DateTime.parse(_reports.first['date']).millisecondsSinceEpoch.toDouble();
  }

  double _getMaxX() {
    return _reports.isEmpty
        ? 0
        : DateTime.parse(_reports.last['date']).millisecondsSinceEpoch.toDouble();
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
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
                    Text('No reports available. Please add!'),
                    SizedBox(height: 20),
                    FloatingActionButton(
                      onPressed: _showAddReportDialog,
                      child: Icon(Icons.add),
                    ),
                  ],
                ),
              )
                  : LineChart(
                LineChartData(
                  minX: _getMinX(),
                  maxX: _getMaxX(),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) => _formatDate(value),
                    ),
                    leftTitles: SideTitles(showTitles: true),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _prepareDataForChart(),
                      isCurved: true,
                      colors: [Colors.blue],
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [Colors.lightBlue.withOpacity(0.4)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_reports[index]['title']),
                  subtitle: Text(_reports[index]['notes']),
                  trailing: Text(_reports[index]['score']?.toString() ?? ''),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReportDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
