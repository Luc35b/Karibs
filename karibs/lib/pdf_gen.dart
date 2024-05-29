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
}