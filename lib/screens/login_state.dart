import 'package:flutter/material.dart';

class LoginState with ChangeNotifier {
  String _color = 'red';

  String get color => _color;

  void setColor(String newColor) {
    _color = newColor;
    notifyListeners();
  }
}
