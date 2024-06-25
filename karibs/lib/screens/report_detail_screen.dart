import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karibs/screens/view_test_grade_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:karibs/database/database_helper.dart';
import 'edit_report_screen.dart';
import 'package:karibs/main.dart';
import 'package:karibs/overlay.dart';


class BarGraph extends StatelessWidget {
  final double score;
  final Map<String, dynamic> categoryScores;

  const BarGraph({super.key, required this.score, required this.categoryScores});

  Color getScoreColor(double currScore) {
    if (currScore >= 70) {
      return const Color(0xFFBBFABB);
    } else if (currScore >= 50) {
      return const Color(0xFFe6cc00);
    } else if (currScore >= 20) {
      return const Color(0xFFFFB68F);
    } else {
      return const Color(0xFFFA6478);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            y: score,
            colors: [getScoreColor(score)],
            width: 80,
            borderRadius: BorderRadius.zero,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              y: 100,
              colors: [Colors.grey[200]!],
            ),
          ),
        ],
        barsSpace: 20,
      ),
    ];

    int xValue = 1;
    categoryScores.forEach((category, categoryScore) {
        barGroups.add(
          BarChartGroupData(
            x: xValue,
            barRods: [
              BarChartRodData(
                y: categoryScore,
                colors: [getScoreColor(categoryScore)],
                width: 80,
                borderRadius: BorderRadius.zero,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  y: 100,
                  colors: [Colors.grey[200]!],
                ),
              ),
            ],
            barsSpace: 20,
          ),
        );
        xValue++;
    });

    return SizedBox(
      width: 400,
      height: 350,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: true,
              margin: 10,
              reservedSize: 14,
              interval: 20,
              getTitles: (value) {
                return value.toInt().toString();
              },
            ),
            bottomTitles: SideTitles(
              showTitles: true,
              margin: 10,
              reservedSize: 14,
              getTitles: (double value) {
                if (value.toInt() == 0) {
                  return 'Total';
                } else if (value.toInt() <= categoryScores.keys.length) {
                  return categoryScores.keys.elementAt(value.toInt()-1);
                } else {
                  return '';
                }
              },
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey),
          ),
          barGroups: barGroups,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String category;
                if (group.x.toInt() == 0) {
                  category = 'Total';
                } else if (group.x.toInt() <= categoryScores.length) {
                  category = categoryScores.keys.elementAt(group.x.toInt() - 1);
                } else {
                  category = '';
                }
                return BarTooltipItem(
                  '$category\n', //category + '\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: rod.y.toString(),
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ReportDetailScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  _ReportDetailScreenState createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  Map<String, dynamic> reportInfo = {};
  String reportTitle = " ";
  String reportNotes = " ";
  double reportScore = 0.0;
  Map<String, dynamic> categoryScores = {};

  @override
  void initState() {
    super.initState();
    queryReportInformation();
  }

  Future<void> queryReportInformation() async {
    var report = await DatabaseHelper().queryReport(widget.reportId);
    int? studentTestId = await DatabaseHelper().getStudentTestIdFromReport(widget.reportId);
    Map<String, double> catsNoNull = {};
    if(studentTestId != null) {
      Map<String, double?> categories = await DatabaseHelper()
          .getCategoryScoresbyStudentTestId(studentTestId);
        categories.forEach((key, val) {
        if (val != null) {
          catsNoNull[key] = val;
        }
      });
    }
    setState(() {
      reportInfo = report ?? {};
      reportTitle = report?['title'] ?? '';
      reportNotes = report?['notes'] ?? '';
      reportScore = report?['score']?.toDouble() ?? 0.0;
      categoryScores = catsNoNull;
    });


  }


  void _navigateToEditReportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReportScreen(reportId: widget.reportId),
      ),
    ).then((_) {
      queryReportInformation();
    });
  }

  void _navigateToViewTestGrades() {
    if (categoryScores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Associated Test.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
    else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewTestGradeScreen(reportId: widget.reportId),
        ),
      ).then((_) {
        queryReportInformation();
      });
    }
  }

  Color getStatusColorFill(double currStatus) {
    if (currStatus >= 70) {
      return const Color(0xFFBBFABB);
    } else if (currStatus >= 50) {
      return const Color(0xFFFAECBB);
    } else if (currStatus >= 20) {
      return const Color(0xFFFFB68F);
    } else if (currStatus >= 0.01) {
      return const Color(0xFFFABBBB);
    } else {
      return const Color(0xFFD8D0DB);
    }
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReportDetailsScreenTutorialDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back), // Back arrow icon
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            const Text('Report Details'),
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                // Show tutorial dialog
                _showTutorialDialog();
              },
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: _navigateToEditReportScreen,
            style: TextButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text('EDIT', style: GoogleFonts.raleway(color: White, fontWeight: FontWeight.bold)),
          ),
        ],
        backgroundColor: DeepPurple,
        foregroundColor: White,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reportTitle,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                'Notes: $reportNotes',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: getStatusColorFill(reportScore), // Adjust the color based on the score
                    border: Border.all(color: getReportColor(reportScore), width: 2),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    reportScore.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 24, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              BarGraph(
                score: reportScore,
                categoryScores: categoryScores, // Exclude null scores
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: _navigateToViewTestGrades,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: DeepPurple,
                    side: const BorderSide(
                        width: 2, color: DeepPurple),
                  ),
                  child: const Text(
                    'View Test Grade',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getReportColor(double score) {
    if (score >= 70) {
      return Colors.green;
    } else if (score >= 50) {
      return Colors.yellow;
    } else if (score >= 20) {
      return Colors.orange;
    } else if (score >= 0.01) {
      return Colors.red;
    } else {
      return Colors.blueGrey;
    }
  }
}

