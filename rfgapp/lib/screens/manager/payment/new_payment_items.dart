import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rfgapp/providers/variables.dart';

class AddNewPaymentItems extends StatefulWidget {
  AddNewPaymentItems(this.submitFn, this.mapitems);

  final Map<dynamic, dynamic> mapitems;

  final void Function(Map<dynamic, dynamic> map, double total) submitFn;

  @override
  _AddNewPaymentItemsState createState() => _AddNewPaymentItemsState();
}

class _AddNewPaymentItemsState extends State<AddNewPaymentItems> {
  final _formKey = GlobalKey<FormState>();

  String _customerName = '';
  double _total = 0;
  double _qty = 1;
  int _price = 0;
  bool _editmood = false;
  Map<dynamic, dynamic> _purchaseMap;

  void _trySubmit(BuildContext ctx) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(ctx).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      if (_editmood == false) {
        _purchaseMap = Provider.of<Variables>(context, listen: false).map;
      }

      if (_purchaseMap == null) {
        _purchaseMap = {};
      }
      _purchaseMap.putIfAbsent(
          _customerName, () => {'price': _price, 'qty': 1});

      _purchaseMap.forEach((key, value) {
        _total = _total + (value['price'] * value['qty']);
      });
      _purchaseMap =
          Provider.of<Variables>(context, listen: false).map = _purchaseMap;
      widget.submitFn(_purchaseMap, _total);

      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    _purchaseMap = widget.mapitems;
    if (_purchaseMap != null) {
      _editmood = true;
      print(_editmood);
    }
    super.initState();
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
                  labelText: 'payment Name ',
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
