import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/resources/resources.dart';

class AppDrawerModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  bool _hasShownUserLoggedInMessage = false;

  set hasShownUserLoggedInMessage(bool value) {
    _hasShownUserLoggedInMessage = value;
    notifyListeners();
  }

  bool get hasShownUserLoggedInMessage => _hasShownUserLoggedInMessage;

  bool _isUserLogged = false;

  set isUserLogged(bool value) {
    _isUserLogged = value;
    notifyListeners();
  }

  bool get isUserLogged => _isUserLogged;

  IconButton? _imgUser;

  set imgUser(IconButton? value) {
    _imgUser = value;
    notifyListeners();
  }

  IconButton? get imgUser => _imgUser;

  String? _originalFilePath;

  set originalFilePath(String? value) {
    _originalFilePath = value;
    notifyListeners();
  }

  String? get originalFilePath => _originalFilePath;

  bool _gotImage = false;

  set gotImage(bool value) {
    _gotImage = value;
    notifyListeners();
  }

  bool get gotImage => _gotImage;

  bool _isGettingImage = false;

  set isGettingImage(bool value) {
    _isGettingImage = value;
    notifyListeners();
  }

  bool get isGettingImage => _isGettingImage;

  Widget _avatar = const Image(
      width: Constants.APP_DRAWER_AVATAR_DEFAULT_WIDTH,
      height: Constants.APP_DRAWER_AVATAR_DEFAULT_HEIGHT,
      image: AssetImage(Images.littleDropsOfRainIcon));

  set avatar(Widget value) {
    _avatar = value;
    notifyListeners();
  }

  Widget get avatar => _avatar;

  void clear() {
    _hasShownUserLoggedInMessage = false;
    _isUserLogged = false;
    _imgUser = null;
    _originalFilePath = null;
    _gotImage = false;
    _isGettingImage = false;
    _avatar = const Image(
        width: Constants.APP_DRAWER_AVATAR_DEFAULT_WIDTH,
        height: Constants.APP_DRAWER_AVATAR_DEFAULT_HEIGHT,
        image: AssetImage(Images.littleDropsOfRainIcon));
    notifyListeners();
  }
}
