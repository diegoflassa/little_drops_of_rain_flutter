import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:little_drops_of_rain_flutter/data/dao/products_dao.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart' as my_app;
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/interfaces/on_suggestions_callback.dart';

class ProductsAutoCompleter extends RawAutocomplete<my_app.Product> {
  ProductsAutoCompleter(this.autocompleteOnSelected,
      {Key? key, FocusNode? focusNode})
      : super(
          key: key,
          optionsViewBuilder: _optionsViewBuilder,
          optionsBuilder: _optionsBuilder,
          focusNode: focusNode,
          textEditingController: _textEditingController,
        ) {
    _updateSuggestions();
    _autoUpdateTimer ??= Timer.periodic(
        const Duration(
            milliseconds: Constants.DEFAULT_DELAY_TO_RELOAD_HEROES_SUGGESTIONS),
        (t) => _updateSuggestions());
  }

  static String? _universeUid;
  static Timer? _autoUpdateTimer;
  static List<my_app.Product> _productsSuggestions = <my_app.Product>[];
  static OnSuggestionsCallback<String>? suggestionCallback;
  final AutocompleteOnSelected<my_app.Product> autocompleteOnSelected;
  static final TextEditingController _textEditingController =
      TextEditingController();

  static void setUniverseUid(String? universeUid) {
    if (_universeUid != universeUid) {
      _universeUid = universeUid;
      _updateSuggestions();
    }
  }

  void clear() {
    _textEditingController.text = '';
  }

  static void _updateSuggestions() {
    unawaited(
        ProductsDao().getAllPublishedByUniverse(_universeUid!).then((products) {
      _productsSuggestions = products;
    }));
  }

  static Widget _optionsViewBuilder(
      BuildContext context,
      AutocompleteOnSelected<my_app.Product> onSelected,
      Iterable<my_app.Product> results) {
    return ListView(
      children: results.map((result) {
        return GestureDetector(
          onTap: () {
            onSelected(result);
          },
          child: ListTile(
            title: Text(result.toString()),
          ),
        );
      }).toList(),
    );
  }

  static Iterable<my_app.Product> _optionsBuilder(TextEditingValue value) {
    suggestionCallback?.onSuggestion(value.text);
    final queryResults = <my_app.Product>[];
    for (final product in _productsSuggestions) {
      if ((product.published == true) &&
          (product.civilName
                  .toLowerCase()
                  .contains(value.text.trim().toLowerCase()) ||
              product.codename
                  .toLowerCase()
                  .contains(value.text.trim().toLowerCase()))) {
        queryResults.add(product);
      }
    }
    return queryResults;
  }
}
