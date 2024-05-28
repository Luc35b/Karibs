import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:karibs/database/database_helper.dart';
import 'package:printing/printing.dart';

class PdfGenerator {
  Future<void> generateTestPdf(int testId, String testTitle) async {
    final pdf = pw.Document();
    final questions = await DatabaseHelper().queryAllQuestions(testId);
    //print(questions);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(testTitle, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              ...questions.map((question) {
                //print('Question: ${question['text']}');
                //print('Answer: ${question['answer']}');
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Q: ${question['text']}', style: pw.TextStyle(fontSize: 18)),
                    pw.SizedBox(height: 10),
                    pw.Text('A: ${question['answer'] ?? 'No answer provided'}', style: pw.TextStyle(fontSize: 16)),
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
    final file = File('${output.path}/$testTitle.pdf');
    await file.writeAsBytes(await pdf.save());

    // Print the PDF
    Printing.sharePdf(bytes: await pdf.save(), filename: '$testTitle.pdf');
  }
}
