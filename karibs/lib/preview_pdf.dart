import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatefulWidget {
  final String path;
  final String title;

  PdfPreviewScreen({required this.path, required this.title}); // Pass file path and name

  @override
  _PdfPreviewScreenState createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late PDFViewController _pdfViewController;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () async {
              // PDF print
              await Printing.layoutPdf(onLayout: (format) async => File(widget.path).readAsBytesSync(),);
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              // PDF share
              final bytes = File(widget.path).readAsBytesSync();
              await Printing.sharePdf(bytes: bytes, filename: widget.title);
            },
          ),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              // Multi page navigation
              if (_currentPage > 0) {
                _pdfViewController.setPage(_currentPage - 1);
              }
            },
          ),
          Text('${_currentPage + 1} / $_totalPages'),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () {
              if (_currentPage < _totalPages - 1) {
                _pdfViewController.setPage(_currentPage + 1);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.path,
            autoSpacing: true,
            enableSwipe: true,
            pageSnap: true,
            swipeHorizontal: false,
            nightMode: false,
            onError: (error) {
              setState(() {
                _errorMessage = error.toString();
              });
              print(error.toString());
            },
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages!;
                _isReady = true;
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              setState(() {
                _pdfViewController = pdfViewController;
              });
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
            },
            onPageError: (page, error) {
              setState(() {
                _errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
          ),
          !_isReady
              ? Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Container(),
        ],
      ),
    );
  }
}
