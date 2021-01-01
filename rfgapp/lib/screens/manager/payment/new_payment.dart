import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rfgapp/imageselect/picgalerry.dart';
import 'package:rfgapp/providers/variables.dart';
import 'package:rfgapp/screens/manager/orders/new_order_items.dart';
import 'package:rfgapp/screens/manager/payment/new_payment_items.dart';

class AddNewPayment extends StatefulWidget {
  @override
  Map<dynamic, dynamic> map;

  AddNewPayment(this.map);
  _AddNewPaymentState createState() => _AddNewPaymentState();
}

class _AddNewPaymentState extends State<AddNewPayment> {
  String _customerName = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double _total;
  String selectedItemcustomer = '';
  List<String> _customerList = [''];
  String _txtInfo;
  void _formfunc(Map<dynamic, dynamic> map, double total) {
    setState(() {
      widget.map = map;
      _total = total;
    });
  }

  _getCustomers() async {
    await Firestore.instance
        .collection('customers')
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        _customerList.add(result['customerName']);
      });
    }).whenComplete(() {
      setState(() {});
    });
  }

  @override
  void initState() {
    _getCustomers();
    super.initState();
  }

  void _save(BuildContext ctx) async {
    var orderNo;
    await Firestore.instance
        .collection('payments')
        .getDocuments()
        .then((value) {
      orderNo = value.documents.length + 1;
    });

    try {
      await Firestore.instance.collection('payments').document().setData({
        'paymentName': selectedItemcustomer,
        'Total': _total,
        'createAt': DateTime.now(),
        'items': widget.map,
        'imageurl': Provider.of<Variables>(context, listen: false).iamgepath,
        'paymentInfo': _txtInfo,
        'paymentNo': orderNo,
      });
      ////////////////////////////////// go to add items for purchase order //////////////////////
      Provider.of<Variables>(context, listen: false).iamgepath = null;
      Provider.of<Variables>(context, listen: false).map = null;

      Navigator.pop(ctx);
    } on PlatformException catch (err) {
      var message = 'An error occurred, pelase check your credentials!';

      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (err) {
      print(err);
    }
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Please Check Name'),
      backgroundColor: Colors.blueGrey,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    var key;
    var value;
    print(widget.map.length);
    print(Provider.of<Variables>(context, listen: false).iamgepath);
    key = widget.map.keys.toList();
    value = widget.map.values.toList();

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Payment Items'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.picture_in_picture),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return GetPicFromGallery('payments');
                    },
                  ));
                }),
            IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  if (selectedItemcustomer == '') {
                    _displaySnackBar(context);
                  } else {
                    _save(context);
                  }
                }),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(8),
                  width: 100,
                  child: Container(
                    child: DropdownButton<String>(
                        value: selectedItemcustomer,
                        items: _customerList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        hint: Text('selectItem'),
                        onChanged: (String value) {
                          setState(() {
                            selectedItemcustomer = value;
                          });
                        }),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Information'),
                    onChanged: (value) {
                      _txtInfo = value;
                    },
                  ),
                ),
                Container(
                  height: 400,
                  child: ListView.builder(
                      itemCount:
                          widget.map.length == null ? 0 : widget.map.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                            key: ValueKey(key[index]),
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  leading: Text((index + 1).toString()),
                                  title: Text(key[index]),
                                  subtitle:
                                      Text(value[index]['price'].toString()),
                                  onTap: () {
                                    print(index);
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
                                            'Do you want to remove the Payment ?',
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

                                                widget.map.remove(key[index]);
                                              },
                                            )
                                          ]));
                            });
                      }),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                  context: (context),
                  builder: (ctx) {
                    return AddNewPaymentItems(_formfunc, null);
                  }).then((value) {
                setState(() {});
              });
            }));
  }
}
