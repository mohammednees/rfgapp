import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:rfgapp/model/balance.dart';
import 'package:rfgapp/model/item.dart';
import 'package:rfgapp/model/itemap.dart';
import 'package:rfgapp/model/mainitem.dart';
import 'package:rfgapp/model/pdf_screen.dart';
import 'package:rfgapp/screens/manager/balance.dart';
import 'package:pdf/widgets.dart' as pw;

class BalanceReport extends StatefulWidget {
  final String customerName;
  final DateTime finalDate;
  final DateTime startDate;

  BalanceReport(this.customerName, this.startDate, this.finalDate);
  @override
  _BalanceReportState createState() => _BalanceReportState();
}

class _BalanceReportState extends State<BalanceReport> {
  List<BalanceItem> items = [];
  List<BalanceItem> selectedItems;
  bool sort;
  List<MainItemOrder> mainitems = [];
  List<MainItemMapOrder> itemMap = [];
  double totalBalance = 0;
  List<Map<dynamic, dynamic>> itemMappp = [];

  final pdf = pw.Document();

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        items.sort((a, b) => a.createAt.compareTo(b.createAt));
      } else {
        items.sort((a, b) => b.createAt.compareTo(a.createAt));
      }
    }
  }

  onSelectedRow(bool selected, BalanceItem item) async {
    setState(() {
      if (selected) {
        selectedItems.add(item);
      } else {
        selectedItems.remove(item);
      }
    });
  }

  deleteSelected() async {
    setState(() {
      if (selectedItems.isNotEmpty) {
        List<BalanceItem> temp = [];
        temp.addAll(selectedItems);
        for (BalanceItem user in temp) {
          items.remove(user);
          selectedItems.remove(user);
        }
      }
    });
  }

  _getOrderByCustomerName() async {
    var timestamfinal = Timestamp.fromDate(widget.finalDate);
    var timestamstart = Timestamp.fromDate(widget.startDate);

    await Firestore.instance
        .collection('orders')
        .where('customerName', isEqualTo: widget.customerName)
        .where('createAt', isLessThanOrEqualTo: timestamfinal)
        .where('createAt', isGreaterThan: timestamstart)
        .orderBy('createAt', descending: true)
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        items.add(BalanceItem(
            createAt: result['createAt'],
            total: result['Total'],
            orderNo: result['orderNo'],
            info: result['orderInfo']));
      });
    }).whenComplete(() async {
      await Firestore.instance
          .collection('payments')
          .where('paymentName', isEqualTo: widget.customerName)
          .where('createAt', isLessThanOrEqualTo: timestamfinal)
          .where('createAt', isGreaterThan: timestamstart)
          .orderBy('createAt', descending: true)
          .getDocuments()
          .then((querySnapshot) {
        querySnapshot.documents.forEach((result) {
          items.add(BalanceItem(
              createAt: result['createAt'],
              total: (result['Total'] * -1),
              orderNo: result['paymentNo'],
              info: result['paymentInfo']));
        });
      }).whenComplete(() {
        setState(() {
          items.sort((a, b) {
            var adate = a.createAt; //before -> var adate = a.expiry;
            var bdate = b.createAt; //before -> var bdate = b.expiry;
            return adate.compareTo(
                bdate); //to get the order other way just switch `adate & bdate`
          });
        });
      });
    });
  }

  void _getitemsmap() async {
    Firestore.instance.collection('orders').getDocuments().then((value) {
      value.documents.forEach((element) {
        mainitems.add(MainItemOrder(
            createAt: element['createAt'],
            orderNo: element['orderNo'],
            name: element['orderInfo'],
            qty: 5,
            total: element['Total']));

        Map<dynamic, dynamic> mapppp = element['items'];

        mapppp.forEach((key, value) {
          mainitems.add(MainItemOrder(
              createAt: null,
              orderNo: null,
              name: key,
              qty: value['price'],
              total: value['qty'] * value['price']));
        });
      });
    });

// widget.map.forEach((key, value) {
//       items.add(Item(
//           name: key,
//           qty: value['qty'],
//           length: 50.0,
//           width: 20.0,
//           notification: 'color 9006'));
//     });
  }

  @override
  void initState() {
    selectedItems = [];
    sort = false;
    // selectedUsers = [];
    //  users = User.getUsers();
    _getitemsmap();

    _getOrderByCustomerName();
    super.initState();
  }

