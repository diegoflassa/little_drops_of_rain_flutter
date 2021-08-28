import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/products_events.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart' as my_app;
import 'package:little_drops_of_rain_flutter/enums/order_by.dart';
import 'package:little_drops_of_rain_flutter/routing/routing_data.dart';

class ViewProductsModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  List<my_app.Product> _products = <my_app.Product>[];

  set products(List<my_app.Product> value) {
    _products = value;
    notifyListeners();
  }

  List<my_app.Product> get products => _products;

  double _scrollPosition = 5;

  set scrollPosition(double value) {
    _scrollPosition = value;
    notifyListeners();
  }

  double get scrollPosition => _scrollPosition;

  StreamSubscription<User?>? _unsubscribe;

  set unsubscribe(StreamSubscription<User?>? value) {
    _unsubscribe?.cancel();
    _unsubscribe = value;
    notifyListeners();
  }

  StreamSubscription<User?>? get unsubscribe => _unsubscribe;

  OrderBy _orderBy = OrderBy.UPDATE_DATE;

  set orderBy(OrderBy value) {
    _orderBy = value;
    notifyListeners();
  }

  OrderBy get orderBy => _orderBy;

  bool _descending = false;

  set descending(bool value) {
    _descending = value;
    notifyListeners();
  }

  bool get descending => _descending;

  bool _shouldReload = false;

  set shouldReload(bool value) {
    _shouldReload = value;
    notifyListeners();
  }

  bool get shouldReload => _shouldReload;

  bool _isMine = false;

  set isMine(bool value) {
    _isMine = value;
    notifyListeners();
  }

  bool get isMine => _isMine;

  bool _waitForFirstPage = false;

  set waitForFirstPage(bool value) {
    _waitForFirstPage = value;
    notifyListeners();
  }

  bool get waitForFirstPage => _waitForFirstPage;

  bool _loadMore = false;

  set loadMore(bool value) {
    _loadMore = value;
    notifyListeners();
  }

  bool get loadMore => _loadMore;

  double _previousMaxScrollExtent = 0;

  set previousMaxScrollExtent(double value) {
    _previousMaxScrollExtent = value;
    notifyListeners();
  }

  double get previousMaxScrollExtent => _previousMaxScrollExtent;

  bool _myProducts = false;

  set myProducts(bool value) {
    _myProducts = value;
    notifyListeners();
  }

  bool get myProducts => _myProducts;

  bool _endOfItems = false;

  set endOfItems(bool value) {
    _endOfItems = value;
    notifyListeners();
  }

  bool get endOfItems => _endOfItems;

  bool _isFirstRun = true;

  set isFirstRun(bool value) {
    _isFirstRun = value;
    notifyListeners();
  }

  bool get isFirstRun => _isFirstRun;

  Type? _clearByState;

  set clearByState(Type? value) {
    _clearByState = value;
    notifyListeners();
  }

  Type? get clearByState => _clearByState;

  bool _isLoading = false;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  String? _lastLanguageTo;

  set lastLanguageTo(String? value) {
    _lastLanguageTo = value;
    notifyListeners();
  }

  String? get lastLanguageTo => _lastLanguageTo;

  String _lastLanguageTranslated = 'auto';

  set lastLanguageTranslated(String value) {
    _lastLanguageTranslated = value;
    notifyListeners();
  }

  String get lastLanguageTranslated => _lastLanguageTranslated;

  RoutingData? _routingData;

  set routingData(RoutingData? value) {
    _routingData = value;
    notifyListeners();
  }

  RoutingData? get routingData => _routingData;

  ProductsEvents? _lastEvent;

  set lastEvent(ProductsEvents? value) {
    _lastEvent = value;
    notifyListeners();
  }

  ProductsEvents? get lastEvent => _lastEvent;

  Timer? _checkEventExecutionTimeTimer;

  set checkEventExecutionTimeTimer(Timer? value) {
    _checkEventExecutionTimeTimer = value;
    notifyListeners();
  }

  Timer? get checkEventExecutionTimeTimer => _checkEventExecutionTimeTimer;

  void clear() {
    _products.clear();
    _scrollPosition = 5.0;
    _unsubscribe?.cancel();
    _unsubscribe = null;
    _orderBy = OrderBy.UPDATE_DATE;
    _descending = false;
    _shouldReload = false;
    _isMine = false;
    _waitForFirstPage = false;
    _loadMore = false;
    _previousMaxScrollExtent = 0;
    _myProducts = false;
    _endOfItems = true;
    //_isFirstRun = true;
    _clearByState = null;
    _isLoading = false;
    _lastLanguageTo = null;
    _lastLanguageTranslated = 'auto';
    _routingData = null;
    _lastEvent = null;
    _checkEventExecutionTimeTimer = null;
    notifyListeners();
  }
}
