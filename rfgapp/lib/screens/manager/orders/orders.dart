import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rfgapp/screens/manager/orders/new_order.dart';
import 'package:rfgapp/screens/manager/orders/new_order_items.dart';
import 'package:rfgapp/widgets/lists_widget.dart';

enum FilterOptions { Done, NotDone }

class Orders extends StatefulWidget {
  static const routeName = '/Orders';
  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  String isDone;
  Map<dynamic, dynamic> salary = {
    'Product': 10,
    'Product': 20,
    'ProductNew': 30,
  };

  @override
  void initState() {
    isDone = 'false';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Timestamp timestam =
        Timestamp.fromDate(DateTime.now().add(Duration(days: 1)));
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Done) {
                  isDone = 'true';
                } else if (selectedValue == FilterOptions.NotDone) {
                  isDone = 'false';
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
            ],
          ),
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('orders')
            .where('isDone', isEqualTo: isDone)
            .orderBy('createAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var orderData = snapshot.data.documents;
          print(orderData.length);
          return ListView.builder(
              itemCount: orderData.length == null ? 0 : orderData.length,
              itemBuilder: (ctx, index) {
                Timestamp time = orderData[index]['createAt'];
                var date = DateTime.fromMicrosecondsSinceEpoch(
                    time.microsecondsSinceEpoch);

                return Dismissible(
                    key: ValueKey(orderData[index]),
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
                                            .collection('orders')
                                            .document(
                                                orderData[index].documentID)
                                            .delete();
                                      },
                                    )
                                  ]));
                    },
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      child: ListWidget(
                        isPic: true,
                        index: index + 1,
                        name: orderData[index]['customerName'],
                        price: null,
                        qty: null,
                        total: orderData[index]['Total'],
                        imageurl: orderData[index]['imageurl'],
                        map: orderData[index]['items'],
                        info: orderData[index]['orderInfo'],
                        department: orderData[index]['department'],
                      ),
                    )

                    /*  ListTile(
                    leading: Text(index.toString()),
                    title: Text(orderData[index]['customerName']),
                    subtitle: Text(orderData[index]['Total'].toString() +
                        '  |  ' +
                        DateFormat.yMMMd().format(date)),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return AddNewOrder(orderData[index]['items']);
                        },
                      ));
                    },
                  ), */
                    );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              salary.putIfAbsent('dddd', () => 20);

              var values = salary.values;
              var result = values.reduce((sum, element) => sum + element);
              print(result);
              return AddNewOrder(
                customerName: '',
                department: '',
                info: '',
                map: {},
              );
            },
          )).then((value) {
            setState(() {});
          });
        },
      ),
    );
  }
}
