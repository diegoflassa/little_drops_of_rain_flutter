import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_svg/flutter_svg.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:intl/intl.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/stories_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/stories_listener_bloc.dart';
import 'package:little_drops_of_rain_flutter/data/entities/story.dart';
import 'package:little_drops_of_rain_flutter/extensions/build_context_extensions.dart';
import 'package:little_drops_of_rain_flutter/extensions/color_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/dialogs.dart';
import 'package:little_drops_of_rain_flutter/helpers/logged_user.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/interfaces/card_actions_callbacks.dart';
import 'package:little_drops_of_rain_flutter/real_main.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/element_card.dart';

class StoryCard extends StatefulWidget implements ElementCard {
  const StoryCard(this.story, {Key? key, this.cardActionsCallbacks})
      : super(key: key);

  final Story story;
  final CardActionsCallbacks<Story>? cardActionsCallbacks;

  @override
  _StoryCardState createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  late Color _cardColor;

  @override
  void initState() {
    super.initState();
    _cardColor = widget.story.getColorObject();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: Card(
        color: _cardColor,
        child: Row(
          children: <Widget>[
            _getCardColorProduct(),
            const SizedBox(width: 10, height: double.infinity),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.story.title,
                  style: TextStyle(
                      color: _cardColor.computeLuminance() < 0.5
                          ? Colors.white
                          : Colors.black),
                ),
                Text(
                  widget.story.getStoryAsString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: _cardColor.computeLuminance() < 0.5
                          ? Colors.white
                          : Colors.black),
                ),
                _getViewsRow(),
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

  Widget _getEditWidget() {
    return _isMyStory()
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
                    widget.cardActionsCallbacks?.onEdit(widget.story);
                    await Navigator.of(context).pushNamed(
                        Routes.getParameterizedRouteForEditStory(widget.story));
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
                    widget.cardActionsCallbacks?.onDelete(widget.story);
                    if (context.isCurrent(this)) {
                      final ret =
                          await Dialogs.showDeleteConfirmationDialog(context);
                      if (ret == Dialogs.DELETE_DIALOG_RET_CONFIRM &&
                          LoggedUser().hasUser()) {
                        if (mounted) {
                          BlocProvider.of<StoriesListenerBloc>(context).add(
                              CanDeleteStoryEvent(
                                  widget.story, LoggedUser().user!.uid!));
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

  Product _getCardColorProduct() {
    return Product(
      tag:
          '${Constants.DEFAULT_STORY_COLOR_CONTAINER_TAG}_${widget.story.title.toUpperCase()}',
      child: Container(
        key: UniqueKey(),
        color: widget.story.getColorObject(),
        width: Constants.DEFAULT_CARD_COLOR_SQUARE_WIDTH,
        height: Constants.DEFAULT_CARD_COLOR_SQUARE_HEIGHT,
      ),
    );
  }

  void _mouseEnter(bool hover) {
    setState(() {
      _cardColor = hover
          ? widget.story
              .getColorObject()
              .withOpacity(Constants.DEFAULT_CARD_BK_IMAGE_ON_HOVER_OPACITY)
          : widget.story.getColorObject();
    });
  }

  Row _getViewsRow() {
    return Row(
      children: <Widget>[
        Text(
          '${NumberFormat.compact(locale: MyApp.locale.toString()).format(widget.story.views).toString()} ${AppLocalizations.of(context).views}',
          style: TextStyle(
              fontFamily: Constants.DEFAULT_APP_FONT_FAMILY,
              color: _cardColor.isDark() ? Colors.white : Colors.black),
        ),
      ],
    );
  }

  bool _isMyStory() {
    return LoggedUser().hasUser()
        ? widget.story.userUID == LoggedUser().user!.uid
        : false;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Card for story: ${widget.story.title}. Additional info: ${super.toString(minLevel: minLevel)}.';
  }
}
