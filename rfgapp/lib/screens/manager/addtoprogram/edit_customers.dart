import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditCustomer extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String ind;
  final String grade;
  EditCustomer(this.name, this.phoneNumber, this.ind, this.grade);
  @override
  _EditCustomerState createState() => _EditCustomerState();
}

class _EditCustomerState extends State<EditCustomer> {
  String _customerName;
  int _customerNum;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String selectedValue = 'C';
  List<String> _customerList = ['A', 'B', 'C'];

  @override
  void initState() {
    _nameController.text = widget.name;
    _phoneController.text = widget.phoneNumber;
    super.initState();
    selectedValue = widget.grade;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Customer'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                final isValid = _formKey.currentState.validate();
                FocusScope.of(context).unfocus();
                if (isValid) {
                  _formKey.currentState.save();
                  await FirebaseFirestore.instance
                      .collection('customers')
                      .doc(widget.ind)
                      .update({
                    'customerName': _customerName,
                    'phoneNumber': _customerNum,
                    "classify": selectedValue
                  }).then((value) {
                    Navigator.pop(context);
                  });
                }
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Customer Name'),
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
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Phone No.'),
                onSaved: (newValue) {
                  _customerNum = int.parse(newValue);
                },
                validator: (value) {
                  if (value.length < 9) {
                    return 'Wrong / Short Number';
                  }
                  return null;
                },
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Grade :   '),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
