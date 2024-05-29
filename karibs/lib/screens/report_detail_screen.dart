import 'package:flutter/material.dart';
import 'student_info_screen.dart';
import 'package:fl_chart/fl_chart.dart';


class BarGraph extends StatelessWidget {
  final double score;

  BarGraph({required this.score});

  @override
  Widget build(BuildContext context) {
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
              getTitles: (value) {
                return '';
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
          ],
        ),
      ),
    );
  }
}


class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> report;

  ReportDetailScreen({required this.report});

  @override
  Widget build(BuildContext context) {
    double score = report['score']?.toDouble() ?? 0;
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
                report['title'],
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: getReportColor(report['score']), // You can change the color as needed
                ),
                padding: EdgeInsets.all(20),
                child: Text(
                  '${report['score']}',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarGraph(score: score),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Notes: ${report['notes']}',
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
