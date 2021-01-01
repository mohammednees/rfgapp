
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditEmployee extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String ind;
  final String salary;
  final String hour;

  EditEmployee(this.name, this.phoneNumber, this.salary, this.hour, this.ind);
  @override
  _EditEmployeeState createState() => _EditEmployeeState();
}

class _EditEmployeeState extends State<EditEmployee> {
  String _emplyeeName;
  int _employeeNum;
  int _employeeSalary;
  int _employeehour;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _salaryController = TextEditingController();
  TextEditingController _hourController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _nameController.text = widget.name;
    _phoneController.text = widget.phoneNumber;
    _salaryController.text = widget.salary;
    _hourController.text = widget.hour;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Employee'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                final isValid = _formKey.currentState.validate();
                FocusScope.of(context).unfocus();
                if (isValid) {
                  _formKey.currentState.save();
                  await Firestore.instance
                      .collection('employees')
                      .document(widget.ind)
                      .updateData({
                    'EmployeeName': _emplyeeName,
                    'phoneNumber': _employeeNum,
                    'EmployeeSalary': _employeeSalary,
                    'EmployeeHour': _employeehour
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
                  _emplyeeName = newValue;
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
                  _employeeNum = int.parse(newValue);
                },
                validator: (value) {
                  if (value.length < 9) {
                    return 'Wrong / Short Number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Salary / Month'),
                onSaved: (newValue) {
                  _employeeSalary = int.parse(newValue);
                },
                validator: (value) {
                  if (value.length < 2) {
                    return 'Wrong / Short Number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hourController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Per Hour.'),
                onSaved: (newValue) {
                  _employeehour = int.parse(newValue);
                },
                validator: (value) {
                  if (value.length < 2) {
                    return 'Wrong / Short Number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
