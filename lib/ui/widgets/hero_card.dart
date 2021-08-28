import 'dart:typed_data';

// ignore: import_of_legacy_library_into_null_safe
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_svg/flutter_svg.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:intl/intl.dart';

import 'package:little_drops_of_rain_flutter/bloc/events/products_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/products_listener_bloc.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart' as my_app;
import 'package:little_drops_of_rain_flutter/extensions/build_context_extensions.dart';
import 'package:little_drops_of_rain_flutter/extensions/color_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/dialogs.dart';
import 'package:little_drops_of_rain_flutter/helpers/logged_user.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/interfaces/card_actions_callbacks.dart';
import 'package:little_drops_of_rain_flutter/real_main.dart';
import 'package:little_drops_of_rain_flutter/resources/resources.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_text_style.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/element_card.dart';

// ignore: import_of_legacy_library_into_null_safe
// import 'package:flutter_svg/flutter_svg.dart';

class ProductCard extends StatefulWidget implements ElementCard {
  const ProductCard(this.product,
      {Key? key, this.cardActionsCallbacks, this.compact = false})
      : super(key: key);

  final my_app.Product product;
  final bool compact;
  final CardActionsCallbacks<my_app.Product>? cardActionsCallbacks;

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String? _universeName;
  late Color _cardColor;
  bool _gettingFaceImage = false;
  bool _gotFaceImage = false;
  int _triesGetFaceImage = 0;
  int _gotDefaultFaceImageTriesCount = 0;
  Widget? _faceImage;

  @override
  void initState() {
    super.initState();

    _cardColor = widget.product.getColorObject();
    if (!widget.product.hasGotFaceImage()) {
      _faceImage = _getLoadingImagePlaceholder();
    }
    _getFaceImage();
    _getUniverse();
  }

