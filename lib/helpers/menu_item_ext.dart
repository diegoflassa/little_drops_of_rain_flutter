import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:popup_menu/popup_menu.dart';

class MenuItemExt extends MenuItem {
  MenuItemExt(
      {String title = '',
      Widget image = const SizedBox(),
      dynamic userInfo,
      TextStyle textStyle = const TextStyle(),
      this.value})
      : super(
            title: title,
            image: image,
            userInfo: userInfo,
            textStyle: textStyle);
  final String? value;
}
