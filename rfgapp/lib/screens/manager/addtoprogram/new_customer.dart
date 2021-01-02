import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddNewCustomer extends StatefulWidget {
  @override
  _AddNewCustomerState createState() => _AddNewCustomerState();
}

class _AddNewCustomerState extends State<AddNewCustomer> {
  final _formKey = GlobalKey<FormState>();

  String _customerName = '';
  int _phoneNumber = 0;
  String selectedValue = 'C';
  List<String> _customerList = ['A', 'B', 'C'];

  void _trySubmit(BuildContext ctx) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(ctx).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      try {
        await FirebaseFirestore.instance.collection('customers').doc().set({
          'customerName': _customerName,
          'phoneNumber': _phoneNumber,
          'createAt': DateTime.now(),
          'classify': selectedValue,
        });

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
                key: ValueKey('CustomerName'),
                validator: (value) {
                  if (value.isEmpty || value.length < 4) {
                    return 'Name should be more that 4 char';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                ),
                onSaved: (value) {
                  _customerName = value;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                key: ValueKey('PhoneNumber'),
                validator: (value) {
                  if (value.isEmpty || value.length < 9) {
                    return 'Please check phone number';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Phone Number'),
                onSaved: (value) {
                  _phoneNumber = int.parse(value);
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
