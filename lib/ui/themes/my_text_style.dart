import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';

class MyTextStyle extends TextStyle {
  const MyTextStyle() : super(fontFamily: Constants.DEFAULT_APP_FONT_FAMILY);

  const MyTextStyle.black()
      : super(
          fontFamily: Constants.DEFAULT_APP_FONT_FAMILY,
          color: Colors.black,
        );

  const MyTextStyle.blackBold()
      : super(
          fontFamily: Constants.DEFAULT_APP_FONT_FAMILY,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        );

  const MyTextStyle.bold()
      : super(
          fontFamily: Constants.DEFAULT_APP_FONT_FAMILY,
          fontWeight: FontWeight.bold,
        );

  MyTextStyle.productCodename(Color color)
      : super(
          fontFamily: Constants.DEFAULT_HERO_CODENAME_CARD_FONT_FAMILY,
          color: (color.computeLuminance() < 0.5) ? Colors.white : Colors.black,
        );

  const MyTextStyle.tabText()
      : super(
          fontFamily: Constants.DEFAULT_APP_FONT_FAMILY,
          fontSize: 20,
          color: Colors.white,
        );

  const MyTextStyle.title()
      : super(
          fontFamily: Constants.DEFAULT_APP_FONT_FAMILY,
          fontSize: 20,
        );

  const MyTextStyle.link()
      : super(
          fontFamily: Constants.DEFAULT_APP_FONT_FAMILY,
          fontSize: 20,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        );

  const MyTextStyle.linkWoUnderline()
      : super(
          fontFamily: Constants.DEFAULT_APP_FONT_FAMILY,
          fontSize: 20,
          color: Colors.blue,
        );

  const MyTextStyle.blue()
      : super(
          fontFamily: Constants.DEFAULT_APP_FONT_FAMILY,
          color: Colors.blue,
        );

  const MyTextStyle.white()
      : super(
          fontFamily: Constants.DEFAULT_APP_FONT_FAMILY,
          color: Colors.white,
        );
}
