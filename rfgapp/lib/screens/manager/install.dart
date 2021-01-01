import 'package:flutter/material.dart';
import 'package:rfgapp/widgets/departments_profile.dart';

class Install extends StatefulWidget {
  static const routeName = '/Install';
  @override
  _InstallState createState() => _InstallState();
}

class _InstallState extends State<Install> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
        body: DepartmentProfile('Install'));
  }
}
