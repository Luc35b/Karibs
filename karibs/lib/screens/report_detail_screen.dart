import 'package:flutter/material.dart';
import 'student_info_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'add_report_screen.dart';
import 'student_info_screen.dart';
import 'package:karibs/database/database_helper.dart';
import 'edit_report_screen.dart';



class BarGraph extends StatelessWidget {
  final double score;
  final double? vocab_score;
  final double? comprehension_score;

  BarGraph({required this.score, this.vocab_score, this.comprehension_score});


  @override
  Widget build(BuildContext context) {
    print('Score: $score');
    print('Comprehension Score: $comprehension_score');
    print('Vocabulary Score: $vocab_score');

    return Container(
      width: 400,
      height: 350,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: true,
              //textStyle: TextStyle(color: Colors.black, fontSize: 14),
              margin: 10,
              reservedSize: 14,
              interval: 20,
              getTitles: (value) {
                return value.toInt().toString();
              },
            ),
            bottomTitles: SideTitles(
              showTitles: true,
              //style: TextStyle(color: Colors.black, fontSize: 14),
              margin: 10,
              reservedSize: 14,
              interval: 1, // Set the interval to 1 to show titles for each bar
              getTitles: (double value) {
                switch (value.toInt()) {
                  case 0:
                    return 'Score';
                  case 1:
                    return 'Vocabulary';
                  case 2:
                    return 'Comprehension';
                  default:
                    return ''; // Empty string for other bars
                }
              },
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey),
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  y: score,
                  colors: [Colors.blueGrey],
                  width: 16,
                ),
              ],
            ),
            if(vocab_score != null)
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  y: vocab_score!,
                  colors: [Colors.blueGrey],
                  width: 16,
                ),
              ],
            ),
            if(comprehension_score != null)
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  y: comprehension_score!,
                  colors: [Colors.blueGrey],
                  width: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class ReportDetailScreen extends StatefulWidget{
  final int reportId;

  ReportDetailScreen({required this.reportId});

  @override
  _ReportDetailScreenState createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  Map<String,dynamic> reportInfo = {};
  String reportTitle = " ";
  String reportNotes = " ";
  double reportScore = 0.0;


  @override
  void initState() {
    super.initState();
    queryReportInformation();
  }

  @override
  void didChangeDependencies() {
    queryReportInformation();
    super.didChangeDependencies();
  }

  Future<void> queryReportInformation() async {
    var x = await DatabaseHelper().queryReport(widget.reportId);
    setState(() {
      reportInfo = x!;
      reportTitle = x['title'];
      reportNotes = x['notes'];
      reportScore = x['score'];
    });
  }

  void _navigateToEditReportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReportScreen(reportId:widget.reportId),
      ),
    ).then((_) {
      print("updating report info");
      queryReportInformation();
    });
  }

  @override
  _ReportDetailScreenState createState() => _ReportDetailScreenState();


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details'),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(

                reportTitle,
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the edit report screen when the button is pressed

                _navigateToEditReportScreen();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Edit Report', style: TextStyle(fontSize: 16),),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: getReportColor(reportScore), // You can change the color as needed
                ),
                padding: EdgeInsets.all(20),
                child: Text(
                  '${reportScore}',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),

              child: BarGraph(score: reportScore),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(

                  'Notes: ${reportNotes}',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
