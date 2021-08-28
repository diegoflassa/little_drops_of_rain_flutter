import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:quiver/async.dart';

class EmptyItemsPage extends StatefulWidget {
  const EmptyItemsPage({Key? key, this.countDownMessage, this.secondsToGo = 0})
      : super(key: key);

  final String? countDownMessage;
  final int secondsToGo;

  @override
  _EmptyItemsPageState createState() => _EmptyItemsPageState();
}

class _EmptyItemsPageState extends State<EmptyItemsPage> {
  int _current = 0;

  @override
  void initState() {
    super.initState();
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
      sub.onDone(sub.cancel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context).emptyItems),
            if (widget.countDownMessage != null)
              Text('${widget.countDownMessage!}: $_current')
            else
              const Text(''),
          ],
        ),
      ),
    );
  }
}
