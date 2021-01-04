import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddNewPage extends StatefulWidget {
  final String paperType;
  AddNewPage(this.paperType);

  @override
  _AddNewPageState createState() => _AddNewPageState();
}

class _AddNewPageState extends State<AddNewPage> {
  String _name;
  double _qty;
  double _price;
  Map<dynamic, dynamic> mapitems = {};

  String selectedItem = '';
  final _formKey = GlobalKey<FormState>();

  List<String> _customerList = [''];

  _getCustomers() async {
    await FirebaseFirestore.instance
        .collection('customers')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
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

  @override
  Widget build(BuildContext context) {
    var key;
    var value;

    key = mapitems.keys.toList();
    value = mapitems.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('add New ' + widget.paperType),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Name :   '),
                      DropdownButton<String>(
                        value: selectedItem,
                        items: _customerList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String value) {
                          setState(() {
                            selectedItem = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.blue,
                  height: 1,
                  thickness: 1,
                ),
                Container(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: TextFormField(
                          key: ValueKey('Name'),
                          validator: (value) {
                            if (value.isEmpty || value.length < 3) {
                              return 'Name should be more that 3 char';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Name',
                          ),
                          onSaved: (value) {
                            _name = value;
                          },
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width / 5,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            key: ValueKey('qty'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please check';
                              }
                              return null;
                            },
                            decoration: InputDecoration(labelText: 'qty'),
                            onSaved: (value) {
                              _qty = double.parse(value);
                            },
                          )),
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          key: ValueKey('price'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please check';
                            }
                            return null;
                          },
                          decoration: InputDecoration(labelText: 'price'),
                          onSaved: (value) {
                            _price = double.parse(value);
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 400,
                  child: ListView.builder(
                      itemCount: mapitems.length == null ? 0 : mapitems.length,
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

                                                mapitems.remove(key[index]);
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
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          setState(() {
            final isValid = _formKey.currentState.validate();
            FocusScope.of(context).unfocus();

            if (isValid) {
              _formKey.currentState.save();
              mapitems.putIfAbsent(_name, () => {'price': _price, 'qty': 1});
            }
          });
        },
      ),
    );
  }
}
