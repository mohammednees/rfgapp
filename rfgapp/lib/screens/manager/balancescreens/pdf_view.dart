import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'dart:async';
import 'package:pdf/pdf.dart';
import 'package:rfgapp/screens/manager/balancescreens/pdf_table_format.dart';



class PDFView extends StatefulWidget {
  @override
  _PDFViewState createState() => _PDFViewState();
}

class _PDFViewState extends State<PDFView> {
  PrintingInfo printingInfo;
  Invoice order;
  List<Product> json;
  Invoice inv;
  String text = ' دكت';

  @override
  void initState() {
    json = [
      Product('1', text, 10, 2),
      Product('2', 'duct', 10, 2),
      Product('3', 'duct', 10, 2),
      Product('1', 'duct', 10, 2),
      Product('2', 'duct', 10, 2),
      Product('3', 'duct', 10, 2),
      Product('1', 'duct', 10, 2),
      Product('2', 'duct', 10, 2),
      Product('3', 'duct', 10, 2),
      Product('1', 'duct', 10, 2),
      Product('2', 'duct', 10, 2),
      Product('3', 'duct', 10, 2),
      Product('1', 'duct', 10, 2),
      Product('2', 'duct', 10, 2),
      Product('3', 'duct', 10, 2),
      Product('1', 'duct', 10, 2),
      Product('2', 'duct', 10, 2),
      Product('3', 'duct', 10, 2),
      Product('1', 'duct', 10, 2),
      Product('2', 'duct', 10, 2),
      Product('3', 'duct', 10, 2),
      Product('1', 'duct', 10, 2),
      Product('2', 'duct', 10, 2),
      Product('3', 'duct', 10, 2),
      Product('1', 'duct', 10, 2),
      Product('2', 'duct', 10, 2),
      Product('3', 'duct', 10, 2),
    ];

    inv = Invoice(
        customerName: 'Mohammed',
        invoiceNumber: '0001',
        orderInfo: 'duct birzerit',
        products: json);

    super.initState();
  }

  void _showPrintedToast(BuildContext context) {
    final ScaffoldState scaffold = Scaffold.of(context);

    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Document printed successfully'),
      ),
    );
  }

  void _showSharedToast(BuildContext context) {
    final ScaffoldState scaffold = Scaffold.of(context);

    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Document shared successfully'),
      ),
    );
  }

  Future<void> _saveAsFile(
    BuildContext context,
    LayoutCallback build,
    PdfPageFormat pageFormat,
  ) async {
    final Uint8List bytes = await build(pageFormat);

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    final File file = File(appDocPath + '/' + 'invoice.pdf');
    print('Save as file ${file.path} ...');
    await file.writeAsBytes(bytes);
    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
 //  pw.RichText.debug = true;

    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(
          icon: const Icon(Icons.save),
          onPressed: _saveAsFile,
        )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pdf Printing Example'),
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        build: (c) => generateInvoice(PdfPageFormat.a4, inv),
        actions: actions,
        onPrinted: _showPrintedToast,
        onShared: _showSharedToast,
      ),
    );
  }
}