  @override
  Widget build(BuildContext context) {
    _getFaceImage();
    if (_universeName == null) {
      _getUniverse();
    }
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
          child: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  _getCardFaceImageContainer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (!widget.compact)
                        const SizedBox(
                            height: Constants.DEFAULT_EDGE_INSETS_VERTICAL),
                      _getProductCodename(),
                      ..._getNotCompatListWidget(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getNotCompatListWidget() {
    final ret = <Widget>[];
    if (!widget.compact) {
      ret.add(
          const SizedBox(height: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF));
      ret.add(_getUniverseRow());
      ret.add(const Spacer());
      ret.add(_getViewsAndRating());
      ret.add(
          const SizedBox(height: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF));
      ret.add(_getEditWidget());
      ret.add(const SizedBox(height: Constants.DEFAULT_EDGE_INSETS_VERTICAL));
    }
    return ret;
  }

  void _mouseEnter(bool hover) {
    setState(() {
      _cardColor = hover
          ? widget.product
              .getColorObject()
              .withOpacity(Constants.DEFAULT_CARD_BK_IMAGE_ON_HOVER_OPACITY)
          : widget.product.getColorObject();
    });
  }

  SizedBox _getViewsAndRating() {
    return SizedBox(
      width: !widget.compact
          ? (MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.width / 350).round() -
              Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH -
              Constants.DEFAULT_EDGE_INSETS_ALL_HALF * 2 -
              Constants.DEFAULT_EDGE_INSETS_HORIZONTAL -
              2)
          : (MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.width / 350).round() -
              Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH_COMPAT -
              200 -
              Constants.DEFAULT_EDGE_INSETS_ALL_QUARTER * 2 -
              Constants.DEFAULT_EDGE_INSETS_HORIZONTAL -
              2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _getViewsText(),
          _getRatingWidget(),
        ],
      ),
    );
  }

  Widget _getEditWidget() {
    return _isMyProduct()
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
                SizedBox(
                    width: (MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.width /
                                    Constants.DEFAULT_CARD_WIDTH)
                                .round()) -
                        228,
                    height: 1),
                InkWell(
                  onTap: () async {
                    widget.cardActionsCallbacks?.onEdit(widget.product);
                    await Navigator.of(context).pushNamed(
                        Routes.getParameterizedRouteForEditProduct(widget.product));
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
                    widget.cardActionsCallbacks?.onDelete(widget.product);
                    if (context.isCurrent(this)) {
                      final ret =
                          await Dialogs.showDeleteConfirmationDialog(context);
                      if (ret == Dialogs.DELETE_DIALOG_RET_CONFIRM &&
                          LoggedUser().hasUser()) {
                        if (mounted) {
                          BlocProvider.of<ProductsListenerBloc>(context).add(
                              CanDeleteProductEvent(
                                  widget.product, LoggedUser().user!.uid!));
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

  Container _getCardFaceImageContainer() {
    return Container(
      margin: EdgeInsets.all(!widget.compact
          ? Constants.DEFAULT_EDGE_INSETS_ALL_HALF
          : Constants.DEFAULT_EDGE_INSETS_ALL_QUARTER),
      constraints: BoxConstraints(
        minWidth: !widget.compact
            ? Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH
            : Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH_COMPAT,
        minHeight: !widget.compact
            ? Constants.DEFAULT_CARD_FACE_IMAGE_HEIGHT
            : Constants.DEFAULT_CARD_FACE_IMAGE_HEIGHT_COMPAT,
        maxWidth: !widget.compact
            ? Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH
            : Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH_COMPAT,
        maxHeight: !widget.compact
            ? Constants.DEFAULT_CARD_FACE_IMAGE_HEIGHT
            : Constants.DEFAULT_CARD_FACE_IMAGE_HEIGHT_COMPAT,
      ),
      child: _faceImage,
    );
  }

  bool _isMyProduct() {
    if (LoggedUser().hasUser()) {
      return widget.product.userUID == LoggedUser().user!.uid;
    } else {
      return false;
    }
  }

  void _getUniverse() {
    if (widget.product.universe == null) {
      widget.product.getUniverse().then((value) => {
            if (value != null)
              {
                if (mounted)
                  {
                    setState(() {
                      _universeName = value.name;
                    })
                  }
              }
          });
    } else {
      setState(() {
        _universeName = widget.product.universe!.name;
      });
    }
  }

  Wrap _getProductCodename() {
    return Wrap(
      children: <Widget>[
        SizedBox(
          width: !widget.compact
              ? (MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.width / 350).round() -
                  Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH -
                  Constants.DEFAULT_EDGE_INSETS_ALL_HALF * 2 -
                  Constants.DEFAULT_EDGE_INSETS_HORIZONTAL -
                  2)
              : (MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.width / 350).round() -
                  Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH_COMPAT -
                  200 -
                  Constants.DEFAULT_EDGE_INSETS_ALL_QUARTER * 2 -
                  Constants.DEFAULT_EDGE_INSETS_HORIZONTAL -
                  2),
          child: AutoSizeText(
            widget.product.codename.toUpperCase(),
            minFontSize: Constants.DEFAULT_MIN_FONT_SIZE,
            maxLines: Constants.DEFAULT_MAX_LINES,
            style: MyTextStyle.productCodename(_cardColor),
          ),
        ),
      ],
    );
  }

  Row _getUniverseRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.width / 350).round() -
              Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH -
              Constants.DEFAULT_EDGE_INSETS_ALL_HALF * 2 -
              Constants.DEFAULT_EDGE_INSETS_HORIZONTAL -
              2,
          child: AutoSizeText(
            '${AppLocalizations.of(context).universe}: $_universeName',
            minFontSize: Constants.DEFAULT_MIN_FONT_SIZE,
            maxLines: Constants.DEFAULT_MAX_LINES,
            style: TextStyle(
                color: _cardColor.isDark() ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }

  SmoothStarRating _getRatingWidget() {
    return SmoothStarRating(
      rating: widget.product.getMediumGrade().ceil().toDouble(),
      isReadOnly: true,
      color: Colors.amber,
      borderColor: _cardColor.isDark() ? Colors.white : Colors.black,
      size: Constants.DEFAULT_STAR_SIZE,
      spacing: Constants.DEFAULT_STAR_SPACING,
      onRated: (rating) {},
    );
  }

  Text _getViewsText() {
    return Text(
      '${NumberFormat.compact(locale: MyApp.locale.toString()).format(widget.product.views).toString()} ${AppLocalizations.of(context).views}',
      style: TextStyle(
          fontFamily: Constants.DEFAULT_APP_FONT_FAMILY,
          color: _cardColor.isDark() ? Colors.white : Colors.black),
    );
  }

  Future<void> _getFaceImage() async {
    if (!_gotFaceImage &&
        !_gettingFaceImage &&
        _triesGetFaceImage < Constants.DEFAULT_GET_FACE_IMAGE_TRY_LIMIT) {
      _triesGetFaceImage++;
      _gettingFaceImage = true;
      if (widget.product.hasGotFaceImage()) {
        final bytes = await widget.product.getFaceImageBytes();
        await _setFaceImageAsBytes(bytes);
      } else if (widget.product.isGettingFaceImage()) {
        showLoadingImage();
        await widget.product.faceImageAsBytesFuture?.then((value) {
          _setFaceImageAsBytes(value);
          widget.product.faceImageAsBytesFuture = null;
        });
      } else {
        showLoadingImage();
        await widget.product.getFaceImage().then((value) {
          _setFaceImageAsBytes(value);
          widget.product.faceImageAsBytesFuture = null;
        });
      }
      _gettingFaceImage = false;
    }
  }

  void showLoadingImage() {
    setState(() {
      _faceImage = _getLoadingImagePlaceholder();
    });
  }

  SizedBox _getLoadingImagePlaceholder() {
    return SizedBox(
      width: !widget.compact
          ? Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH
          : Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH_COMPAT,
      height: !widget.compact
          ? Constants.DEFAULT_CARD_FACE_IMAGE_HEIGHT
          : Constants.DEFAULT_CARD_FACE_IMAGE_HEIGHT_COMPAT,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _setFaceImageAsBytes(Uint8List? bytes) async {
    final identifier = (await widget.product.getIdentifier()).toUpperCase();
    if (bytes != null && bytes.isNotEmpty) {
      _gotFaceImage = true;
      if (mounted) {
        setState(
          () {
            final image = Image.memory(
              bytes,
              gaplessPlayback: true,
              key: UniqueKey(),
              fit: BoxFit.cover,
              width: !widget.compact
                  ? Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH
                  : Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH_COMPAT,
              height: !widget.compact
                  ? Constants.DEFAULT_CARD_FACE_IMAGE_HEIGHT
                  : Constants.DEFAULT_CARD_FACE_IMAGE_HEIGHT_COMPAT,
            );
            _faceImage = Product(
                tag: '${Constants.DEFAULT_HERO_HERO_IMAGE_TAG}_$identifier',
                child: image);
            precacheImage(image.image, context);
          },
        );
      }
    } else {
      if (mounted) {
        _gotDefaultFaceImageTriesCount++;
        if (_gotDefaultFaceImageTriesCount >
            Constants.DEFAULT_GET_IMAGE_TRY_LIMIT) {
          _gotDefaultFaceImageTriesCount = 0;
          _gotFaceImage = true;
        }
        setState(() {
          final image = Image(
            gaplessPlayback: true,
            image: const AssetImage(Images.noFace),
            key: UniqueKey(),
            fit: BoxFit.cover,
            width: !widget.compact
                ? Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH
                : Constants.DEFAULT_CARD_FACE_IMAGE_WIDTH_COMPAT,
            height: !widget.compact
                ? Constants.DEFAULT_CARD_FACE_IMAGE_HEIGHT
                : Constants.DEFAULT_CARD_FACE_IMAGE_HEIGHT_COMPAT,
          );
          _faceImage = Product(
            tag: '${Constants.DEFAULT_HERO_HERO_IMAGE_TAG}_$identifier',
            child: image,
          );
          precacheImage(image.image, context);
        });
      }
    }
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Card for product: ${widget.product.codename}. Additional info: ${super.toString(minLevel: minLevel)}.';
  }
}
