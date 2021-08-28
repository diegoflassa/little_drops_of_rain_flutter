import 'dart:async';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;

class ConnectionStatusSingleton {
  ConnectionStatusSingleton._internal();

  //This creates the single instance by calling the `_internal` constructor specified below
  static final ConnectionStatusSingleton _singleton =
      ConnectionStatusSingleton._internal();

  //This is what's used to retrieve the instance through the app
  static ConnectionStatusSingleton getInstance() => _singleton;

  //This tracks the current connection status
  bool _hasConnection = false;
  bool _isCheckingConnection = false;
  bool _isRunningTransaction = false;
  static const String _kGoogleUrl = 'https://www.google.com';
  static const String _kFacebookUrl = 'https://www.facebook.com';
  static const String _kMicrosoftUrl = 'https://www.microsoft.com';
  static const String _kGoogleUrlWithoutHttpsAndWww = 'google.com';
  static const String _kFacebookUrlWithoutHttpsAndWww = 'facebook.com';
  static const String _kMicrosoftUrlWithoutHttpsAndWww = 'microsoft.com';
  ConnectivityResult? _previousConnectivityResult;

  static bool _hasSentNotification = false;

  //This is how we'll allow subscribing to connection changes
  StreamController<bool> connectionChangeController =
      StreamController<bool>.broadcast();

  //dynamic
  final Connectivity _connectivity = Connectivity();

