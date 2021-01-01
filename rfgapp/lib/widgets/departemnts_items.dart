import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rfgapp/model/item.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class DepartmentItems extends StatefulWidget {
  final Map<dynamic, dynamic> map;
  DepartmentItems(this.map);
  @override
  _DepartmentItemsState createState() => _DepartmentItemsState();
}

class _DepartmentItemsState extends State<DepartmentItems> {
  List<Item> items = [];
  List<Item> selectedItems;
  bool sort;
  final pdf = pw.Document();

  @override
  void initState() {
    sort = false;
    selectedItems = [];
    widget.map.forEach((key, value) {
      items.add(Item(
          name: key,
          qty: value['qty'],
          length: 50.0,
          width: 20.0,
          notification: 'color 9006'));
    });
    super.initState();
  }

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        items.sort((a, b) => a.name.compareTo(b.name));
      } else {
        items.sort((a, b) => b.name.compareTo(a.name));
      }
    }
  }

  onSelectedRow(bool selected, Item item) async {
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
        List<Item> temp = [];
        temp.addAll(selectedItems);
        for (Item user in temp) {
          items.remove(user);
          selectedItems.remove(user);
        }
      }
    });
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
            <String>['Name', 'Coach', 'players', 'hello'],
            ...items.map((item) => [
                  item.name,
                  item.length.toString(),
                  item.width.toString(),
                  item.notification
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

  //////////////////////////////////////////////////////////////////////////////////
  SingleChildScrollView dataBody() {
    var width = MediaQuery.of(context).size.width / 8;
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: width,
            sortAscending: sort,
            sortColumnIndex: 0,
            columns: [
              DataColumn(
                  label: Text("Name"),
                  numeric: false,
                  tooltip: "This is First Name",
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      sort = !sort;
                    });
                    onSortColum(columnIndex, ascending);
                  }),
              DataColumn(
                label: Text("Size"),
                numeric: false,
                tooltip: "This is Last Name",
              ),
              DataColumn(
                label: Text("Qty"),
                numeric: false,
                tooltip: "This is Last Name",
              ),
              DataColumn(
                label: Text("Notification"),
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
                          Text(user.name),
                          onTap: () {
                            print('Selected ${user.name}');
                          },
                        ),
                        DataCell(
                          Text(user.length.toString() +
                              'X' +
                              user.width.toString()),
                        ),
                        DataCell(
                          Text(user.qty.toString()),
                        ),
                        DataCell(
                          Text(user.notification),
                        ),
                      ]),
                )
                .toList(),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('order no..'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              writeOnPdf();
              await savePdf();

              Directory documentDirectory =
                  await getApplicationDocumentsDirectory();

              String documentPath = documentDirectory.path;

              String fullPath = "$documentPath/example.pdf";

           
            },
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Expanded(
            child: dataBody(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20.0),
                child: OutlineButton(
                  child: Text('SELECTED ${selectedItems.length}'),
                  onPressed: () {},
                ),
              ),
              /*   Padding(
                padding: EdgeInsets.all(20.0),
                child: OutlineButton(
                  child: Text('DELETE SELECTED'),
                  onPressed: selectedItems.isEmpty
                      ? null
                      : () {
                          deleteSelected();
                        },
                ),
              ), */
            ],
          ),
        ],
      ),
    );
  }
}
