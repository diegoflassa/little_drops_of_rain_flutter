import 'package:flutter/cupertino.dart';
import 'package:little_drops_of_rain_flutter/data/entities/user.dart';

class LoggedUser extends ChangeNotifier {
  factory LoggedUser() {
    return _instance;
  }

  LoggedUser._internal();

  User? _user;

  User? get user => _user;

  set user(User? value) {
    _user = value;
    notifyListeners();
  }

  static final LoggedUser _instance = LoggedUser._internal();

  bool hasUser() {
    return _user != null && _user!.uid!=null;
  }
}
