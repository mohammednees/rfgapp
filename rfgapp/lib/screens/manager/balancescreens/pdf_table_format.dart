import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generateInvoice(PdfPageFormat pageFormat, Invoice inv) async {
  final lorem = pw.LoremText();

  final invoice = Invoice(
    invoiceNumber: inv.invoiceNumber,
    products: inv.products,
    customerName: inv.customerName,
    orderInfo: inv.orderInfo,
    baseColor: PdfColors.blue400,
    accentColor: PdfColors.grey700,
  );

  return await invoice.buildPdf(pageFormat);
}

class Invoice {
  Invoice({
    this.products,
    this.customerName,
    this.invoiceNumber,
    this.orderInfo,
    this.baseColor,
    this.accentColor,
  });

  Invoice.fromJson(Map<String, dynamic> json)
      : customerName = json['name'],
        invoiceNumber = json['no'],
        orderInfo = json['info'],
        products = json['products'],
        baseColor = json['baseColor'],
        accentColor = json['accentColor'];

  Map<String, dynamic> toJson() => {
        'name': customerName,
        'no': invoiceNumber,
        'info': orderInfo,
        'products': products,
        'baseColor': baseColor,
        'accentColor': accentColor,
      };

  List<Product> products;
  String customerName;

  String invoiceNumber;

  String orderInfo;
  PdfColor baseColor;
  PdfColor accentColor;

  static const _darkColor = PdfColors.blueGrey800;
  static const _lightColor = PdfColors.white;

  PdfColor get _baseTextColor =>
      baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  PdfColor get _accentTextColor =>
      baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  double get _total =>
      products.map<double>((p) => p.total).reduce((a, b) => a + b);

  double get _grandTotal => _total * (1);

  PdfImage _logo;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    // Create a PDF document.
    final doc = pw.Document();

    final font1 = await rootBundle.load('assets/fonts/arabic.ttf');
    final font2 = await rootBundle.load('assets/fonts/arabic.ttf');
    final font3 = await rootBundle.load('assets/fonts/arabic.ttf');

