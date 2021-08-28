import 'dart:async';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pedantic/pedantic.dart';
import 'package:little_drops_of_rain_flutter/data/dao/products_dao.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart' as my_app;
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';

class ProductsAutoCompleter extends TypeAheadFormField<my_app.Product> {
  ProductsAutoCompleter(this.onSuggestionSelected,
      {TextFieldConfiguration? textFieldConfiguration =
          const TextFieldConfiguration(),
      Key? key})
      : super(
          key: key,
          itemBuilder: _itemBuilder,
          onSuggestionSelected: onSuggestionSelected,
          suggestionsCallback: _suggestionsCallback,
          textFieldConfiguration: (textFieldConfiguration != null)
              ? textFieldConfiguration
              : _textFieldConfiguration,
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
  static SuggestionsCallback<void>? suggestionCallback;
  final SuggestionSelectionCallback<my_app.Product> onSuggestionSelected;
  static final TextEditingController typeAheadController =
      TextEditingController();
  static final _textFieldConfiguration = TextFieldConfiguration(
      controller: typeAheadController,
      decoration: const InputDecoration(labelText: 'Products'));

  static void setUniverseUid(String? universeUid) {
    if(_universeUid != universeUid) {
      _universeUid = universeUid;
      _updateSuggestions();
    }
  }

  static String? getUniverseUid() {
    return _universeUid;
  }

  static void _updateSuggestions() {
    if (_universeUid != null) {
      unawaited(
          ProductsDao().getAllPublishedByUniverse(_universeUid!).then((products) {
        _productsSuggestions = products;
      }));
    }
  }

  void clear() {
    typeAheadController.text = '';
  }

  static Widget _itemBuilder(BuildContext context, my_app.Product suggestion) {
    return ListTile(
      title: Text(suggestion.codename),
    );
  }

  static Future<List<my_app.Product>> _suggestionsCallback(String pattern) async {
    suggestionCallback?.call(pattern);
    final queryResults = <my_app.Product>[];
    for (final product in _productsSuggestions) {
      if ((product.published == true) &&
          (product.civilName
                  .toLowerCase()
                  .contains(pattern.trim().toLowerCase()) ||
              product.codename
                  .toLowerCase()
                  .contains(pattern.trim().toLowerCase()))) {
        queryResults.add(product);
      }
    }
    return queryResults;
  }
}
