import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfgapp/screens/manager/balancescreens/balance_report_screen.dart';

import 'package:rfgapp/widgets/departments_profile.dart';

class Balance extends StatefulWidget {
  static const routeName = '/Balance';
  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  String selectedItem = '';

  List<String> _customerList = [''];
  TextEditingController _startDateCon = TextEditingController();
  TextEditingController _finalDateCon = TextEditingController();
  DateTime _firstDate;
  DateTime _finalDate;

  _getCustomers() async {
    await Firestore.instance
        .collection('customers')
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
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
    return Scaffold(
        appBar: AppBar(title: Text('Balance')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: DropdownButton<String>(
                  value: selectedItem,
                  items: _customerList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text('selectItem'),
                  onChanged: (String value) {
                    setState(() {
                      selectedItem = value;
                    });
                  }),
            ),
            Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.date_range),
                    onPressed: () {
                      _pickTimefirst();
                    }),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Start Date'),
                    controller: _startDateCon,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.date_range),
                    onPressed: () {
                      _pickTimefinal();
                    }),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Final Date'),
                    controller: _finalDateCon,
                  ),
                ),
              ],
            ),
            OutlineButton(
                color: Colors.blueAccent,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return BalanceReport(
                          selectedItem, _firstDate, _finalDate);
                    },
                  ));
                },
                child: Text('Get Report'))
          ],
        ));
  }

  _pickTimefirst() async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2099),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _firstDate = pickedDate;
        _startDateCon.text = DateFormat.yMd().format(pickedDate).toString();
      });
    });
  }

  _pickTimefinal() async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2099),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        _finalDate = pickedDate;
        _finalDateCon.text = DateFormat.yMd().format(pickedDate).toString();
      });
    });
  }
}
