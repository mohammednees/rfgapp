import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfgapp/screens/manager/purchase/purchase_items.dart';

class Purchase extends StatefulWidget {
  static const routeName = '/Purchase';
  @override
  _PurchaseState createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Timestamp timestam =
        Timestamp.fromDate(DateTime.now().add(Duration(days: 1)));
    return Scaffold(
      appBar: AppBar(title:Text('Purchase List')),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('purchase')
            .where('createAt', isLessThan: timestam)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var customerdata = snapshot.data.documents;

          return ListView.builder(
            itemCount: customerdata.length == null ? 0 : customerdata.length,
            itemBuilder: (context, index) {
              Timestamp time = customerdata[index]['createAt'];
              var date = DateTime.fromMicrosecondsSinceEpoch(
                  time.microsecondsSinceEpoch);

              return Dismissible(
                  key: ValueKey(customerdata[index]),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Text((index + 1).toString()),
                        title: Text(customerdata[index]['sellerName']),
                        subtitle: Text(DateFormat.yMMMd().format(date) +
                            '  |  ' +
                            customerdata[index]['Total'].toString()),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (ctx) {
                            return PurchaseItems(customerdata[index]['items']);
                          }));
                        },
                      ),
                      Divider(
                        color: Colors.blue,
                        thickness: 1,
                      )
                    ],
                  ),
                  background: Container(
                    color: Colors.red,
                    child: Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  confirmDismiss: (direction) {
                    return showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                                title: Text('Are you sure?'),
                                content: Text(
                                  'Do you want to remove the Purchase Order?',
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('No'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(false);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Yes'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop(true);
                                      Firestore.instance
                                          .collection('purchase')
                                          .document(
                                              customerdata[index].documentID)
                                          .delete();
                                    },
                                  )
                                ]));
                  });
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (ctx) {
              return PurchaseItems(
                {},
              );
            }));
          }),
    );
  }
}
