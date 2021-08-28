import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_color_scheme.dart';

class MyAppBarTheme extends AppBarTheme {
  MyAppBarTheme(this.myColorScheme)
      : super(
          brightness: myColorScheme.brightness,
          color: myColorScheme.primary,
        );

  final MyColorScheme myColorScheme;
}
