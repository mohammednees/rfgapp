import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rfgapp/providers/variables.dart';

class AddNewPurchaseItems extends StatefulWidget {
  @override
  _AddNewPurchaseItemsState createState() => _AddNewPurchaseItemsState();
}

class _AddNewPurchaseItemsState extends State<AddNewPurchaseItems> {
  final _formKey = GlobalKey<FormState>();
  String selectedItem = '';
  List<String> _customerList = [''];

  String _customerName = '';
  double _total = 0;
  double _qty = 0;
  int _price = 0;
  Map<String, dynamic> _purchaseMap = {};

  void _trySubmit(BuildContext ctx) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(ctx).unfocus();
    _purchaseMap = Provider.of<Variables>(context, listen: false).map;
    if (_purchaseMap == null) {
      _purchaseMap = {};
    }
    if (isValid) {
      _formKey.currentState.save();
      setState(() {
        _purchaseMap.putIfAbsent(
            _customerName, () => {'price': _price, 'qty': _qty});

        _purchaseMap.forEach((key, value) {
          _total = _total + (value['price'] * value['qty']);
        });
      });

      Provider.of<Variables>(context, listen: false).map = _purchaseMap;
      Provider.of<Variables>(context, listen: false).total = _total;
      Provider.of<Variables>(context, listen: false).selected = selectedItem;

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
              TextFormField(
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
                  _price = int.parse(value);
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                key: ValueKey('qty'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter value';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Qty',
                ),
                onSaved: (value) {
                  _qty = double.parse(value);
                },
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
