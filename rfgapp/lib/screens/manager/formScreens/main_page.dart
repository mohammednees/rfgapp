import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rfgapp/screens/manager/formScreens/add_new_page.dart';
import 'package:rfgapp/screens/manager/payment/edit_payment.dart';
import 'package:rfgapp/screens/manager/payment/new_payment.dart';

class MainPage extends StatefulWidget {
  String paperType;

  MainPage(this.paperType);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime _firstDate = DateTime.now();
  DateTime _finalDate = DateTime.now();

  Widget build(BuildContext context) {
    Timestamp timestam =
        Timestamp.fromDate(DateTime.now().add(Duration(days: 1)));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paperType),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(widget.paperType)
            .where('createAt', isLessThan: timestam)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var customerdata = snapshot.data.documents;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('From:'),
                  IconButton(
                      icon: Icon(Icons.date_range),
                      onPressed: () {
                        _pickTimefirst();
                      }),
                  Text(DateFormat.yMd().format(_firstDate).toString()),
                  Text('To:'),
                  IconButton(
                      icon: Icon(Icons.date_range),
                      onPressed: () {
                        _pickTimefinal();
                      }),
                  Text(DateFormat.yMd().format(_finalDate).toString())
                ],
              ),
              Divider(
                color: Colors.blue,
                height: 1,
                thickness: 1,
              ),
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount:
                      customerdata.length == null ? 0 : customerdata.length,
                  itemBuilder: (context, index) {
                    Timestamp time = customerdata[index]['createAt'];
                    var date = DateTime.fromMicrosecondsSinceEpoch(
                        time.microsecondsSinceEpoch);

                    return Dismissible(
                        key: ValueKey(customerdata[index]),
                        child: Column(
                          children: <Widget>[
                            listStyle(index, customerdata),
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
                                        'Do you want to remove the Payment?',
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
                                                .collection(widget.paperType)
                                                .doc(customerdata[index]
                                                    .documentID)
                                                .delete();
                                          },
                                        )
                                      ]));
                        });
                  },
                ),
              )
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewPage(widget.paperType),
                ));
          }),
    );
  }

  Widget listStyle(int index, dynamic snapshot) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return EditPayment(
                snapshot[index]['paymentName'],
                snapshot[index]['items'], // map

                snapshot[index].documentID,
                snapshot[index]['imageurl'],
                snapshot[index]['paymentInfo'],
              );
            },
          )).then((value) {
            setState(() {});
          });
        },
        child: Container(
            width: double.infinity,
            height: 70,
            child: Row(
              //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.all(4),
                    width: screenWidth / 14,
                    height: 30,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey, width: 1),
                        borderRadius: BorderRadius.circular(3)),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text((index + 1).toString(), style: textStyle()),
                    ))),
                ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: snapshot[index]['imageurl'] == null
                        ? Image.asset(
                            'assets/image/app-icon2.jpg',
                            width: screenWidth / 6,
                            height: 90,
                            fit: BoxFit.fill,
                          )
                        : Image.network(
                            snapshot[index]['imageurl'],
                            fit: BoxFit.cover,
                            width: screenWidth / 6,
                            height: 90,
                          )),
                SizedBox(
                  width: 8,
                ),
                Container(
                  width: screenWidth / 5,
                  child: Text(snapshot[index]['Name'],
                      style: textStyle(), overflow: TextOverflow.ellipsis),
                ),
                VerticalDivider(
                  indent: 2,
                  endIndent: 2,
                  thickness: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                      width: screenWidth / 6,
                      child: Text(snapshot[index]['Total'].toString(),
                          style: textStyle(), overflow: TextOverflow.ellipsis)),
                ),
                VerticalDivider(
                  indent: 2,
                  endIndent: 2,
                  thickness: 1,
                  color: Colors.grey,
                ),
                Container(
                    width: screenWidth / 5,
                    child: Text(
                        DateFormat.yMd()
                            .format(DateTime.parse(snapshot[index]['createAt']
                                .toDate()
                                .toString()))
                            .toString(),
                        style: textStyle(),
                        overflow: TextOverflow.ellipsis)),
              ],
            )),
      ),
    );
  }

  TextStyle textStyle() {
    return TextStyle(
      fontSize: 14,
      color: Colors.blue,
    );
  }

  _pickTimefirst() async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2099),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _firstDate = pickedDate;
      });
    });
  }

  _pickTimefinal() async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2099),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        _finalDate = pickedDate;
      });
    });
  }
}
