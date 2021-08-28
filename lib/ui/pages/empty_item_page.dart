import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/enums/element_type.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/routing/routing_data.dart';

class EmptyItemPage extends StatefulWidget {
  const EmptyItemPage(
      {Key? key,
      this.message,
      this.elementType = ElementType.UNKNOWN,
      this.routingData})
      : super(key: key);

  final String? message;
  final ElementType elementType;
  final RoutingData? routingData;

  @override
  _EmptyItemPageState createState() => _EmptyItemPageState();
}

class _EmptyItemPageState extends State<EmptyItemPage> {
  String _elementTypeMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_elementTypeMessage.isEmpty) {
      _elementTypeMessage = _getElementTypeMessage();
    }
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_elementTypeMessage),
          ],
        ),
      ),
    );
  }

  String _getElementTypeMessage() {
    String ret;
    switch (widget.elementType) {
      case ElementType.PRODUCT:
        var product = '';
        ret =
            '${AppLocalizations.of(context).noProductFound} : ${(product != null) ? product : AppLocalizations.of(context).unknown}';
        break;
      case ElementType.UNKNOWN:
        ret = AppLocalizations.of(context).noElement;
        break;
    }
    return ret;
  }
}
