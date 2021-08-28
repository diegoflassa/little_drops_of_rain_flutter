import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/real_main.dart';

class OpenContainerWrapper<T> extends StatelessWidget {
  const OpenContainerWrapper({
    required this.openBuilder,
    required this.closedBuilder,
    required this.onClosed,
    required this.routeSettings,
    this.openColor = Colors.white,
    this.closedColor = Colors.white,
    Key? key,
  }) : super(key: key);

  final OpenContainerBuilder<T> openBuilder;
  final Color openColor;
  final CloseContainerBuilder closedBuilder;
  final Color closedColor;
  final ClosedCallback<T?> onClosed;
  final RouteSettings routeSettings;

  @override
  Widget build(BuildContext context) {
    var transitionTypeAsString = MyApp.getSharedPreferences()
        .getString(Constants.PREFS_CARD_TO_DETAILS_TRANSITION_TYPE);
    transitionTypeAsString = (transitionTypeAsString != null)
        ? transitionTypeAsString
        : Constants.DEFAULT_CARD_TO_DETAILS_TRANSITION_TYPE_VALUE;
    return OpenContainer<T>(
      transitionType:
          Helper.containerTransitionTypeStringToEnum(transitionTypeAsString),
      closedColor: closedColor,
      openColor: openColor,
      openBuilder: openBuilder,
      //tappable: false,
      onClosed: onClosed,
      closedBuilder: closedBuilder,
      routeSettings: routeSettings,
    );
  }
}
