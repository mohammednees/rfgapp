import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:rfgapp/screens/manager/addtoprogram/edit_item.dart';

import 'package:rfgapp/screens/manager/addtoprogram/new_item.dart';

class AddItem extends StatefulWidget {
  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
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
            .collection('items')
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
                      listStyle(index, customerdata),
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
                                  'Do you want to remove the Item?',
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
                                          .collection('items')
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
                  return AddNewItem();
                });
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
              return EditItem(
                snapshot[index]['itemName'],
                snapshot[index]['ItemPrice'].toString(),
                snapshot[index]['priceMethod'],
                snapshot[index].documentID,
                snapshot[index]['itemImageUrl'],
                snapshot[index]['installPrice'].toString(),
                snapshot[index]['manufacturePrice'].toString(),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.all(2),
                    height: 30,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 1),
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text((index + 1).toString(), style: textStyle()),
                    ))),
                ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: snapshot[index]['itemImageUrl'] == null
                        ? Image.asset(
                            'assets/image/app-icon2.jpg',
                            width: screenWidth / 5,
                            height: 90,
                            fit: BoxFit.fill,
                          )
                        : Image.network(
                            snapshot[index]['itemImageUrl'],
                            fit: BoxFit.cover,
                            width: screenWidth / 5,
                            height: 90,
                          )),
                SizedBox(
                  width: 8,
                ),
                Container(
                  width: screenWidth / 5.5,
                  child: Text(
                    snapshot[index]['itemName'],
                    style: textStyle(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
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
                    width: screenWidth / 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            'P : ' +
                                snapshot[index]['ItemPrice'].toString() + " " +
                                snapshot[index]['priceMethod'].toString(),
                            style: textStyle(),
                            overflow: TextOverflow.ellipsis),
                        Text('I : ' + snapshot[index]['installPrice'].toString(),
                            style: textStyle(),
                            overflow: TextOverflow.ellipsis),
                        Text(
                            'M : ' +
                                snapshot[index]['manufacturePrice'].toString(),
                            style: textStyle(),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  TextStyle textStyle() {
    return TextStyle(
      fontSize: 12,
      color: Colors.blue,
    );
  }
}
