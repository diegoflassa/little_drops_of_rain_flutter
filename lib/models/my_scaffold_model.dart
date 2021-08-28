import 'package:flutter/material.dart';

class MyScaffoldModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  bool _isConnected = true;

  set isConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }

  bool get isConnected => _isConnected;

  void clear() {
    _isConnected = true;
    notifyListeners();
  }
}
