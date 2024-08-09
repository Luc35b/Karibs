import 'dart:io';
import 'package:flutter/material.dart';
import 'package:karibs/preview_pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PdfGenerator {
  final BuildContext context;

  PdfGenerator(this.context);

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
                              margin: const pw.EdgeInsets.only(top: 15),
                              padding: const pw.EdgeInsets.only(bottom: 1),
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(width: 0.5),
                                ),
                              ),
                              height: 20,
                            );
                          }),
                        ),
                      if (question['type'] == 'Fill in the Blank')
                        pw.Container(
                          margin: const pw.EdgeInsets.only(top: 10, bottom: 10),
                          padding: const pw.EdgeInsets.only(bottom: 1),
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 0.5),
                            ),
                          ),
                          height: 20,
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
    final filePath = '${output.path}/$testTitle - Questions.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(path: filePath, title: '$testTitle - Questions.pdf'),
      ),
    );
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
    final filePath = '${output.path}/$testTitle - Answer Key.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(path: filePath, title: '$testTitle - Answer Key.pdf'),
      ),
    );
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
                          pw.Text('Score: ${report['score']?.toStringAsFixed(2) ?? 'N/A'}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
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
    final filePath = '${output.path}/${student['name']} - Report.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(path: filePath, title: '${student['name']} - Report.pdf'),
      ),
    );
  }

  Future<void> generateClassReportPdf(String className, double? averageGrade, List<Map<String, dynamic>> students) async {
    final pdf = pw.Document();

    final List<Map<String, dynamic>> sortedStudents = List.from(students);

    sortedStudents.sort((a, b) => a['name'].compareTo(b['name']));

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Column(
              children: [
                pw.Text('Class Name: $className', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Class Grade Average: ${(averageGrade ?? 0).toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 10),
                pw.Text('Students:', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                ...sortedStudents.map((student) {
                  final averageScore = student['average_score'];
                  final scoreText = (averageScore != null && averageScore is num) ? averageScore.toStringAsFixed(2) : '--';
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(student['name'] ?? '', style: const pw.TextStyle(fontSize: 16)),
                      pw.Text(
                        '.' * ((80 - (student['name'] ?? '').length).round()),
                        style: const pw.TextStyle(fontSize: 16),
                      ),
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(path: file.path, title: '$className - Report.pdf'),
      ),
    );
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
                    pw.Text('Score: ${report['score']?.toStringAsFixed(2) ?? 'N/A'}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(path: file.path, title: '${student['name']} - ${report['title']} Report.pdf'),
      ),
    );
  }

  Future<void> generateTestScoresPdf(int testId, String testTitle, List<Map<String, dynamic>> students) async {
    final pdf = pw.Document();

    List<Map<String, dynamic>> studentScores = await DatabaseHelper().getStudentScoresByTestId(testId);

    List<Map<String, dynamic>> mutableStudents = List.from(students);

    mutableStudents.sort((a, b) => a['name'].compareTo(b['name']));

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
                for (var student in mutableStudents)
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          '${student['name']}  ',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Text(
                        generateFillerString(
                          '${student['name']}  ',
                          '   ${_formatScore(studentScores.firstWhere((score) => score['student_id'] == student['id'], orElse: () => {'total_score': null})['total_score'])}',
                        ),
                        style: const pw.TextStyle(fontSize: 16),
                      ),
                      pw.Text(
                        '   ${_formatScore(studentScores.firstWhere((score) => score['student_id'] == student['id'], orElse: () => {'total_score': null})['total_score'])}', // Check for null and display '--'
                        style: const pw.TextStyle(fontSize: 16),
                      ),
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(path: file.path, title: '$testTitle - Scores.pdf'),
      ),
    );
  }


  String _formatScore(dynamic score) {
    if (score == null) {
      return '   --   ';
    } else {
      return double.tryParse(score.toString())?.toStringAsFixed(2) ?? '   --   ';
    }
  }

  String generateFillerString(String name, String score) { // Filler string for between name and score
    final maxLength = 90;
    int remainingLength = 0;
    if(score == '   --   '){
      remainingLength = maxLength - name.length - score.length + 10;
    }else {
      remainingLength = maxLength - name.length - score.length;
    }
    return '.' * remainingLength;
  }

  Future<void> generateTestImportPdf(int testId, String testTitle, int subjectId) async {
    final pdf = pw.Document();
    final questions = await _getOrderedQuestions(testId);

    // Fetch the subject name based on the subjectId
    String? subjectName = await DatabaseHelper().getSubjectNameById(subjectId);

    // Create a map to store categoryId to categoryName mapping
    Map<int, String> categoryMap = {};

    // Populate the categoryMap with category names
    for (var question in questions) {
      int categoryId = question['category_id'];
      if (!categoryMap.containsKey(categoryId)) {
        String? categoryName = await DatabaseHelper().getCategoryNameById(categoryId);
        categoryMap[categoryId] = categoryName ?? 'Unknown Category';
      }
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('_Import_Format_^', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('title:$testTitle|subject:$subjectName^', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                ...questions.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  var question = entry.value;
                  String? categoryName = categoryMap[question['category_id']];

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (question['type'] == 'Multiple Choice')
                        pw.Text('Q.${question['text']}|m_c|$categoryName|${question['essay_spaces']??''}^', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      if (question['type'] == 'Fill in the Blank')
                        pw.Text('Q.${question['text']}|f_b|$categoryName|${question['essay_spaces']??''}^', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      if (question['type'] == 'Essay')
                        pw.Text('Q.${question['text']}|${question['type']}|$categoryName|${question['essay_spaces']??''}^', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      if (question['choices'] != null)
                        ...question['choices'].asMap().entries.map<pw.Widget>((choiceEntry) {
                          int choiceIndex = choiceEntry.key;
                          var choice = choiceEntry.value;
                          return pw.Text(
                            'A.$choiceIndex|${choice['choice_text']}|${choice['is_correct'] == 1 ? 'true' : 'false'}^',
                            style: pw.TextStyle(fontSize: 14),
                          );
                        }).toList(),
                      pw.SizedBox(height: 20),
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
    final filePath = '${output.path}/$testTitle - Import Format.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Ensure the context is still mounted before navigating
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfPreviewScreen(path: filePath, title: '$testTitle - Import Format.pdf'),
        ),
      );
    }
  }
}