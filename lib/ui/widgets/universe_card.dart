import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_svg/flutter_svg.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/universes_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/universes_listener_bloc.dart';
import 'package:little_drops_of_rain_flutter/data/entities/universe.dart';
import 'package:little_drops_of_rain_flutter/extensions/build_context_extensions.dart';
import 'package:little_drops_of_rain_flutter/extensions/color_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/dialogs.dart';
import 'package:little_drops_of_rain_flutter/helpers/logged_user.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/interfaces/card_actions_callbacks.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/element_card.dart';

class UniverseCard extends StatefulWidget implements ElementCard {
  const UniverseCard(this.universe, {Key? key, this.cardActionsCallbacks})
      : super(key: key);

  final Universe universe;
  final CardActionsCallbacks<Universe>? cardActionsCallbacks;

  @override
  _UniverseCardState createState() => _UniverseCardState();
}

class _UniverseCardState extends State<UniverseCard> {
  late Color _cardColor;
  late int _numberOfProducts = 0;
  late int _numberOfPublishedProducts = 0;
  late int _numberOfUnpublishedProducts = 0;

  @override
  void initState() {
    super.initState();
    widget.universe.getNumberOfProducts().then((value) => setState(() {
          _numberOfProducts = value;
        }));
    _numberOfPublishedProducts = widget.universe.getNumberOfPublishedProducts();
    _numberOfUnpublishedProducts = widget.universe.getNumberOfUnpublishedProducts();
    _cardColor = widget.universe.getColorObject();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: Card(
        color: _cardColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getCardColorProduct(),
            const SizedBox(width: 10, height: double.infinity),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _getUniverseNameText(),
                const SizedBox(
                    height: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
                _getNumberOfProductsText(),
                const SizedBox(
                    height: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
                _getNumberOfPublishedProductsText(),
                const SizedBox(
                    height: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
                _getNumberOfUnpublishedProductsText(),
                const SizedBox(
                    height: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
                _getEditWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Product _getCardColorProduct() {
    return Product(
      tag:
          '${Constants.DEFAULT_UNIVERSE_COLOR_CONTAINER_TAG}_${widget.universe.name.toUpperCase()}',
      child: Container(
        key: UniqueKey(),
        color: widget.universe.getColorObject(),
        width: Constants.DEFAULT_CARD_COLOR_SQUARE_WIDTH,
        height: Constants.DEFAULT_CARD_COLOR_SQUARE_HEIGHT,
      ),
    );
  }

  Text _getUniverseNameText() {
    return Text(
      widget.universe.name,
      style:
          TextStyle(color: _cardColor.isDark() ? Colors.white : Colors.black),
    );
  }

  Text _getNumberOfProductsText() {
    return Text(
      '${AppLocalizations.of(context).numberOfProducts}: $_numberOfProducts',
      overflow: TextOverflow.ellipsis,
      style:
          TextStyle(color: _cardColor.isDark() ? Colors.white : Colors.black),
    );
  }

  Text _getNumberOfPublishedProductsText() {
    return Text(
      '${AppLocalizations.of(context).published}: $_numberOfPublishedProducts',
      overflow: TextOverflow.ellipsis,
      style:
          TextStyle(color: _cardColor.isDark() ? Colors.white : Colors.black),
    );
  }

  Text _getNumberOfUnpublishedProductsText() {
    return Text(
      '${AppLocalizations.of(context).unpublished}: $_numberOfUnpublishedProducts',
      overflow: TextOverflow.ellipsis,
      style:
          TextStyle(color: _cardColor.isDark() ? Colors.white : Colors.black),
    );
  }

  Widget _getEditWidget() {
    return _isMyUniverse()
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
                SizedBox(
                    width: (MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.width /
                                    Constants.DEFAULT_CARD_WIDTH)
                                .round()) -
                        150,
                    height: 1),
                InkWell(
                  onTap: () async {
                    widget.cardActionsCallbacks?.onEdit(widget.universe);
                    await Navigator.of(context).pushNamed(
                        Routes.getParameterizedRouteForEditUniverse(
                            widget.universe));
                  },
                  child: SvgPicture.asset(
                      'assets/images/font_awesome/solid/edit.svg',
                      color: _cardColor.isDark() ? Colors.white : Colors.black,
                      placeholderBuilder: (context) => const SizedBox(
                          width: Constants.DEFAULT_EDIT_ICON_WIDTH,
                          height: Constants.DEFAULT_EDIT_ICON_HEIGHT,
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: CircularProgressIndicator())),
                      width: Constants.DEFAULT_EDIT_ICON_WIDTH,
                      height: Constants.DEFAULT_EDIT_ICON_HEIGHT),
                ),
                const SizedBox(
                    width: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL, height: 1),
                InkWell(
                  onTap: () async {
                    widget.cardActionsCallbacks?.onDelete(widget.universe);
                    if (context.isCurrent(this)) {
                      final ret =
                          await Dialogs.showDeleteConfirmationDialog(context);
                      if (ret == Dialogs.DELETE_DIALOG_RET_CONFIRM &&
                          LoggedUser().hasUser()) {
                        if (mounted) {
                          BlocProvider.of<UniversesListenerBloc>(context).add(
                              CanDeleteUniverseEvent(
                                  widget.universe, LoggedUser().user!.uid!));
                        }
                      }
                    }
                  },
                  child: SvgPicture.asset(
                      'assets/images/font_awesome/solid/trash.svg',
                      color: _cardColor.isDark() ? Colors.white : Colors.black,
                      placeholderBuilder: (context) => const SizedBox(
                          width: Constants.DEFAULT_EDIT_ICON_WIDTH,
                          height: Constants.DEFAULT_EDIT_ICON_HEIGHT,
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: CircularProgressIndicator())),
                      width: Constants.DEFAULT_EDIT_ICON_WIDTH,
                      height: Constants.DEFAULT_EDIT_ICON_HEIGHT),
                ),
              ])
        : const SizedBox(width: 1, height: 1);
  }

  void _mouseEnter(bool hover) {
    setState(() {
      _cardColor = hover
          ? widget.universe
              .getColorObject()
              .withOpacity(Constants.DEFAULT_CARD_BK_IMAGE_ON_HOVER_OPACITY)
          : widget.universe.getColorObject();
    });
  }

  bool _isMyUniverse() {
    return LoggedUser().hasUser()
        ? widget.universe.userUID == LoggedUser().user!.uid
        : false;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Card for universe: ${widget.universe.name}. Additional info: ${super.toString(minLevel: minLevel)}.';
  }
}