//////////////////////////////////////////////////////////////////////////////
  ///

  writeOnPdf() async {
    var _logo = PdfImage.file(
      pdf.document,
      bytes: (await rootBundle.load('assets/image/app-icon2.jpg'))
          .buffer
          .asUint8List(),
    );

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return <pw.Widget>[
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Padding(
                    padding: pw.EdgeInsets.symmetric(vertical: 5),
                    child: pw.Image(_logo,
                        width: 200, height: 100, fit: pw.BoxFit.contain)),
                pw.Text('Ramallah Co for HVAC')
              ]),
          pw.Header(
              child: pw.Center(
                  child: pw.Text("Orders",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 20)))),
          pw.Text('Date:'),
          pw.Text('Finish Date:'),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text('Customer Name'), pw.Text('Order:')]),
          pw.Paragraph(text: "date:"),
          pw.Table.fromTextArray(context: context, data: <List<String>>[
            <String>[
              'Date',
              'orderNo',
              'Name',
              'Price',
              'Qty',
              'Total',
              'Total Balance'
            ],
            ...mainitems.map((item) =>
                /*  {
              totalBalance = item.total + totalBalance;
              print(totalBalance.toString()); */
                [
                  item.createAt == null
                      ? ''
                      : DateFormat.yMd()
                          .format(
                              DateTime.parse(item.createAt.toDate().toString()))
                          .toString(),
                  item.orderNo.toString(),
                  item.name,
                  '',
                  item.qty.toString(),
                  item.total.toString(),
                  totalBalance.toString(),
                ])
          ]),
        ];
      },
    ));
  }

  Future savePdf() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String documentPath = documentDirectory.path;

    File file = File("$documentPath/example.pdf");

    file.writeAsBytesSync(pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width / 8;
    return Scaffold(
        appBar: AppBar(
          title: Text('Balance Report'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.picture_as_pdf),
                onPressed: () async {
                  writeOnPdf();
                  //   await savePdf();
                var d =    await generateInvoice(PdfPageFormat.a4);
              
                  Directory documentDirectory =
                      await getApplicationDocumentsDirectory();

                  String documentPath = documentDirectory.path;

                //  String fullPath = "$documentPath/example.pdf";
                      String fullPath = "$d/example.pdf";
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PdfPreviewScreen(
                                path: fullPath,
                              )));
                })
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.grey,
              ),
              child: DataTable(
                columnSpacing: width,
                sortAscending: sort,
                sortColumnIndex: 0,
                columns: [
                  DataColumn(
                      label: Text("Date"),
                      numeric: false,
                      tooltip: "This is First Name",
                      onSort: (columnIndex, ascending) {
                        setState(() {
                          sort = !sort;
                        });
                        onSortColum(columnIndex, ascending);
                      }),
                  DataColumn(
                    label: Text("orderNo"),
                    numeric: false,
                    tooltip: "This is Last Name",
                  ),
                  DataColumn(
                    label: Text("total"),
                    numeric: false,
                    tooltip: "This is Last Name",
                  ),
                  DataColumn(
                    label: Text("info"),
                    numeric: false,
                    tooltip: "This is Last Name",
                  ),
                ],
                rows: items
                    .map(
                      (user) => DataRow(
                          selected: selectedItems.contains(user),
                          onSelectChanged: (b) {
                            print("Onselect");
                            onSelectedRow(b, user);
                          },
                          cells: [
                            DataCell(
                              Text(
                                  DateFormat.yMd()
                                      .format(DateTime.parse(
                                          user.createAt.toDate().toString()))
                                      .toString(),
                                  style: user.total < 0
                                      ? TextStyle(color: Colors.red)
                                      : TextStyle(color: Colors.black)),
                              onTap: () {},
                            ),
                            DataCell(Text(user.orderNo.toString(),
                                style: user.total < 0
                                    ? TextStyle(color: Colors.red)
                                    : TextStyle(color: Colors.black))),
                            DataCell(
                              Text(user.total.toString(),
                                  style: user.total < 0
                                      ? TextStyle(color: Colors.red)
                                      : TextStyle(color: Colors.black)),
                            ),
                            DataCell(
                              Text(user.info,
                                  style: user.total < 0
                                      ? TextStyle(color: Colors.red)
                                      : TextStyle(color: Colors.black)),
                            ),
                          ]),
                    )
                    .toList(),
              ),
            ),
          ),
        ));
  }
}
///////////////////////////////////////////////////////////////////////////////////////
///
Future<Uint8List> generateInvoice(PdfPageFormat pageFormat) async {
  final lorem = pw.LoremText();

  final products = <Product>[
    Product('19874', lorem.sentence(4), 3.99, 2),
    Product('98452', lorem.sentence(6), 15, 2),
    Product('28375', lorem.sentence(4), 6.95, 3),
    Product('95673', lorem.sentence(3), 49.99, 4),
    Product('23763', lorem.sentence(2), 560.03, 1),
    Product('55209', lorem.sentence(5), 26, 1),
    Product('09853', lorem.sentence(5), 26, 1),
    Product('23463', lorem.sentence(5), 34, 1),
    Product('56783', lorem.sentence(5), 7, 4),
    Product('78256', lorem.sentence(5), 23, 1),
    Product('23745', lorem.sentence(5), 94, 1),
    Product('07834', lorem.sentence(5), 12, 1),
    Product('23547', lorem.sentence(5), 34, 1),
    Product('98387', lorem.sentence(5), 7.99, 2),
  ];

  final invoice = Invoice(
    invoiceNumber: '982347',
    products: products,
    customerName: 'Abraham Swearegin',
    customerAddress: '54 rue de Rivoli\n75001 Paris, France',
    paymentInfo:
        '4509 Wiseman Street\nKnoxville, Tennessee(TN), 37929\n865-372-0425',
    tax: .15,
    baseColor: PdfColors.teal,
    accentColor: PdfColors.blueGrey900,
  );

  return await invoice.buildPdf(pageFormat);
}

