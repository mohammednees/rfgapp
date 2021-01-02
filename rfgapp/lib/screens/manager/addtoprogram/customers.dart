import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rfgapp/screens/manager/addtoprogram/edit_customers.dart';
import 'package:rfgapp/screens/manager/addtoprogram/new_customer.dart';

class AddCustomer extends StatefulWidget {
  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Timestamp timestam =
        Timestamp.fromDate(DateTime.now().add(Duration(days: 1)));
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('customers')
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
                        leading: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            margin: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.blue)),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                (index + 1).toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          customerdata[index]['customerName'] +
                              "    |   Grade :  " +
                              customerdata[index]['classify'],
                          style: TextStyle(color: Colors.blue),
                        ),
                        subtitle: Text('Create At : ' +
                            DateFormat.yMMMd().format(date) +
                            '  | Phone No. : ' +
                            customerdata[index]['phoneNumber'].toString()),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return EditCustomer(
                                  customerdata[index]['customerName'],
                                  customerdata[index]['phoneNumber'].toString(),
                                  customerdata[index].documentID,
                                  customerdata[index]['classify']);
                            },
                          )).then((value) {
                            setState(() {});
                          });
                        },
                      ),
                      Divider(
                        color: Colors.blue,
                        thickness: 1,
                        height: 1,
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
                                  'Do you want to remove the Customer?',
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
                                      FirebaseFirestore.instance
                                          .collection('customers')
                                          .doc(customerdata[index].documentID)
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
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (ctx) {
                  return AddNewCustomer();
                });
          }),
    );
  }
}
