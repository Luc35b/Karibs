import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:karibs/database/database_helper.dart';
import 'add_report_screen.dart';
import 'teacher_class_screen.dart';
import 'package:karibs/main.dart';
import 'package:karibs/overlay.dart';

//returns report color based on score
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

class EditStudentScreen extends StatefulWidget {
  final int studentId;

  const EditStudentScreen({super.key, required this.studentId});

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  Map<String, dynamic>? _student;
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  double? _averageScore = 0.0;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  @override
  void dispose(){
    _nameController.dispose();
    super.dispose();
  }

  //goes to add report screen then automatically fetches the data on return
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

  // Fetches student data from the database
  Future<void> _fetchStudentData() async {
    final student = await DatabaseHelper().queryStudent(widget.studentId);
    final reports = await DatabaseHelper().queryAllReports(widget.studentId);
    final averageScore = await DatabaseHelper().queryAverageScore(widget.studentId);

    // Update student status based on average score
    if(averageScore != null){
      String newStatus = changeStatus(averageScore);
      final status = await DatabaseHelper().updateStudentStatus(widget.studentId, newStatus);
    }

    // Convert the read-only list to a mutable list before sorting
    final mutableReports = List<Map<String, dynamic>>.from(reports);
    mutableReports.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));

    // Update state with fetched data
    setState(() {
      _student = student;
      _reports = mutableReports;
      _averageScore = averageScore;
      _nameController.text = _student!['name'];
      _isLoading = false;
    });
  }

// Prepares data for chart plotting
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

  //returns the report title to be displayed on graph
  String _getReportTitle(int index) {
    if (index >= 0 && index < _reports.length) {
      return _reports[index]['title'] ?? '';
    }
    return '';
  }

  //gets the end x value from the graph
  double _getMaxX() {
    if (_reports.isEmpty) {
      return 0.0;
    }
    return (_reports.length - 1).toDouble(); // Maximum X is the last index
  }

  // Shows tutorial dialog for the Edit Student Screen
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditStudentScreenTutorialDialog();
      },
    );
  }

  // Updates student name in the database
  void _updateStudentName(String newName) async{
    await DatabaseHelper().updateStudentName(widget.studentId, newName);
    _fetchStudentData();

  }

  // Shows delete confirmation dialog for reports
  void _showDeleteConfirmationDialog(int reportId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Report'),
          content: const Text('Are you sure you want to delete this report?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: () {
                _deleteReport(reportId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  // Deletes the student from the database
  void _deleteStudent() async {
    // Show a confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('Cancel', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: const Text('Delete', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
    // Delete the student if confirmed
    if (confirmDelete == true) {
      await DatabaseHelper().deleteStudent(widget.studentId);
      Navigator.pop(context, true);
      Navigator.pop(context, true);// Navigate back to the previous screen
    }
  }

  // Deletes a specific report from the database
  void _deleteReport(int reportId) async{
    await DatabaseHelper().deleteReport(reportId);
    _fetchStudentData(); //refresh screen after delete
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child:Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back), // Back arrow icon
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              const Text('Edit Student'),
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

            IconButton(onPressed: _deleteStudent, icon: const Icon(Icons.delete)),
          ],
          backgroundColor: DeepPurple,
          foregroundColor: White,
          automaticallyImplyLeading: false,
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 15),
          if(_student != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Student Name',
                        border: OutlineInputBorder(),
                      ),
                      onEditingComplete: () {
                        // Save the updated name when editing is complete
                        //_updateStudentName(_nameController.text);
                        // Dismiss the keyboard
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      // Save the updated name when the user clicks the save button.
                      _updateStudentName(_nameController.text);
                      // Dismiss the keyboard
                      FocusScope.of(context).unfocus();
                      // Optionally navigate back or show a confirmation message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Student name saved')),
                      );
                    },
                      style: TextButton.styleFrom(
                        backgroundColor: White,
                        side: const BorderSide(color: DeepPurple, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'SAVE',
                        style: TextStyle(color: DeepPurple, fontWeight: FontWeight.bold),
                      ),
                  ),
                ],

              ),
            ),
          if (_averageScore != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Average Score: ${_averageScore!.toStringAsFixed(2)}', //displays the average score
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          SizedBox(
            height: 300, // Provide a fixed height for the chart
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _reports.isEmpty
                  ? Center(
                child: Column(
                  //no reports available dialog
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

              //displays graph on center of the screen
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
                ]

            ),
          ),

          //displays reports section
          Expanded(
            child:Padding(
              padding: const EdgeInsets.all(8),
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
                      offset: const Offset(0, 3), // Shadow position
                    ),
                  ],
              ),
              child: ListView.builder(
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: getReportColor(_reports[index]['score']).withOpacity(0.5), // Background color of the box
                      borderRadius: BorderRadius.circular(8), // Rounded corners for the box
                    ),
                    margin: const EdgeInsets.only(bottom: 8), // Margin between boxes
                    child: ListTile(
                      title: Text(_reports[index]['title'], style: const TextStyle(fontSize: 24)),
                      subtitle: Text(_reports[index]['notes']),
                      trailing: SizedBox(
                        width: 130,
                        child: Row(
                          children: [
                            Text(
                                _reports[index]['score']?.toString() ?? '',
                                style: const TextStyle(fontSize: 30)
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                _showDeleteConfirmationDialog(_reports[index]['id']);
                              },
                              icon: Icon(Icons.delete, color: Colors.red[900]),
                            ),
                          ],
                        ),
                      ),
                    ),

                  );
                },
              ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