    _logo = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('assets/image/ic_launcher.png'))
          .buffer
          .asUint8List(),
    );

    // Add page to the PDF
    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
          pageFormat,
          font1 != null ? pw.Font.ttf(font1) : null,
          font2 != null ? pw.Font.ttf(font2) : null,
          font3 != null ? pw.Font.ttf(font3) : null,
        ),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          _contentTable(context),
          pw.SizedBox(height: 20),
          _contentFooter(context),
        ],
      ),
    );

    // Return the PDF file content
    return doc.save();
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Container(
                          width: 120,
                          padding:
                              const pw.EdgeInsets.only(bottom: 8, left: 10),
                          height: 120,
                          child: _logo != null
                              ? pw.Image(_logo, width: 120, height: 120)
                              : pw.PdfLogo(),
                        ),
                        pw.Container(
                          height: 100,
                          padding:
                              const pw.EdgeInsets.only(right: 10, bottom: 10),
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text(
                            'مبيعات',
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(
                              color: baseColor,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ]),
                  pw.Container(
                    width: 550,
                    decoration: pw.BoxDecoration(
                      borderRadius: 2,
                      color: accentColor,
                    ),
                    padding: const pw.EdgeInsets.only(
                        left: 120, top: 4, bottom: 10, right: 10),
                    alignment: pw.Alignment.centerRight,
                    height: 70,
                    child: pw.DefaultTextStyle(
                      style: pw.TextStyle(
                        color: _accentTextColor,
                        fontSize: 18,
                      ),
                      child: pw.GridView(
                        crossAxisCount: 2,
                        children: [
                          pw.Expanded(
                            child: pw.Text(invoiceNumber),
                          ),
                          pw.Expanded(
                            child: pw.Text('رقم الطلبية :',
                                textDirection: pw.TextDirection.rtl),
                          ),
                          pw.Text(_formatDate(DateTime.now()),
                              textDirection: pw.TextDirection.rtl),
                          pw.Text('التاريخ:',
                              textDirection: pw.TextDirection.rtl),
                          pw.Text(customerName,
                              textDirection: pw.TextDirection.rtl),
                          pw.Text('اسم الزيون:',
                              textDirection: pw.TextDirection.rtl),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ],
        ),
        if (context.pageNumber > 1) pw.SizedBox(height: 20)
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Container(
          height: 20,
          width: 100,
          //   child: pw.BarcodeWidget(
          //    barcode: pw.Barcode.pdf417(),
          //     data: 'Invoice# $invoiceNumber',
          //    ),
        ),
        pw.Text(
          'Page ${context.pageNumber}/${context.pagesCount}',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey,
          ),
        ),
      ],
    );
  }

  pw.PageTheme _buildTheme(
      PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(
        base: base,
        bold: bold,
        italic: italic,
      ),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Positioned(
              bottom: 0,
              left: 0,
              child: pw.Container(
                height: 20,
                width: pageFormat.width / 2,
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [baseColor, PdfColors.white],
                  ),
                ),
              ),
            ),
            pw.Positioned(
              bottom: 20,
              left: 0,
              child: pw.Container(
                height: 20,
                width: pageFormat.width / 4,
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [accentColor, PdfColors.white],
                  ),
                ),
              ),
            ),
            pw.Positioned(
              top: pageFormat.marginTop + 80,
              left: 0,
              right: 0,
              child: pw.Container(
                height: 2,
                color: baseColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(flex: 2, child: pw.Container(width: 500)),
        pw.Expanded(
          flex: 1,
          child: pw.DefaultTextStyle(
            style: const pw.TextStyle(
              fontSize: 10,
              color: _darkColor,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Divider(color: accentColor),
                pw.DefaultTextStyle(
                  style: pw.TextStyle(
                    color: baseColor,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('المجموع', textDirection: pw.TextDirection.rtl),
                      pw.Text(_formatCurrency(_grandTotal)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    /*    const tableHeaders = [
      'No.',
      'Item Description',
      'Price',
      'Quantity',
      'Total'
    ]; */

    const tableHeaders = [
      'المجموع',
      'الكمية',
      'السعر',
      'الصنف',
      'الرقم',
    ];

    return pw.Table.fromTextArray(
        border: null,
        cellAlignment: pw.Alignment.centerRight,
        headerDecoration: pw.BoxDecoration(

          borderRadius: 2,
          color: baseColor,
        ),
        headerHeight: 30,
        cellHeight: 40,
        cellAlignments: {
          0: pw.Alignment.centerRight,
          1: pw.Alignment.centerRight,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.center,
          4: pw.Alignment.centerRight,
        },
        headerStyle: pw.TextStyle(
          color: _baseTextColor,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
        cellStyle: const pw.TextStyle(
          color: _darkColor,
          fontSize: 12,
        ),
        
        rowDecoration: pw.BoxDecoration(
          
          border: pw.BoxBorder(
            bottom: true,
            color: accentColor,
            width: .5,
          ),
        ),
             headers: List<String>.generate(
        tableHeaders.length,
        (col) => tableHeaders[col],
      ),

        data: List<List<String>>.generate(
          products.length,
          (row) => List<String>.generate(
            tableHeaders.length,
            (col) => products[row].getIndex(col),
          ),
        ));
  }
}

String _formatCurrency(double amount) {
  return '${amount.toStringAsFixed(2)} ';
}

String _formatDate(DateTime date) {
//  final format = DateFormat.yMMMMd('en_US');
  final df = new DateFormat('dd-MM-yyyy');
  return df.format(date);
  // return DateFormat.yMd().format(date);
  //return format.format(date);
}

class Product {
  const Product(
    this.sku,
    this.productName,
    this.price,
    this.quantity,
  );

  final String sku;
  final String productName;
  final double price;
  final int quantity;
  double get total => price * quantity;
/* 
  Product.fromJson(Map<String, dynamic> json)
      : sku = json['sku'],
        productName = json['name'],
        price = json['price'],
        quantity = json['qty'];

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'name': productName,
        'price': price,
        'qty': quantity,
      };
 */
  String getIndex(int index) {
    switch (index) {
      case 0:
        return sku;
      case 1:
        return productName;
      case 2:
        return _formatCurrency(price);
      case 3:
        return quantity.toString();
      case 4:
        return _formatCurrency(total);
    }
    return '';
  }
}
