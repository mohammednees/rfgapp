import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String path;
  
  PdfPreviewScreen({this.path});
void _printDocument() {
    Printing.layoutPdf(
      onLayout: (pageFormat) {
        final doc = pw.Document();

        doc.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Center(
              child: pw.Text('Hello World!'),
            ),
          ),
        );

        return doc.save();
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      appBar: AppBar(
        title: Text('Order No.'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.print),
              onPressed: () {
                print('print');
                _printDocument();
              })
        ],
      ),
      path: path,
    );
  }
}
