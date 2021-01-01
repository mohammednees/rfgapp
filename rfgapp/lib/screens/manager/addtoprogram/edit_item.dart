
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rfgapp/imageselect/picgalerry.dart';
import 'package:rfgapp/providers/variables.dart';

class EditItem extends StatefulWidget {
  final String name;
  final String price;
  final String installprice;
  final String manufacprice;
  final String pricePer;
  final String ind;
  final String imageUrl;
  EditItem(this.name, this.price, this.pricePer, this.ind, this.imageUrl,
      this.installprice, this.manufacprice);
  @override
  _EditCustomerState createState() => _EditCustomerState();
}

class _EditCustomerState extends State<EditItem> {
  String _customerName;
  int _customerNum;
  int _installPrice;
  int _manufacturePrice;
  String priceper;
  String _image;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _installController = TextEditingController();
  TextEditingController _manufactureController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _nameController.text = widget.name;
    _phoneController.text = widget.price;
    _installController.text = widget.installprice;
    _manufactureController.text = widget.manufacprice;

    priceper = widget.pricePer;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var x = Provider.of<Variables>(context, listen: false).iamgepath;

    if (x == null) {
      _image = widget.imageUrl == null ? null : widget.imageUrl;
    } else {
      _image = x;
    }
    return  Scaffold(
        appBar: AppBar(
          title: Text('Edit Item'),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.image,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                    return GetPicFromGallery('items');
                  })).then((value) {
                    setState(() {
                      _image = Provider.of<Variables>(context, listen: false)
                          .iamgepath;
                    });
                  });
                }),
            IconButton(
                icon: Icon(Icons.save),
                onPressed: () async {
                  final isValid = _formKey.currentState.validate();
                  FocusScope.of(context).unfocus();
                  if (isValid) {
                    _formKey.currentState.save();
                    await Firestore.instance
                        .collection('items')
                        .document(widget.ind)
                        .updateData({
                      'itemName': _customerName,
                      'ItemPrice': _customerNum,
                      'priceMethod': priceper,
                      'itemImageUrl': _image,
                      'installPrice': _installPrice,
                      'manufacturePrice': _manufacturePrice
                    }).then((value) {
                      Provider.of<Variables>(context, listen: false).iamgepath =
                          null;
                      Navigator.pop(context);
                    });
                  }
                }),
          ],
        ),
        body: SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'item Name'),
                  onSaved: (newValue) {
                    _customerName = newValue;
                  },
                  validator: (value) {
                    if (value.length < 4) {
                      return 'Wrong / Short Name';
                    }
                    return null;
                  },
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Price'),
                        onSaved: (newValue) {
                          _customerNum = int.parse(newValue);
                        },
                        validator: (value) {
                          if (value.length < 2) {
                            return 'Wrong / Short Number';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _installController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Install Price'),
                        onSaved: (newValue) {
                          _installPrice = int.parse(newValue);
                        },
                        validator: (value) {
                          if (value.length < 1) {
                            return 'Wrong / Short Number';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _manufactureController,
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(labelText: 'Manufactring Price'),
                        onSaved: (newValue) {
                          _manufacturePrice = int.parse(newValue);
                        },
                        validator: (value) {
                          if (value.length < 1) {
                            return 'Wrong / Short Number';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    )
                  ],
                ),
                DropdownButton<String>(
                  value: priceper,
                  items: <String>[
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
                      priceper = value;
                    });
                  },
                ),
                Container(
                  width: 300,
                  height: 300,
                  child: _image == null
                      ? Image.asset('assets/image/app-icon2.jpg')
                      : Image.network(
                          _image,
                          fit: BoxFit.cover,
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
