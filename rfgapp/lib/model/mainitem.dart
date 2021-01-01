import 'package:cloud_firestore/cloud_firestore.dart';

class MainItemOrder {
  Timestamp createAt;
  int orderNo;
  String name;
  double qty;
  double total;
  String notification;
  Map<dynamic, dynamic> items;

  MainItemOrder(
      {this.createAt,
      this.name,
      this.orderNo,
      this.items,
      this.total,
      this.notification,
      this.qty});
}
