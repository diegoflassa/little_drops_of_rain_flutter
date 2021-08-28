import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  bool isCurrent(State state) {
    var ret = false;
    if (state.mounted) {
      ret = ModalRoute.of(this)!.isCurrent;
    }
    return ret;
  }
}
