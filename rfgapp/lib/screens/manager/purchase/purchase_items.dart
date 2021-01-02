import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rfgapp/providers/variables.dart';

import 'package:rfgapp/screens/manager/purchase/new_purchase_items.dart';

class PurchaseItems extends StatefulWidget {
  // final int id;
  Map<dynamic, dynamic> map;
  String name;
  String mode;
  String docID;
  PurchaseItems(this.map, this.name, this.mode, this.docID);
  @override
  _PurchaseItemsState createState() => _PurchaseItemsState();
}

class _PurchaseItemsState extends State<PurchaseItems> {
  String _sellerName = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedItem = '';
  List<String> _customerList = [''];

  TextEditingController _txtController = TextEditingController();

  void refresh() {
    setState(() {});
  }

  void _save(BuildContext ctx) async {
    if (widget.mode == 'new') {
      try {
        await FirebaseFirestore.instance.collection('purchase').doc().set({
          'sellerName': _sellerName,
          'Total': Provider.of<Variables>(ctx, listen: false).total,
          'createAt': DateTime.now(),
          'items': Provider.of<Variables>(ctx, listen: false).map,
        });
        ////////////////////////////////// go to add items for purchase order //////////////////////
        Provider.of<Variables>(context, listen: false).map = null;
        Provider.of<Variables>(context, listen: false).total = null;

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
    } else if (widget.mode == 'edit') {
      try {
        await FirebaseFirestore.instance
            .collection('purchase')
            .doc(widget.docID)
            .update({
          'sellerName': _sellerName,
          'Total': Provider.of<Variables>(ctx, listen: false).total,
          'createAt': DateTime.now(),
          'items': Provider.of<Variables>(ctx, listen: false).map,
        });
        ////////////////////////////////// go to add items for purchase order //////////////////////
        Provider.of<Variables>(context, listen: false).map = null;
        Provider.of<Variables>(context, listen: false).total = null;

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
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Please Check Name'),
      backgroundColor: Colors.blueGrey,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<bool> _getCustomers() async {
    await FirebaseFirestore.instance
        .collection('customers')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        if (!_customerList.contains(result['customerName'])) {
          _customerList.add(result['customerName']);
        }
      });
    }).whenComplete(() {
      if (!_customerList.contains('new')) {
        _customerList.add('new');

        if (!_customerList.contains(widget.name)) {
          _customerList.add(widget.name);
        }
      }
    });
    print(_customerList);
    return true;
  }

  @override
  void initState() {
    // _getCustomers();
    selectedItem = widget.name;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<Variables>(context, listen: false).map != null) {
      widget.map = Provider.of<Variables>(context, listen: false).map;
    }

    var key;
    var value;
    print(widget.map.length);
    key = widget.map.keys.toList();
    value = widget.map.values.toList();

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Purchase Items'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  if (_sellerName.isEmpty || _sellerName.length < 4) {
                    _displaySnackBar(context);
                  } else {
                    _save(context);
                  }
                })
          ],
        ),
        body: FutureBuilder(
            future: _getCustomers(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      if (selectedItem != 'new')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Seller Name :  ',
                              style: TextStyle(color: Colors.blue),
                            ),
                            DropdownButton<String>(
                                value: selectedItem,
                                items: _customerList
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                hint: Text('selectItem'),
                                onChanged: (String value) {
                                  setState(() {
                                    selectedItem = value;
                                    _sellerName = value;
                                  });
                                }),
                          ],
                        ),
                      if (selectedItem == 'new')
                        Container(
                          margin: EdgeInsets.all(8),
                          width: double.infinity,
                          height: 70,
                          child: TextField(
                            controller: _txtController,
                            decoration:
                                InputDecoration(labelText: 'SellerName'),
                            onChanged: (value) {
                              _sellerName = value;
                            },
                          ),
                        ),
                      Container(
                        height: 400,
                        child: ListView.builder(
                            itemCount: widget.map.length == null
                                ? 0
                                : widget.map.length,
                            itemBuilder: (context, index) {
                              return Dismissible(
                                  key: ValueKey(key[index]),
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        leading: Text((index + 1).toString()),
                                        title: Text(key[index]),
                                        subtitle: Text(
                                            value[index]['price'].toString() +
                                                ' X ' +
                                                value[index]['qty'].toString() +
                                                ' = ' +
                                                (value[index]['price'] *
                                                        value[index]['qty'])
                                                    .toString()),
                                        // onTap: () {
                                        //   print(index);
                                        // },
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
                                                  'Do you want to remove the Purchase item?',
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text('No'),
                                                    onPressed: () {
                                                      Navigator.of(ctx)
                                                          .pop(false);
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Text('Yes'),
                                                    onPressed: () {
                                                      Navigator.of(ctx)
                                                          .pop(true);

                                                      widget.map
                                                          .remove(key[index]);
                                                    },
                                                  )
                                                ]));
                                  });
                            }),
                      )
                    ],
                  ),
                );
              }
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: (context),
                  builder: (ctx) {
                    return AddNewPurchaseItems();
                  }).then((value) {
                setState(() {});
              });
            }));
  }
}
