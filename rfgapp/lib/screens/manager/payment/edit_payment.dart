import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rfgapp/imageselect/picgalerry.dart';
import 'package:rfgapp/providers/variables.dart';
import 'package:rfgapp/screens/manager/payment/new_payment_items.dart';

class EditPayment extends StatefulWidget {
  final String name;
  Map<dynamic, dynamic> map;

  final String ind;
  final String imageUrl;
  final String info;
  EditPayment(this.name, this.map, this.ind, this.imageUrl, this.info);
  @override
  _EditPaymentState createState() => _EditPaymentState();
}

class _EditPaymentState extends State<EditPayment> {
  String _customerName;
  String selectedValue = '';
  List<String> _customerList = [''];
  String _info;
  String _image;
  double _total = 0;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _infoController = TextEditingController();
  void _formfunc(Map<dynamic, dynamic> map, double total) {
    setState(() {
      widget.map = map;
      _total = total;
    });
  }

  final _formKey = GlobalKey<FormState>();
  _getCustomers() async {
    await Firestore.instance
        .collection('customers')
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        _customerList.add(result['customerName']);
      });
    }).whenComplete(() {
      setState(() {
        _customerList.add('new');
      });
    });
  }

  @override
  void initState() {
    _getCustomers();

    _nameController.text = widget.name;
    _infoController.text = widget.info;
    selectedValue = widget.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var key;
    var value;
    print(widget.map.length);
    print(Provider.of<Variables>(context, listen: false).iamgepath);
    key = widget.map.keys.toList();
    value = widget.map.values.toList();

    var x = Provider.of<Variables>(context, listen: false).iamgepath;

    if (x == null) {
      _image = widget.imageUrl == null ? null : widget.imageUrl;
    } else {
      _image = x;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Payment'),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.image,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                  return GetPicFromGallery('payments');
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
                _total = 0;
                widget.map.forEach((key, value) {
                  _total = _total + (value['price'] * value['qty']);
                });
                final isValid = _formKey.currentState.validate();
                FocusScope.of(context).unfocus();
                if (isValid) {
                  _formKey.currentState.save();
                  await Firestore.instance
                      .collection('payments')
                      .document(widget.ind)
                      .updateData({
                    'paymentName': selectedValue,
                    'paymentInfo': _info,
                    'imageurl': _image,
                    'items': widget.map,
                    'Total': _total
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
                DropdownButton<String>(
                  value: selectedValue,
                  items: _customerList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _infoController,
                        decoration: InputDecoration(labelText: 'Info'),
                        onSaved: (newValue) {
                          _info = newValue;
                        },
                        validator: (value) {
                          if (value.length < 4) {
                            return 'Wrong / Short Name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                  ],
                ),
                Container(
                  height: 300,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: (context),
              builder: (ctx) {
                return AddNewPaymentItems(_formfunc, widget.map);
              }).then((value) {
            setState(() {});
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
