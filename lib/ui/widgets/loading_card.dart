import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/extensions/color_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/element_card.dart';

class LoadingCard extends StatefulWidget implements ElementCard {
  const LoadingCard({Key? key}) : super(key: key);

  @override
  _LoadingCard createState() => _LoadingCard();
}

class _LoadingCard extends State<LoadingCard> {
  late Color _cardColor;

  @override
  void initState() {
    super.initState();
    _cardColor = Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: _cardColor.isDark() ? Colors.white : Colors.black),
        ),
        child: Card(
          color: _cardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircularProgressIndicator(color: Colors.black),
              Text(AppLocalizations.of(context).loading),
            ],
          ),
        ),
      ),
    );
  }

  void _mouseEnter(bool hover) {
    setState(() {
      _cardColor = hover
          ? Colors.white
              .withOpacity(Constants.DEFAULT_CARD_BK_IMAGE_ON_HOVER_OPACITY)
          : Colors.white;
    });
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Loading Card. Additional info: ${super.toString(minLevel: minLevel)}.';
  }
}
