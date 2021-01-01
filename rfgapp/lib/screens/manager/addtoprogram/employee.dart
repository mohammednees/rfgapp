


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rfgapp/screens/manager/addtoprogram/edit_employee.dart';
import 'package:rfgapp/screens/manager/addtoprogram/new_employee.dart';

class AddEmployee extends StatefulWidget {
  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Timestamp timestam =
        Timestamp.fromDate(DateTime.now().add(Duration(days: 1)));
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('employees')
            .where('createAt', isLessThan: timestam)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var employeedata = snapshot.data.documents;

          return ListView.builder(
            itemCount: employeedata.length == null ? 0 : employeedata.length,
            itemBuilder: (context, index) {
              Timestamp time = employeedata[index]['createAt'];
              var date = DateTime.fromMicrosecondsSinceEpoch(
                  time.microsecondsSinceEpoch);

              return Dismissible(
                  key: ValueKey(employeedata[index]),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Text((index + 1).toString()),
                        title: Text(employeedata[index]['EmployeeName'] +
                            '  |  ' +
                            DateFormat.yMMMd().format(date)),
                        subtitle: Text('Month : ' +
                            employeedata[index]['EmployeeSalary'].toString() +
                            '  |  ' +
                            'Hour : ' +
                            employeedata[index]['EmployeeHour'].toString() +
                            ' | ' +
                            employeedata[index]['phoneNumber'].toString()),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return EditEmployee(
                                  employeedata[index]['EmployeeName'],
                                  employeedata[index]['phoneNumber'].toString(),
                                  employeedata[index]['EmployeeSalary']
                                      .toString(),
                                  employeedata[index]['EmployeeHour']
                                      .toString(),
                                  employeedata[index].documentID.toString());
                            },
                          )).then((value) {
                            setState(() {});
                          });
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
                                  'Do you want to remove the Employee?',
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
                                          .collection('employees')
                                          .document(
                                              employeedata[index].documentID)
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
                  return AddNewEmployee();
                });
          }),
    );
  }
}
