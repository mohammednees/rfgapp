
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:rfgapp/imageselect/picgalerry.dart';
import 'package:rfgapp/providers/variables.dart';

class AddNewItem extends StatefulWidget {
  @override
  _AddNewItemState createState() => _AddNewItemState();
}

class _AddNewItemState extends State<AddNewItem> {
  final _formKey = GlobalKey<FormState>();

  String _customerName = '';
  int _price = 0;
  String _imageUrl;
  int _itemQty = 0;
  String selectedMenu = '';
  int _installPrice;
  int _manufacPrice;
  void _trySubmitItem(BuildContext ctx) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(ctx).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      try {
        await Firestore.instance.collection('items').document().setData({
          'itemName': _customerName,
          'ItemPrice': _price,
          'itemImageUrl': _imageUrl,
          'itemQty': _itemQty,
          'createAt': DateTime.now(),
          'priceMethod': selectedMenu,
          'manufacturePrice': _manufacPrice,
          'installPrice': _installPrice
        });
        Provider.of<Variables>(context, listen: false).iamgepath = null;
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    _imageUrl = Provider.of<Variables>(context, listen: false).iamgepath;

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
              TextFormField(
                key: ValueKey('itemName'),
                validator: (value) {
                  if (value.isEmpty || value.length < 4) {
                    return 'Name should be more that 4 char';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Item Name',
                ),
                onSaved: (value) {
                  _customerName = value;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 200,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      key: ValueKey('itemPrice'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please check price value';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Price'),
                      onSaved: (value) {
                        _price = int.parse(value);
                      },
                    ),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedMenu,
                      items: <String>[
                        '',
                        'Price/m2',
                        'Price/M.L',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        setState(() {
                          selectedMenu = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      key: ValueKey('itemQty'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please check Qty value';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Qty'),
                      onSaved: (value) {
                        _itemQty = int.parse(value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      key: ValueKey('instalPrice'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please check  value';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'instalPrice'),
                      onSaved: (value) {
                        _installPrice = int.parse(value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      key: ValueKey('ManufacturePrice'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please check  value';
                        }
                        return null;
                      },
                      decoration:
                          InputDecoration(labelText: 'Manufacture Price'),
                      onSaved: (value) {
                        _manufacPrice = int.parse(value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                      icon: Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 50,
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (ctx) {
                          return GetPicFromGallery('items');
                        }));
                      }),
                  IconButton(
                      icon: Icon(
                        Icons.save,
                        color: Colors.blue,
                        size: 50,
                      ),
                      onPressed: () {
                        _trySubmitItem(context);
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
