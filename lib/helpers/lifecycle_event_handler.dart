import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  LifecycleEventHandler(
      {this.didPopRouteCallback,
      this.didHaveMemoryPressureCallback,
      this.didChangeTextScaleFactorCallback,
      this.didChangeMetricsCallback,
      this.didPushRouteCallback,
      this.pausedCallBack,
      this.inactiveCallBack,
      this.resumeCallBack,
      this.detachedCallBack});

  final void Function(bool)? didPopRouteCallback;
  final AsyncCallback? didHaveMemoryPressureCallback;
  final AsyncCallback? didChangeTextScaleFactorCallback;
  final AsyncCallback? didChangeMetricsCallback;
  final void Function(String, bool)? didPushRouteCallback;
  final AsyncCallback? pausedCallBack;
  final AsyncCallback? inactiveCallBack;
  final AsyncCallback? resumeCallBack;
  final AsyncCallback? detachedCallBack;

  @override
  Future<bool> didPopRoute() async {
    final ret = await super.didPopRoute();
    if (didPopRouteCallback != null) {
      didPopRouteCallback!(ret);
    }
    return ret;
  }

  @override
  void didHaveMemoryPressure() {
    if (didHaveMemoryPressureCallback != null) {
      didHaveMemoryPressureCallback!();
    }
    super.didHaveMemoryPressure();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        {
          if (pausedCallBack != null) {
            await pausedCallBack!();
          }
        }
        break;
      case AppLifecycleState.paused:
        {
          if (inactiveCallBack != null) {
            await inactiveCallBack!();
          }
        }
        break;
      case AppLifecycleState.detached:
        {
          if (detachedCallBack != null) {
            await detachedCallBack!();
          }
        }
        break;
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack!();
        }
        break;
    }
    MyLogger().logger.i('$state');
  }

  @override
  void didChangeTextScaleFactor() {
    if (didChangeTextScaleFactorCallback != null) {
      didChangeTextScaleFactorCallback!();
    }
    super.didChangeTextScaleFactor();
  }

  @override
  void didChangeMetrics() {
    if (didChangeMetricsCallback != null) {
      didChangeMetricsCallback!();
    }
    super.didChangeMetrics();
  }

  @override
  Future<bool> didPushRoute(String route) async {
    final ret = await super.didPushRoute(route);
    if (didPushRouteCallback != null) {
      didPushRouteCallback!(route, ret);
    }
    return ret;
  }
}
