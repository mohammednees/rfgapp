import 'package:cloud_firestore/cloud_firestore.dart';

class BalanceItem {
  String info;
  Timestamp createAt;
  double total;
  Map<dynamic, dynamic> orderItems;
  int orderNo;

  BalanceItem(
      {this.orderNo, this.createAt, this.total, this.orderItems, this.info});

}