class Invoice {
  Invoice({
    this.products,
    this.customerName,
    this.customerAddress,
    this.invoiceNumber,
    this.tax,
    this.paymentInfo,
    this.baseColor,
    this.accentColor,
  });

  final List<Product> products;
  final String customerName;
  final String customerAddress;
  final String invoiceNumber;
  final double tax;
  final String paymentInfo;
  final PdfColor baseColor;
  final PdfColor accentColor;

  static const _darkColor = PdfColors.blueGrey800;
  static const _lightColor = PdfColors.white;

  PdfColor get _baseTextColor =>
      baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  PdfColor get _accentTextColor =>
      baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  double get _total =>
      products.map<double>((p) => p.total).reduce((a, b) => a + b);

  double get _grandTotal => _total * (1 + tax);

  PdfImage _logo;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    // Create a PDF document.
    final doc = pw.Document();

    final font1 = await rootBundle.load('assets/roboto1.ttf');
    final font2 = await rootBundle.load('assets/roboto2.ttf');
    final font3 = await rootBundle.load('assets/roboto3.ttf');

    _logo = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
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
          _contentHeader(context),
          _contentTable(context),
          pw.SizedBox(height: 20),
          _contentFooter(context),
          pw.SizedBox(height: 20),
          _termsAndConditions(context),
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
                  pw.Container(
                    height: 50,
                    padding: const pw.EdgeInsets.only(left: 20),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        color: baseColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      borderRadius: 2,
                      color: accentColor,
                    ),
                    padding: const pw.EdgeInsets.only(
                        left: 40, top: 10, bottom: 10, right: 20),
                    alignment: pw.Alignment.centerLeft,
                    height: 50,
                    child: pw.DefaultTextStyle(
                      style: pw.TextStyle(
                        color: _accentTextColor,
                        fontSize: 12,
                      ),
                      child: pw.GridView(
                        crossAxisCount: 2,
                        children: [
                          pw.Text('Invoice #'),
                          pw.Text(invoiceNumber),
                          pw.Text('Date:'),
                          pw.Text(_formatDate(DateTime.now())),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(
                    alignment: pw.Alignment.topRight,
                    padding: const pw.EdgeInsets.only(bottom: 8, left: 30),
                    height: 72,
                    child: _logo != null ? pw.Image(_logo) : pw.PdfLogo(),
                  ),
                  // pw.Container(
                  //   color: baseColor,
                  //   padding: pw.EdgeInsets.only(top: 3),
                  // ),
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
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.pdf417(),
            data: 'Invoice# $invoiceNumber',
          ),
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
              top: pageFormat.marginTop + 72,
              left: 0,
              right: 0,
              child: pw.Container(
                height: 3,
                color: baseColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _contentHeader(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 20),
            height: 70,
            child: pw.FittedBox(
              child: pw.Text(
                'Total: ${_formatCurrency(_grandTotal)}',
                style: pw.TextStyle(
                  color: baseColor,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Row(
            children: [
              pw.Container(
                margin: const pw.EdgeInsets.only(left: 10, right: 10),
                height: 70,
                child: pw.Text(
                  'Invoice to:',
                  style: pw.TextStyle(
                    color: _darkColor,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  height: 70,
                  child: pw.RichText(
                      text: pw.TextSpan(
                          text: '$customerName\n',
                          style: pw.TextStyle(
                            color: _darkColor,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                        const pw.TextSpan(
                          text: '\n',
                          style: pw.TextStyle(
                            fontSize: 5,
                          ),
                        ),
                        pw.TextSpan(
                          text: customerAddress,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal,
                            fontSize: 10,
                          ),
                        ),
                      ])),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Thank you for your business',
                style: pw.TextStyle(
                  color: _darkColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 20, bottom: 8),
                child: pw.Text(
                  'Payment Info:',
                  style: pw.TextStyle(
                    color: baseColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                paymentInfo,
                style: const pw.TextStyle(
                  fontSize: 8,
                  lineSpacing: 5,
                  color: _darkColor,
                ),
              ),
            ],
          ),
        ),
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
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Sub Total:'),
                    pw.Text(_formatCurrency(_total)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tax:'),
                    pw.Text('${(tax * 100).toStringAsFixed(1)}%'),
                  ],
                ),
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
                      pw.Text('Total:'),
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

  pw.Widget _termsAndConditions(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                    top: true,
                    color: accentColor,
                  ),
                ),
                padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
                child: pw.Text(
                  'Terms & Conditions',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: baseColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                pw.LoremText().paragraph(40),
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(
                  fontSize: 6,
                  lineSpacing: 2,
                  color: _darkColor,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.SizedBox(),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    const tableHeaders = [
      'SKU#',
      'Item Description',
      'Price',
      'Quantity',
      'Total'
    ];

    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        borderRadius: 2,
        color: baseColor,
      ),
      headerHeight: 25,
      cellHeight: 40,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
      headerStyle: pw.TextStyle(
        color: _baseTextColor,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(
        color: _darkColor,
        fontSize: 10,
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
      ),
    );
  }
}

String _formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';
}

String _formatDate(DateTime date) {
  final format = DateFormat.yMMMMd('en_US');
  return format.format(date);
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
