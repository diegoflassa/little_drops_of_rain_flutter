import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart' as my_app;
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/hand_cursor.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/products_auto_completer.dart';

class OverlaidProductSuggestions extends StatefulWidget {
  const OverlaidProductSuggestions(this.quillEditor, this.universeUid,
      {this.onSuggestionSelected, this.addHandCursor = false, Key? key})
      : super(key: key);

  final quill.QuillEditor quillEditor;
  final String? universeUid;
  final bool addHandCursor;
  final SuggestionSelectionCallback<my_app.Product>? onSuggestionSelected;

  @override
  _OverlaidProductSuggestionsState createState() =>
      _OverlaidProductSuggestionsState();
}

class _OverlaidProductSuggestionsState extends State<OverlaidProductSuggestions> {
  ProductsAutoCompleter? _productsAutoCompleter;
  late TextFieldConfiguration _productsAutoCompleterTextFieldConfiguration;
  final FocusNode _productsAutoCompleterFocusNode = FocusNode();
  OverlayEntry? _productSuggestionsOverlayEntry;
  MouseCursor _previousCursor = SystemMouseCursors.text;

  @override
  void initState() {
    super.initState();
    widget.quillEditor.focusNode.addListener(_onZefyrFocusChangedListener);
    _productsAutoCompleterFocusNode.addListener(_onZefyrFocusChangedListener);
    widget.quillEditor.controller.addListener(_controllerStoryListener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.quillEditor.focusNode.removeListener(_onZefyrFocusChangedListener);
    _productsAutoCompleterFocusNode.removeListener(_onZefyrFocusChangedListener);
  }

  @override
  Widget build(BuildContext context) {
    if (_productsAutoCompleter == null) {
      _productsAutoCompleterTextFieldConfiguration = TextFieldConfiguration(
          controller: ProductsAutoCompleter.typeAheadController,
          decoration:
              InputDecoration(labelText: AppLocalizations.of(context).products),
          focusNode: _productsAutoCompleterFocusNode);
      _productsAutoCompleter = ProductsAutoCompleter(_onSuggestionSelected,
          textFieldConfiguration: _productsAutoCompleterTextFieldConfiguration);
    }
    if (ProductsAutoCompleter.getUniverseUid() != widget.universeUid) {
      ProductsAutoCompleter.setUniverseUid(
        widget.universeUid,
      );
    }
    if (widget.addHandCursor) {
      return HandCursor(
          onMouseCursorChanged: _onMouseCursorChanged,
          child: widget.quillEditor);
    } else {
      return widget.quillEditor;
    }
  }

  void _onMouseCursorChanged(MouseCursor cursor) {
    if (_previousCursor != cursor) {
      _previousCursor = cursor;
      setState(() {});
    }
  }

  Future<bool> _showOverlaidProductSuggestions() async {
    if (widget.universeUid != null) {
      final text = widget.quillEditor.controller.document.toPlainText();
      final textSelection = widget.quillEditor.controller.selection;
      final textDy = text.substring(0, textSelection.base.offset);
      //final textDySplitted = textDy.split('\n');
      final textDx = _getTextDx(text, textSelection.base.offset);
      //ZefyrThemeData? theme = ZefyrTheme.of(context, nullOk: true);
      ThemeData? theme;
      final defaultStyle = DefaultTextStyle.of(context);
      final baseStyle = defaultStyle.style.copyWith(
        fontSize: 16,
        height: 1.3,
      );
      final painterDy = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          style: (theme != null) ? null : baseStyle,
          text: textDy,
        ),
      );
      painterDy.layout();
      final painterDx = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          style: (theme != null) ? null : baseStyle,
          text: textDx,
        ),
      );
      painterDx.layout();

      final overlayState = Overlay.of(context);
      final suggestionWidth = MediaQuery.of(context).size.width / 2;
      if (_productSuggestionsOverlayEntry != null) {
        if (_productSuggestionsOverlayEntry!.mounted) {
          _productSuggestionsOverlayEntry?.remove();
          _productSuggestionsOverlayEntry?.dispose();
        }
      }
      _productSuggestionsOverlayEntry = OverlayEntry(builder: (context) {
        return Positioned(
            // Decides where to place the products suggestions on the screens.
            top: widget.quillEditor.focusNode.offset.dy - 50, // +
            //(painterDy.height * textDySplitted.length) -
            //20,
            left: widget.quillEditor.focusNode.offset.dx + painterDx.width + 5,
            child: Material(
              elevation: 4,
              child: SizedBox(
                  width: suggestionWidth,
                  height: 40,
                  child: _productsAutoCompleter),
            ));
      });
      if (overlayState != null) {
        overlayState.insert(_productSuggestionsOverlayEntry!);
      } else {
        MyLogger().logger.e('Overlay state is null');
      }
    }
    return true;
  }

  void _onZefyrFocusChangedListener() {
    if (widget.quillEditor.focusNode.hasFocus) {
      setState(() {
        _productsAutoCompleter!.clear();
        _productSuggestionsOverlayEntry?.remove();
        _productSuggestionsOverlayEntry?.dispose();
      });
    }
  }

  String? _getTextDx(String? text, int? index) {
    var ret = text;
    if (text != null && index != null) {
      final matches = '\n'.allMatches(text);
      Match? startMatch;
      Match? endMatch;
      for (final match in matches) {
        if (match.end <= index) {
          startMatch = match;
        }
        if (endMatch == null && match.start >= index) {
          endMatch = match;
        }
      }
      final startIndex = (startMatch != null) ? startMatch.end : 0;
      final endIndex = (endMatch != null) ? endMatch.start : text.length;
      ret = text.substring(startIndex, endIndex);
    }
    return ret;
  }

  void _controllerStoryListener() {
    final text = widget.quillEditor.controller.document.toPlainText();
    final textSelection = widget.quillEditor.controller.selection;
    if (textSelection.base.offset > 0) {
      final subText = text.substring(
          textSelection.base.offset - 1, textSelection.base.offset);
      if (subText.contains('@')) {
        setState(() {
          _showOverlaidProductSuggestions();
          _productsAutoCompleterFocusNode.requestFocus();
        });
      }
    }
  }

  void _onSuggestionSelected(my_app.Product suggestion) {
    if (suggestion.uid != null) {
      setState(() {
        final textSelection = widget.quillEditor.controller.selection;
        final suggestionLength = suggestion.toString().length;
        widget.quillEditor.controller.document
            .insert(textSelection.base.offset.toInt(), suggestion.toString());
        widget.quillEditor.controller.document.format(
            textSelection.base.offset.toInt(),
            suggestionLength,
            LinkAttribute(Constants.DEFAULT_HEROESBOOK_URL +
                Routes.getParameterizedRouteForViewProduct(suggestion)
                    .replaceAll('//', '/')));
        widget.quillEditor.controller.document
            .replace(textSelection.base.offset.toInt() - 1, 1, '');
        widget.quillEditor.controller.updateSelection(
          TextSelection.collapsed(
              offset: textSelection.base.offset.toInt() + suggestionLength),
          ChangeSource.LOCAL,
        );
        widget.quillEditor.focusNode.requestFocus();
      });
    }
  }
}
