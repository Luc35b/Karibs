import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:printing/printing.dart';

class PdfGenerator {

  Future<void> generateTestQuestionsPdf(int testId, String testTitle) async {
    final pdf = pw.Document();
    final questions = await DatabaseHelper().queryAllQuestions(testId);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(testTitle, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              ...questions.map((question) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Q: ${question['text']}', style: pw.TextStyle(fontSize: 18)),
                    pw.SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ],
          );
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
    final questions = await DatabaseHelper().queryAllQuestionsWithChoices(testId);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(testTitle, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              ...questions.map((question) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Q: ${question['text']}', style: pw.TextStyle(fontSize: 18)),
                    pw.SizedBox(height: 10),
                    if (question['choices'] != null)
                      ...question['choices'].map<pw.Widget>((choice) {
                        return pw.Text(
                          'A: ${choice['choice_text']} - ${choice['is_correct'] == 1 ? 'Correct' : 'Incorrect'}',
                          style: pw.TextStyle(fontSize: 16),
                        );
                      }).toList()
                    else
                      pw.Text(
                        'A: ${question['answer'] ?? 'No answer provided'}',
                        style: pw.TextStyle(fontSize: 16),
                      ),
                    pw.SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ],
          );
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
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
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
                    pw.Text('Notes: ${report['notes']}', style: pw.TextStyle(fontSize: 16)),
                    pw.SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );


    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${student['name']} - Report.pdf');
    await file.writeAsBytes(await pdf.save());

    // Print the PDF
    Printing.sharePdf(bytes: await pdf.save(), filename: '${student['name']} - Report.pdf');
  }

  Future<void> generateClassReportPdf(
      String className, double averageGrade, List<Map<String, dynamic>> students) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('Class Name: $className', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Average Grade: ${averageGrade.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            pw.Text('Students:', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            ...students.map((student) {
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(student['name'], style: pw.TextStyle(fontSize: 16)),
                  pw.Text(student['average_score']?.toStringAsFixed(2) ?? 'N/A', style: pw.TextStyle(fontSize: 16)),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$className - Report.pdf');
    await file.writeAsBytes(await pdf.save());

    // Print the PDF
    await Printing.sharePdf(bytes: await pdf.save(), filename: '$className - Report.pdf');
  }

}