  //Hook into flutter_connectivity's Stream to listen for changes
  //And check the connection status out of the gate
  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    checkConnection();
  }

  Stream<bool> get connectionChange => connectionChangeController.stream;

  //A clean up method to close our StreamController
  //   Because this is meant to exist through the entire application life cycle this isn't
  //   really an issue
  void dispose() {
    connectionChangeController.close();
  }

  //flutter_connectivity's listener
  void _connectionChange(dynamic result) {
    final connectivityResult = result as ConnectivityResult;
    if (_previousConnectivityResult == null ||
        connectivityResult != _previousConnectivityResult) {
      _previousConnectivityResult = connectivityResult;
      checkConnection();
    }
  }

  //The test to actually see if there is a connection
  Future<bool> checkConnection() async {
    if (!_isCheckingConnection) {
      _isCheckingConnection = true;
      final previousConnection = _hasConnection;

      if (!kIsWeb) {
        _hasConnection = await _checkByAddressLookup();
      } else {
        _hasConnection = true;
      }
      //If the _hasConnection is true by lookup, we must double check by another way
      // as its value may be from cache from the router
      if (_hasConnection) {
        final resultByHead = await _checkByHead();
        final resultByFirebase = await _checkByFirestore();
        _hasConnection = resultByHead || resultByFirebase;
      }

      MyLogger()
          .logger
          .d('[checkConnection]Setting connected to : $_hasConnection');

      //The connection status changed send out an update to all listeners
      if (previousConnection != _hasConnection || !_hasSentNotification) {
        _hasSentNotification = true;
        connectionChangeController.add(_hasConnection);
      }
      _isCheckingConnection = false;
    }
    if (!_hasConnection) {
      Future.delayed(
          const Duration(
              milliseconds: Constants.DEFAULT_DELAY_TO_RECHECK_CONNECTION),
          checkConnection);
    }
    return _hasConnection;
  }

  Future<bool> _checkByAddressLookup() async {
    var ret = false;
    try {
      final resultGoogle =
          await InternetAddress.lookup(_kGoogleUrlWithoutHttpsAndWww);
      final resultFacebook =
          await InternetAddress.lookup(_kFacebookUrlWithoutHttpsAndWww);
      final resultMicrosoft =
          await InternetAddress.lookup(_kMicrosoftUrlWithoutHttpsAndWww);
      if ((resultGoogle.isNotEmpty && resultGoogle[0].rawAddress.isNotEmpty) ||
          (resultFacebook.isNotEmpty &&
              resultFacebook[0].rawAddress.isNotEmpty) ||
          (resultMicrosoft.isNotEmpty &&
              resultMicrosoft[0].rawAddress.isNotEmpty)) {
        ret = true;
      } else {
        ret = false;
      }
    } on SocketException catch (ex) {
      MyLogger().logger.e(
          '[ConnectionStatusSingleton._checkByAddressLookup]SocketException: ${ex.toString()}');
      ret = false;
    } on Error catch (ex) {
      MyLogger().logger.e(
          '[ConnectionStatusSingleton._checkByAddressLookup]Error: ${ex.toString()}');
      ret = false;
    } on Exception catch (ex) {
      MyLogger().logger.e(
          '[ConnectionStatusSingleton._checkByAddressLookup]Exception: ${ex.toString()}');
      ret = false;
    }
    MyLogger()
        .logger
        .i('[ConnectionStatusSingleton._checkByAddressLookup]Returned: $ret');
    return ret;
  }

  Future<bool> _checkByHead() async {
    final resultGoogle = await _checkByGoogle();
    final resultFacebook = await _checkByFacebook();
    final resultMicrosoft = await _checkByMicrosoft();
    return resultGoogle || resultFacebook || resultMicrosoft;
  }

  Future<bool> _checkByGoogle() async {
    return _checkByUrl(_kGoogleUrl);
  }

  Future<bool> _checkByFacebook() async {
    return _checkByUrl(_kFacebookUrl);
  }

  Future<bool> _checkByMicrosoft() async {
    return _checkByUrl(_kMicrosoftUrl);
  }

  Future<bool> _checkByUrl(String url) async {
    var ret = false;
    try {
      final corsHeaders = <String, String>{};

      corsHeaders['Access-Control-Allow-Methods'] = 'GET, HEAD, OPTIONS';
      corsHeaders['Access-Control-Expose-Headers'] = '*';
      corsHeaders['Access-Control-Allow-Credentials'] = 'true';
      corsHeaders['Access-Control-Allow-Headers'] = '*';
      corsHeaders['Access-Control-Allow-Origin'] = '*';
      final response = await http.head(Uri.parse(url), headers: corsHeaders);
      if ((response.statusCode == 202 && response.body.isNotEmpty) || response.statusCode == 200) {
        ret = true;
      } else {
        ret = false;
      }
    } on Error catch (ex) {
      MyLogger().logger.e(
          '[ConnectionStatusSingleton._checkByUrl]Url: $url - Error: ${ex.toString()}');
      ret = false;
    } on http.ClientException catch (ex) {
      if (ex.message.contains('XMLHttpRequest')) {
        ret = true;
      } else {
        MyLogger().logger.e(
            '[ConnectionStatusSingleton._checkByUrl]Url: $url - Error: ${ex.toString()}');
      }
    } on Exception catch (ex) {
      MyLogger().logger.e(
          '[ConnectionStatusSingleton._checkByUrl]Url: $url - Error: ${ex.toString()}');
      ret = false;
    }
    MyLogger()
        .logger
        .i('[ConnectionStatusSingleton._checkByUrl]Returned: $ret for $url');
    return ret;
  }

  Future<bool> _checkByFirestore() async {
    var ret = false;
    try {
      if(!_isRunningTransaction) {
        _isRunningTransaction= true;
        ret = await FirebaseFirestore.instance
            .runTransaction<bool>((transaction) async {
          _isRunningTransaction= false;
          return Future.value(true);
        }).timeout(const Duration(seconds: 5));
      }
    } on Error catch (ex) {
      MyLogger().logger.e(
          '[ConnectionStatusSingleton._checkByFirestore]Error: ${ex.toString()}');
      ret = false;
    } on Exception catch (ex) {
      MyLogger().logger.e(
          '[ConnectionStatusSingleton._checkByFirestore]Exception: ${ex.toString()}');
      ret = false;
    }
    MyLogger()
        .logger
        .i('[ConnectionStatusSingleton._checkByFirestore]Returned: $ret');
    return ret;
  }
}
