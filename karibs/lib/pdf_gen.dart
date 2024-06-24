import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:printing/printing.dart';
//import 'package:screenshot/screenshot.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PdfGenerator {

  Future<List<Map<String, dynamic>>> _getOrderedQuestions(int testId) async {
    final data = await DatabaseHelper().queryAllQuestionsWithChoices(testId);
    final prefs = await SharedPreferences.getInstance();
    final orderList = prefs.getStringList('test_${testId}_order');

    if (orderList != null) {
      data.sort((a, b) => orderList.indexOf(a['id'].toString()).compareTo(orderList.indexOf(b['id'].toString())));
    }

    return data;
  }
  Future<void> generateTestQuestionsPdf(int testId, String testTitle) async {
    final pdf = pw.Document();
    final questions = await _getOrderedQuestions(testId);

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Name: _________________  Date: ________  Marks: ____', style: const pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 20),
                pw.Text(testTitle, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                ...questions.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  var question = entry.value;
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('$index. ${question['text']}', style: const pw.TextStyle(fontSize: 18)),
                      pw.SizedBox(height: 10),
                      if (question['type'] == 'Multiple Choice' && question['choices'] != null)
                        ...question['choices'].asMap().entries.map<pw.Widget>((choiceEntry) {
                          int choiceIndex = choiceEntry.key;
                          var choice = choiceEntry.value;
                          String choiceLabel = String.fromCharCode(65 + choiceIndex); // A, B, C, etc.
                          return pw.Text(
                            '$choiceLabel. ${choice['choice_text']}',
                            style: const pw.TextStyle(fontSize: 16),
                          );
                        }).toList(),
                      if (question['type'] == 'Essay')
                        pw.Column(
                          children: List.generate(question['essay_spaces'] ?? 1, (_) {
                            return pw.Container(
                              margin: const pw.EdgeInsets.only(top: 15), // Increase top margin for more spacing
                              padding: const pw.EdgeInsets.only(bottom: 1),
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(width: 0.5),
                                ),
                              ),
                              height: 20, // Add a height to make the line more visible
                            );
                          }),
                        ),
                      if (question['type'] == 'Fill in the Blank')
                        pw.Container(
                          margin: const pw.EdgeInsets.only(top: 10, bottom: 10), // Add margins for spacing
                          padding: const pw.EdgeInsets.only(bottom: 1),
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 0.5),
                            ),
                          ),
                          height: 20, // Add a height to make the line more visible
                        ),
                      pw.SizedBox(height: 20),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$testTitle - Questions.pdf');
    await file.writeAsBytes(await pdf.save());

    // Print the PDF
    Printing.sharePdf(bytes: await pdf.save(), filename: '$testTitle - Questions.pdf');
  }

  Future<void> generateTestAnswerKeyPdf(int testId, String testTitle) async {
    final pdf = pw.Document();
    final questions = await _getOrderedQuestions(testId);

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Answer Key', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text(testTitle, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                ...questions.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  var question = entry.value;
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('$index. ${question['text']}', style: const pw.TextStyle(fontSize: 18)),
                      pw.SizedBox(height: 10),
                      if (question['choices'] != null)
                        ...question['choices'].asMap().entries.map<pw.Widget>((choiceEntry) {
                          int choiceIndex = choiceEntry.key;
                          var choice = choiceEntry.value;
                          String choiceLabel = String.fromCharCode(65 + choiceIndex); // A, B, C, etc.
                          return pw.Text(
                            '$choiceLabel: ${choice['choice_text']} - ${choice['is_correct'] == 1 ? 'Correct' : 'Incorrect'}',
                            style: const pw.TextStyle(fontSize: 16),
                          );
                        }).toList()
                      else
                        pw.Text(
                          'Answer: ${question['answer'] ?? 'No answer provided'}',
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                      pw.SizedBox(height: 20),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$testTitle - Answer Key.pdf');
    await file.writeAsBytes(await pdf.save());

    // Print the PDF
    Printing.sharePdf(bytes: await pdf.save(), filename: '$testTitle - Answer Key.pdf');
  }

  Future<void> generateStudentReportPdf(Map<String, dynamic> student, List<Map<String, dynamic>> reports) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(student['name'], style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Reports:', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                ...reports.map((report) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Title: ${report['title']}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Score: ${report['score']}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('Notes: ${report['notes']}', style: const pw.TextStyle(fontSize: 16)),
                      pw.SizedBox(height: 10),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${student['name']} - Report.pdf');
    await file.writeAsBytes(await pdf.save());

    // Print the PDF
    Printing.sharePdf(bytes: await pdf.save(), filename: '${student['name']} - Report.pdf');
  }


  Future<void> generateClassReportPdf(String className, double? averageGrade, List<Map<String, dynamic>> students) async {
    final pdf = pw.Document();

    // Create a copy of the students list before sorting
    final List<Map<String, dynamic>> sortedStudents = List.from(students);

    // Sort students by name alphabetically
    sortedStudents.sort((a, b) => a['name'].compareTo(b['name']));

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Column(
              children: [
                pw.Text('Class Name: $className', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Class Grade Average: ${(averageGrade ?? 0).toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 18)), // Check if averageGrade is null
                pw.SizedBox(height: 10),
                pw.Text('Students:', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                ...sortedStudents.map((student) {
                  final averageScore = student['average_score'];
                  final scoreText = (averageScore != null) ? averageScore.toStringAsFixed(2) : '—'; // Check if averageScore is null
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(student['name'], style: const pw.TextStyle(fontSize: 16)),
                      pw.Text(scoreText, style: const pw.TextStyle(fontSize: 16)),
                    ],
                  );
                }).toList(),
              ],
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$className - Report.pdf');
    await file.writeAsBytes(await pdf.save());

    // Print the PDF
    await Printing.sharePdf(bytes: await pdf.save(), filename: '$className - Report.pdf');
  }

  Future<void> generateIndividualReportPdf(Map<String, dynamic> student, Map<String, dynamic> report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(student['name'], style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Report Details:', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Title: ${report['title']}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Score: ${report['score']}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Text('Notes: ${report['notes']}', style: const pw.TextStyle(fontSize: 16)),
              ],
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${student['name']} - ${report['title']} Report.pdf');
    await file.writeAsBytes(await pdf.save());

    // Print the PDF
    Printing.sharePdf(bytes: await pdf.save(), filename: '${student['name']} - ${report['title']} Report.pdf');
  }

  Future<void> generateTestScoresPdf(int testId, String testTitle, List<Map<String, dynamic>> students) async {
    final pdf = pw.Document();

    // Fetch scores for each student from the student_test table
    List<Map<String, dynamic>> studentScores = await DatabaseHelper().getStudentScoresByTestId(testId);

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Test Scores - $testTitle', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Students:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                for (var student in students)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${student['name']}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Score: ${studentScores.firstWhere((score) => score['student_id'] == student['id'])['total_score']}', style: const pw.TextStyle(fontSize: 16)),
                      pw.SizedBox(height: 10),
                    ],
                  ),
              ],
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$testTitle - Scores.pdf');
    await file.writeAsBytes(await pdf.save());

    // Print the PDF
    Printing.sharePdf(bytes: await pdf.save(), filename: '$testTitle - Scores.pdf');
  }

}