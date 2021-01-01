import 'package:flutter/material.dart';
import 'package:rfgapp/widgets/departments_profile.dart';

class GrillShop extends StatefulWidget {

   static const routeName = '/GrillShop';
  @override
  _GrillShopState createState() => _GrillShopState();
}

class _GrillShopState extends State<GrillShop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
        body: DepartmentProfile('GrillShop'));
  
  }
}
