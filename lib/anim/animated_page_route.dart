import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/enums/transition_type.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/real_main.dart';

class AnimatedPageRoute<T> extends MaterialPageRoute<T> {
  AnimatedPageRoute(
      {required WidgetBuilder builder,
      required RouteSettings settings,
      bool maintainState = true})
      : super(
            builder: builder, settings: settings, maintainState: maintainState);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    Widget ret = const SizedBox();
    final transitionType = Helper.pageTransitionTypeStringToEnum(
        MyApp.getSharedPreferences()
            .getString(Constants.PREFS_PAGE_TRANSITION_TYPE));
    if (settings.name == '/') {
      ret = child;
    }
    switch (transitionType) {
      case TransitionType.FADE:
        ret = FadeTransition(opacity: animation, child: child);
        break;
      case TransitionType.SLIDE:
        ret = SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
        break;
      case TransitionType.SCALE:
        ret = ScaleTransition(
          scale: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        );
        break;
      case TransitionType.ROTATION:
        ret = RotationTransition(
          turns: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.linear,
            ),
          ),
          child: child,
        );
        break;
      case TransitionType.SIZE:
        ret = Align(
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );
        break;
      case TransitionType.HERO:
        ret = child;
        break;
    }
    return ret;
  }
}
