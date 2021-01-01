import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfgapp/model/balance.dart';
import 'package:rfgapp/model/itemap.dart';
import 'package:rfgapp/model/mainitem.dart';
import 'package:rfgapp/screens/manager/balancescreens/pdf_view.dart';

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
  }

  @override
  void initState() {
    selectedItems = [];
    sort = false;
    _getitemsmap();

    _getOrderByCustomerName();
    super.initState();
  }

//////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width / 8;
    return Scaffold(
        appBar: AppBar(
          title: Text('Balance Report'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.picture_as_pdf),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return PDFView();
                    },
                  ));
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
