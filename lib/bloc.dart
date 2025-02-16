// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';

class Stat with ChangeNotifier {
  String _stat = "";

  set setStat(String relayStatus) {
    _stat = relayStatus;
    notifyListeners();
  }

  String get getStat => _stat;
}

class IsSliderEnable with ChangeNotifier {
  bool _isEnable = false;

  set setStat(bool isEnable) {
    _isEnable = isEnable;
    notifyListeners();
  }

  bool get getStat => _isEnable;
}

class RadioValue with ChangeNotifier {
  Map<String, String> _radio = {"role": "اصلی", "type": "سوییچ"};

  set setStat(Map<String, String> radio) {
    radio.forEach((key, value) {
      _radio[key] = value;
    });
    notifyListeners();
  }

  Map<String, String> get getStat => _radio;
}

class NewConfigDevicesList with ChangeNotifier {
  List<String> _list = [];

  set setList(List<String> newList) {
    _list = newList;
    notifyListeners();
  }
  List<String> get getList => _list;
}