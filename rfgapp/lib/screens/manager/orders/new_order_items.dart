import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rfgapp/providers/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewOrderItems extends StatefulWidget {
  AddNewOrderItems(this.submitFn, this.map);

  final void Function(Map<dynamic, dynamic> map, double total , double pricePer) submitFn;
  final Map<dynamic, dynamic> map;

  @override
  _AddNewOrderItemsState createState() => _AddNewOrderItemsState();
}

class _AddNewOrderItemsState extends State<AddNewOrderItems> {
  final _formKey = GlobalKey<FormState>();

  String _customerName = '';
  double _total = 0;
  double _qty = 0;
  double _price = 0;
  double _totalQty = 0;
  Map<dynamic, dynamic> _purchaseMap;
  List<String> _list = [''];
  List<String> _listItemType = [''];
  String selectedItem = '';
  String newItem = '';
  int index;
  var pricetype;
  TextEditingController _pricecont = TextEditingController();
  TextEditingController _lengthCont = TextEditingController();
  TextEditingController _widthCont = TextEditingController();
  TextEditingController _totalCon = TextEditingController();
  TextEditingController _qtyCont = TextEditingController();
  double length;
  double width;
  QuerySnapshot snap;
  Map<dynamic, dynamic> map = {};
  bool editmood;

  void _getValues() async {
    await Firestore.instance
        .collection('items')
        .getDocuments()
        .then((querySnapshot) {
      snap = querySnapshot;
      querySnapshot.documents.forEach((result) {
        map.putIfAbsent(result['itemName'], () => result['ItemPrice']);
        _list.add(result['itemName']);
        _listItemType.add(result['priceMethod']);
      });
    }).whenComplete(() {
      setState(() {
        _list.add('newItem');
      });
    });
  }

  @override
  void initState() {
    _purchaseMap = widget.map;

    if (_purchaseMap != null) {
      editmood = true;
    } else {
      editmood = false;
    }
    _getValues();
    _pricecont.text = '';
    _lengthCont.text = '';
    _widthCont.text = '';
    _totalCon.text = '';

    // TODO: implement initState
    super.initState();
  }

  void _trySubmit(BuildContext ctx) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(ctx).unfocus();

    if (isValid) {
      _formKey.currentState.save();

      if (editmood == false) {
        _purchaseMap = Provider.of<Variables>(context, listen: false).map;
      }

      if (_purchaseMap == null) {
        _purchaseMap = {};
      }
      if (newItem != 'newItem') {
        _customerName = selectedItem;
      }
      _purchaseMap.putIfAbsent(
          _customerName, () => {'price': _price, 'qty': _qty});

      _purchaseMap.forEach((key, value) {
        _total = _total + (value['price'] * value['qty']);
      });
      _purchaseMap =
          Provider.of<Variables>(context, listen: false).map = _purchaseMap;
      widget.submitFn(_purchaseMap, _total, _totalQty);
      print(_totalQty.toString());
      _totalQty = 0;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.only(
          topLeft: const Radius.circular(25.0),
          topRight: const Radius.circular(25.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if (newItem != 'newItem')
                DropdownButton<String>(
                  value: selectedItem,
                  items: _list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text('selectItem'),
                  onChanged: (String value) {
                    setState(() {
                      selectedItem = value;
                      _pricecont.text = map[value].toString();
                      index = _list.indexOf(selectedItem);
                      pricetype = _listItemType[index];
                      print(_listItemType[index]);

                      _lengthCont.text = '';
                      _widthCont.text = '';
                      _totalCon.text = '';
                      _qtyCont.text = '';
                      _customerName = '';
                      _total = 0;
                      _qty = 0;
                      _price = 0;
                      _totalQty = 0;
                      length = 0;
                      width = 0;

                      if (value == 'newItem') {
                        newItem = 'newItem';

                        _pricecont.text = '';
                      }
                    });
                  },
                ),
              if (newItem == 'newItem')
                TextFormField(
                  key: ValueKey('ItemName'),
                  validator: (value) {
                    if (value.isEmpty || value.length < 4) {
                      return 'Name should be more that 4 char';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Item Name ',
                  ),
                  onSaved: (value) {
                    _customerName = value;
                  },
                ),
              if (newItem != 'newItem')
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _pricecont,
                        keyboardType: TextInputType.number,
                        key: ValueKey('price'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter value';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Price ',
                        ),
                        onSaved: (value) {
                          _price = double.parse(value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _lengthCont,
                        keyboardType: TextInputType.number,
                        key: ValueKey('length'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter value';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Length(cm)',
                        ),
                        onChanged: (value) {
                          print('hereee');
                          length = double.parse(value) / 100;
                          double area;

                          if (pricetype == 'Price/M.L') {
                            setState(() {
                              _totalCon.text =
                                  ((map[selectedItem]) * length * _qty)
                                      .toString();
                            });
                          } else {
                            setState(() {
                              if (length * width < 0.3) {
                                area = 0.9;
                              }
                              _totalCon.text =
                                  ((map[selectedItem]) * area * _qty)
                                      .toString();
                            });
                          }
                        },
                        onSaved: (value) {
                          length = double.parse(value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    if (pricetype == 'Price/m2')
                      Expanded(
                        child: TextFormField(
                          controller: _widthCont,
                          keyboardType: TextInputType.number,
                          key: ValueKey('width'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter value';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              width = double.parse(value) / 100;
                              var area;

                              if (pricetype == 'Price/M.L') {
                                _totalCon.text =
                                    ((map[selectedItem]) * length * _qty)
                                        .toString();
                              } else {
                                if (length * width < 0.9) {
                                  area = 0.3;
                                }
                                _totalCon.text =
                                    ((map[selectedItem]) * area * _qty)
                                        .toString();
                              }
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Width(cm) ',
                          ),
                          onSaved: (value) {
                            width = double.parse(value);
                          },
                        ),
                      ),
                  ],
                ),
              if (newItem != 'newItem')
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        key: ValueKey('qty'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter value';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _qty = double.parse(value);
                          setState(() {
                            if (pricetype == 'Price/M.L') {
                              _totalCon.text =
                                  ((map[selectedItem]) * length * _qty)
                                      .toString();
                            } else {
                              _totalCon.text =
                                  ((map[selectedItem]) * length * width * _qty)
                                      .toString();
                            }
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Qty',
                        ),
                        controller: _qtyCont,
                        onSaved: (value) {
                          _qty = double.parse(value);
                        },
                      ),
                    ),
                    SizedBox(width: 3),
                    Expanded(
                      child: TextFormField(
                        controller: _totalCon,
                        keyboardType: TextInputType.number,
                        key: ValueKey('total'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter value';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Total',
                        ),
                        onSaved: (value) {
                          _totalQty = double.parse(value);
                        },
                      ),
                    ),
                  ],
                ),
              IconButton(
                  icon: Icon(
                    Icons.save,
                    color: Colors.blue,
                    size: 50,
                  ),
                  onPressed: () {
                    _trySubmit(context);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
