// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/go_back_widget.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:quiver/async.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage(
      {Key? key, this.exception, this.countDownMessage, this.secondsToGo = 0})
      : super(key: key);

  final dynamic exception;

  final String? countDownMessage;
  final int secondsToGo;

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  int _current = 0;
  static bool _timerSet = false;

  @override
  void initState() {
    super.initState();
  }

  void _setTimer() {
    if (!_timerSet) {
      _timerSet = true;
      if (widget.countDownMessage != null) {
        final countDownTimer = CountdownTimer(
            Duration(seconds: widget.secondsToGo), const Duration(seconds: 1));
        final sub = countDownTimer.listen(null);
        sub.onData((duration) {
          if (mounted) {
            setState(() {
              _current = widget.secondsToGo - duration.elapsed.inSeconds;
              _current = _current < 0 ? 0 : _current;
            });
          }
        });
        sub.onDone(() {
          _timerSet = false;
          sub.cancel();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _setTimer();
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(AppLocalizations.of(context).error),
            if (widget.exception != null)
              //_getErrorAsText(context)
              Text('')
            else
              const SizedBox(width: 1, height: 1),
            if (widget.countDownMessage != null)
              Text('${widget.countDownMessage!}: $_current')
            else
              const Text(''),
            const GoBackWidget(),
          ],
        ),
      ),
    );
  }
}
