import 'package:flutter/material.dart';

class TextEditingControllerWorkaround extends TextEditingController {
  TextEditingControllerWorkaround({String? text}) : super(text: text);

  void setTextAndPosition(String newText, {int? caretPosition}) {
    int offset;
    if (caretPosition != null) {
      offset = caretPosition;
    } else {
      offset = newText.length;
    }
    value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: offset),
        composing: TextRange.empty);
  }
}
