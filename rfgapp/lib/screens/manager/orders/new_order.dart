import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rfgapp/imageselect/picgalerry.dart';
import 'package:rfgapp/providers/variables.dart';
import 'package:rfgapp/screens/manager/orders/new_order_items.dart';

class AddNewOrder extends StatefulWidget {
  @override
  Map<dynamic, dynamic> map;
  String info;
  String customerName;
  String department;
  String ind;

  AddNewOrder(
      {this.map, this.customerName, this.department, this.info, this.ind});
  _AddNewOrderState createState() => _AddNewOrderState();
}

class _AddNewOrderState extends State<AddNewOrder> {
  String _customerName = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double _total;
  String selectedDepartment = '';
  String selectedItemcustomer = '';
  List<String> _customerList = [''];
  String _txtInfo;
  bool editmood = false;
  double _pricePer;
  TextEditingController _infoCont = TextEditingController();

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
    _infoCont.text = widget.info;
    selectedDepartment = widget.department;
    selectedItemcustomer = widget.customerName;
    if (widget.map == {}) {
      editmood = false;
    } else {
      editmood = true;
    }
    _getCustomers();
    super.initState();
  }

  void _formfunc(Map<dynamic, dynamic> map, double total, double _totalQty) {
    setState(() {
      widget.map = map;
      _total = total;
      _pricePer = _totalQty;
    });
  }

  void _save(BuildContext ctx) async {
    var orderNo;
    await Firestore.instance.collection('orders').getDocuments().then((value) {
      orderNo = value.documents.length + 1;
    });
    print(orderNo.toString());

    try {
      await Firestore.instance.collection('orders').document().setData({
        'customerName': selectedItemcustomer,
        'Total': _total,
        'createAt': DateTime.now(),
        'items': widget.map,
        'imageurl': Provider.of<Variables>(context, listen: false).iamgepath,
        'isDone': 'false',
        'department': selectedDepartment,
        'orderNo': orderNo,
        'orderInfo': _txtInfo,
        'pricePer': _pricePer
      });
      ////////////////////////////////// go to add items for purchase order //////////////////////
      Provider.of<Variables>(context, listen: false).iamgepath = null;
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

  /* void _save(BuildContext ctx) async {

      print('SAVE');
    if (editmood) {
    
      await Firestore.instance
          .collection('orders')
          .document()
          .updateData({
        'customerName': selectedItemcustomer,
        'Total': _total,
        'items': widget.map,
        'imageurl': Provider.of<Variables>(context, listen: false).iamgepath,
        'department': selectedDepartment,
        'orderInfo': _txtInfo,
        'pricePer': _pricePer
      });
    } else {
      var orderNo;
      await Firestore.instance
          .collection('orders')
          .getDocuments()
          .then((value) {
        orderNo = value.documents.length + 1;
      });
      print(orderNo.toString());

      try {
        await Firestore.instance.collection('orders').document().setData({
          'customerName': selectedItemcustomer,
          'Total': _total,
          'createAt': DateTime.now(),
          'items': widget.map,
          'imageurl': Provider.of<Variables>(context, listen: false).iamgepath,
          'isDone': 'false',
          'department': selectedDepartment,
          'orderNo': orderNo,
          'orderInfo': _txtInfo,
          'pricePer': _pricePer
        });
        ////////////////////////////////// go to add items for purchase order //////////////////////
        Provider.of<Variables>(context, listen: false).iamgepath = null;
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
  } */

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
    key = widget.map.keys.toList();
    value = widget.map.values.toList();

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Order Items'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.picture_in_picture),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return GetPicFromGallery('orders');
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
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(8),
                width: double.infinity,
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 100,
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
                    Container(
                      width: 100,
                      child: DropdownButton<String>(
                        value: selectedDepartment,
                        items: <String>['', 'Install', 'DuctShop', 'GrillShop']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String value) {
                          setState(() {
                            selectedDepartment = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 400,
                child: TextField(
                  controller: _infoCont,
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
                                subtitle: Text(_pricePer.toString() +
                                    "  |  " +
                                    value[index]['qty'].toString()),
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
                                          'Do you want to remove the Order item?',
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: (context),
                  builder: (ctx) {
                    if (editmood) {
                      return AddNewOrderItems(_formfunc, widget.map);
                    } else {
                      return AddNewOrderItems(_formfunc, null);
                    }
                  }).then((value) {
                setState(() {});
              });
            }));
  }
}
