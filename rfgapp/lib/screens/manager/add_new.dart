import 'package:flutter/material.dart';
import 'package:rfgapp/screens/manager/addtoprogram/customers.dart';
import 'package:rfgapp/screens/manager/addtoprogram/employee.dart';
import 'package:rfgapp/screens/manager/addtoprogram/items.dart';


enum FilterOptions {
  Customer,
  Item,
  Employee,
}

class Accountant extends StatefulWidget {
  static const routeName = '/AddNew';
  @override
  _AccountantState createState() => _AccountantState();
}

class _AccountantState extends State<Accountant> {
  int index = 0;
  List<dynamic> _screens = [AddCustomer(), AddItem(), AddEmployee()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(index  == 0 ? 'New Customer' : index == 1 ? 'New Item' : 'New Employee' ),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Customer) {
                  index = 0;
                } else if (selectedValue == FilterOptions.Item) {
                  index = 1;
                } else {
                  index = 2;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Add Customer'),
                value: FilterOptions.Customer,
              ),
              PopupMenuItem(
                child: Text('Add Item'),
                value: FilterOptions.Item,
              ),
              PopupMenuItem(
                child: Text('Add Employee'),
                value: FilterOptions.Employee,
              ),
            ],
          ),
        ],
      ),
      body: _screens[index],
     
    );
  }
}
