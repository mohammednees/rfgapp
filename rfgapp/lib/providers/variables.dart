import 'dart:io';

import 'package:flutter/cupertino.dart';

class Variables with ChangeNotifier {
  String screenNameE;
  String _userIdName;
  String _phomeNumber;
  File picName;
  String _imagepathe;
  String _mode;
  bool _waitdata;
  Map<dynamic, dynamic> _map;
  double _total;
  String _selected;

  Variables({this.screenNameE, this.picName});
  double get total => _total;
  Map<dynamic, dynamic> get map => _map;
  String get screenName => screenNameE;
  String get userIdName => _userIdName;
  String get phoneNumber => _phomeNumber;
  String get mode => _mode;
  String get selected => _selected;
  bool get wait => _waitdata;
  String get iamgepath => _imagepathe;

  set wait(bool val) {
    this._waitdata = val;
    notifyListeners();
  }

  set userIdName(String val) {
    this._userIdName = val;
  }

  set selected(String val) {
    this._selected = val;
  }

  set phoneNumber(String val) {
    this._phomeNumber = val;
  }

  set mode(String val) {
    this._mode = val;
  }

  set map(Map<dynamic, dynamic> value) {
    _map = value;
  }

  set total(double value) {
    _total = value;
  }

  void changeScreen(String val) {
    screenNameE = val;

    notifyListeners();
  }

  set iamgepath(val) {
    _imagepathe = val;
  }

  Future<void> storepath(String path) {
    _imagepathe = path;

    // notifyListeners();
  }
}
