import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rfgapp/widgets/departemnts_items.dart';

enum FilterOptions { Done, NotDone, Week, Month }

class DepartmentProfile extends StatefulWidget {
  final String department;

  DepartmentProfile(this.department);
  @override
  _DepartmentProfileState createState() => _DepartmentProfileState();
}

class _DepartmentProfileState extends State<DepartmentProfile> {
  String isDone;
  Timestamp timestam;

  @override
  void initState() {
    isDone = 'false';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.department),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Done) {
                  isDone = 'true';
                } else if (selectedValue == FilterOptions.NotDone) {
                  isDone = 'false';
                } else if (selectedValue == FilterOptions.Week) {
                  timestam =
                      Timestamp.fromDate(DateTime.now().subtract(Duration(days: 7)));
                    /*   print(Timestamp.fromDate(DateTime.now()).toString());
                       print( Timestamp.fromDate(DateTime.now().subtract(Duration(days: 7))).toString()); */
                } else if (selectedValue == FilterOptions.Month) {
                  timestam = Timestamp.fromDate(
                      DateTime.now().subtract(Duration(days: 30)));
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Orders Done'),
                value: FilterOptions.Done,
              ),
              PopupMenuItem(
                child: Text('Orders Not Done'),
                value: FilterOptions.NotDone,
              ),
              PopupMenuItem(
                child: Text('This Week'),
                value: FilterOptions.Week,
              ),
              PopupMenuItem(
                child: Text('This Month'),
                value: FilterOptions.Month,
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('orders')
            .where('department', isEqualTo: widget.department)
            .where('isDone', isEqualTo: isDone)
            .where('createAt', isGreaterThanOrEqualTo: timestam)
            .orderBy('createAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var departData = snapshot.data.documents;

          return ListView.builder(
              itemCount: departData.length == null ? 0 : departData.length,
              itemBuilder: (ctx, index) {
                Timestamp time = departData[index]['createAt'];
                var date = DateTime.fromMicrosecondsSinceEpoch(
                    time.microsecondsSinceEpoch);
                return Dismissible(
                    key: ValueKey(departData[index]),
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
                                    'Are you sure Order is Ready?',
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
                                            .collection('orders')
                                            .document(
                                                departData[index].documentID)
                                            .updateData({'isDone': 'true'});
                                      },
                                    )
                                  ]));
                    },
                    child: Container(
                        width: double.infinity,
                        height: 100,
                        child: ListTile(
                            onTap: () {

                              Navigator.push(context, MaterialPageRoute(builder:(context) {
                                return DepartmentItems(departData[index]['items']);
                              },));
                             



                            },
                            leading: Text('index'),
                            title: Text(
                              departData[index]['customerName'],
                            ),
                            subtitle: Text(
                              DateFormat.yMMMd().format(date) +
                                  '  |  ' +
                                  ' finish date',
                            ))));
              });
        },
      ),
    );
  }
}
