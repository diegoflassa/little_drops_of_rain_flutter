import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_color_scheme.dart';

class MyButtonTheme extends ButtonThemeData {
  const MyButtonTheme(this.myColorScheme)
      : super(
          colorScheme: myColorScheme,
        );

  final MyColorScheme myColorScheme;
}
