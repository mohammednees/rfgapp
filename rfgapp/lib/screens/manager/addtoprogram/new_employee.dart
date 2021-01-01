
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddNewEmployee extends StatefulWidget {
  @override
  _AddNewEmployeeState createState() => _AddNewEmployeeState();
}

class _AddNewEmployeeState extends State<AddNewEmployee> {
  final _formKey = GlobalKey<FormState>();

  String _employeeName = '';
  int _phoneNumber = 0;
  int _salary = 0;
  int _hour;

  void _trySubmitemployee(BuildContext ctx) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(ctx).unfocus();

    if (isValid) {
      _formKey.currentState.save();

      try {
        await Firestore.instance.collection('employees').document().setData({
          'EmployeeName': _employeeName,
          'EmployeeSalary': _salary,
          'phoneNumber': _phoneNumber,
          'createAt': DateTime.now(),
          'EmployeeHour': _hour,
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
    print('ADD NEW EMPLOYEE');
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
                key: ValueKey('EmployeeName'),
                validator: (value) {
                  if (value.isEmpty || value.length < 4) {
                    return 'Name should be more that 4 char';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Employee Name',
                ),
                onSaved: (value) {
                  _employeeName = value;
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
              TextFormField(
                keyboardType: TextInputType.number,
                key: ValueKey('Salaryemp'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please check salary value';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Salary'),
                onSaved: (value) {
                  _salary = int.parse(value);
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                key: ValueKey('Hour'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please check Hour value';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Hour'),
                onSaved: (value) {
                  _hour = int.parse(value);
                },
              ),
              IconButton(
                  icon: Icon(
                    Icons.save,
                    color: Colors.blue,
                    size: 50,
                  ),
                  onPressed: () {
                    _trySubmitemployee(context);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
