import 'package:flutter/material.dart';
import 'package:rfgapp/widgets/departments_profile.dart';

class DuctShop extends StatefulWidget {
  static const routeName = '/DuctShop';
  @override
  _DuctShopState createState() => _DuctShopState();
}

class _DuctShopState extends State<DuctShop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: DepartmentProfile('DuctShop'));
  }
}
