import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

// ignore: import_of_legacy_library_into_null_safe
import 'package:archive/archive.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_cache/Cache.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_cache/flutter_cache.dart' as cache;
import 'package:little_drops_of_rain_flutter/extensions/uri_extensions.dart';
import 'package:little_drops_of_rain_flutter/extensions/string_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/helpers/settings.dart';
import 'package:little_drops_of_rain_flutter/interfaces/on_cache_update_callback.dart';
import 'package:little_drops_of_rain_flutter/real_main.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:pedantic/pedantic.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

class ImagesCache extends Cache {
  ImagesCache(String key, String data) : super(key, data);

  static final SharedPreferences _prefs = MyApp.getSharedPreferences();
  static final _encoder = GZipEncoder();
  static final _decoder = GZipDecoder();
  static final Set<String> _keys = <String>{};
  static Timer? _autoUpdateTimer;
  static final List<OnCacheUpdateCallback> _cacheUpdateListeners =
      <OnCacheUpdateCallback>[];
  static bool _isInitialized = false;

  static bool hasListener(OnCacheUpdateCallback listener) {
    return _cacheUpdateListeners.contains(listener);
  }

  static void registerListener(OnCacheUpdateCallback listener) {
    _cacheUpdateListeners.add(listener);
  }

  static void removeListener(OnCacheUpdateCallback listener) {
    _cacheUpdateListeners.remove(listener);
  }

  static bool isInitialized() {
    return _isInitialized;
  }

  static Future<bool?> initialize() async {
    _isInitialized = true;
    try {
      await _getKeysFromPreferences();
      await checkAndEnableOrDisableAutoUpdates();
    } catch (ex) {
      _isInitialized = false;
    }

    return _isInitialized;
  }

  static Future<int> _getKeysFromPreferences() async {
    for (final key in _prefs.getKeys()) {
      if (!key.startsWith('type') &&
          !key.startsWith('content') &&
          !key.endsWith('ExpiredAt')) {
        final uri = Uri.tryParse(key);
        if (uri != null && (uri.isFromStorage() || uri.isFromWeb())) {
          _keys.add(uri.toString());
        }
      }
    }
    return _keys.length;
  }

  static bool containsAsUri(Uri key) {
    return contains(key.toString());
  }

  static bool contains(String key) {
    final ret = _keys.contains(key);
    MyLogger().logger.i(
        '[ImagesCache.contains]Verified key : $key${ret ? '. It does contain' : '. It does NOT contain'}');
    MyLogger().logger.i('The stored keys are :');
    for (final key in _keys) {
      MyLogger().logger.i('\t-$key');
    }
    return ret;
  }

  static Future<Uint8List?> writeAsUri(Uri key, Uint8List data) async {
    return write(key.toString(), data);
  }

  static Future<Uint8List?> write(String key, Uint8List data) async {
    Uint8List? uncompressedData;
    if (data.isNotEmpty) {
      _keys.add(key);
      final enableCompression =
          _prefs.getBool(Constants.PREFS_ENABLE_COMPRESSION);
      final compress = (enableCompression != null)
          ? enableCompression
          : Constants.DEFAULT_ENABLE_COMPRESSION_VALUE;
      if (compress) {
        final compressionLevel =
            _prefs.getInt(Constants.PREFS_COMPRESSION_LEVEL);
        final compressedData =
            Uint8List.fromList(_encoder.encode(data, level: compressionLevel)!);
        MyLogger().logger.i(
            'Compression successful, by -${data.length - compressedData.length} bytes');
        if (compressedData.length < data.length) {
          data = compressedData;
        }
      }
      final base64EncodedData = base64.encode(data);
      final base64StoredData = await cache.write(
          key.toString(), base64EncodedData, _getImageTTL()) as String?;
      if (base64StoredData == null || base64StoredData.isEmpty) {
        _keys.remove(key.toString());
        MyLogger().logger.i(
            '[ImagesCache.write]Unable to add key : $key with data of ${data.length} bytes. ${compress ? ' (${utf8.encode(base64EncodedData).length.toString()} base 64 compressed). Perhaps the storage is full?' : ''}');
      } else {
        final storedCompressedString = base64.decode(base64StoredData);
        uncompressedData = storedCompressedString;
        if (compress) {
          try {
            uncompressedData = Uint8List.fromList(
                _decoder.decodeBytes(storedCompressedString, verify: true));
          } on ArchiveException catch (ex) {
            MyLogger().logger.i(
                '[ImagesCache.write]Error trying to uncompress the image : ${ex.toString()}');
          }
        }
        MyLogger().logger.i(
            '[ImagesCache.write]Added key : $key with data of ${data.length} bytes. ${compress ? ' (${(uncompressedData != null) ? uncompressedData.length : 0} uncompressed)' : ''}');
      }
    } else {
      MyLogger()
          .logger
          .i('[ImagesCache.write]Unable to add key : $key with empty data');
    }
    return uncompressedData;
  }

  static Future<Uint8List?> rememberAsUri(Uri key, Uint8List data) async {
    return remember(key.toString(), data);
  }

  static Future<Uint8List?> remember(String key, Uint8List data) async {
    Uint8List? uncompressedData;
    if (data.isNotEmpty) {
      _keys.add(key);
      final enableCompression =
          _prefs.getBool(Constants.PREFS_ENABLE_COMPRESSION);
      final compress = (enableCompression != null)
          ? enableCompression
          : Constants.DEFAULT_ENABLE_COMPRESSION_VALUE;
      if (compress) {
        final compressionLevel =
            _prefs.getInt(Constants.PREFS_COMPRESSION_LEVEL);
        final compressedData =
            Uint8List.fromList(_encoder.encode(data, level: compressionLevel)!);
        MyLogger().logger.i(
            'Compression successful, by -${data.length - compressedData.length} bytes');
        if (compressedData.length < data.length) {
          data = compressedData;
        }
      }
      final base64EncodedData = base64.encode(data);
      final base64StoredData = await cache.remember(
          key, base64EncodedData, _getImageTTL()) as String?;
      if (base64StoredData == null || base64StoredData.isEmpty) {
        _keys.remove(key);
        MyLogger().logger.i(
            '[ImagesCache.remember]Unable to add key : $key with data of ${data.length} bytes. ${compress ? ' (${utf8.encode(base64EncodedData).length.toString()} base 64 compressed). Perhaps the storage is full?' : ''}');
      } else {
        final storedCompressedString = base64.decode(base64StoredData);
        uncompressedData = storedCompressedString;
        if (compress) {
          try {
            uncompressedData = Uint8List.fromList(
                _decoder.decodeBytes(storedCompressedString, verify: true));
          } on ArchiveException catch (ex) {
            MyLogger().logger.i(
                '[ImagesCache.write]Error trying to uncompress the image : ${ex.toString()}');
          }
        }
        MyLogger().logger.i(
            '[ImagesCache.remember]Added key : $key with data of ${data.length} bytes. ${compress ? ' (${(uncompressedData != null) ? uncompressedData.length : 0} uncompressed)' : ''}');
      }
    } else {
      MyLogger()
          .logger
          .i('[ImagesCache.remember]Unable to add key : $key with empty data');
    }
    return uncompressedData;
  }

  static Future<Uint8List?> loadAsUri(Uri key, {bool list = false}) async {
    return load(key.toString(), list: list);
  }

  static Future<Uint8List?> load(String key, {bool list = false}) async {
    final cachedImage =
        await cache.load(key, Uint8List.fromList(<int>[]), list) as String?;
    Uint8List? data;
    if (cachedImage != null && cachedImage.isNotEmpty) {
      final compressedData = base64.decode(cachedImage);
      Uint8List? uncompressedData;
      var uncompressed = false;
      try {
        uncompressedData = Uint8List.fromList(
            _decoder.decodeBytes(compressedData, verify: true));
        uncompressed = true;
      } on ArchiveException catch (ex) {
        MyLogger().logger.i(
            '[ImagesCache.load]Data for key : $key is not compressed. Got error ${ex.toString()}. Returning raw data.');
        uncompressedData = compressedData;
      }
      data = uncompressedData;
      MyLogger().logger.i(
          '[ImagesCache.load]Got data for key : $key with data of ${data.length} bytes. ${uncompressed ? '(${compressedData.length} compressed)' : ''}');
    } else {
      destroy(key);
    }
    return data;
  }

  static void destroy(String key) {
    _keys.remove(key);
    cache.destroy(key);
  }

  static void clear() {
    _keys.forEach(cache.destroy);
    _keys.clear();
  }

  static Future<void> reset() async {
    await Settings.resetImagesCache();
  }

  static Future<bool> isCacheEnabled() async {
    final enableCache = _prefs.getBool(Constants.PREFS_ENABLE_CACHE);
    final ret = (enableCache != null)
        ? enableCache
        : Constants.DEFAULT_ENABLE_CACHE_VALUE;
    return ret;
  }

  static Future<bool> shouldEnableCacheAutoUpdate() async {
    final enableCache = _prefs.getBool(Constants.PREFS_ENABLE_CACHE);
    final retEnableCache = (enableCache != null)
        ? enableCache
        : Constants.DEFAULT_ENABLE_CACHE_VALUE;
    final enableCacheAutoUpdate =
        _prefs.getBool(Constants.PREFS_ENABLE_CACHE_AUTO_UPDATE);
    final retEnableCacheAutoUpdate = (enableCacheAutoUpdate != null)
        ? enableCacheAutoUpdate
        : Constants.DEFAULT_ENABLE_CACHE_AUTO_UPDATE_VALUE;
    return retEnableCache && retEnableCacheAutoUpdate;
  }

  static Future<bool> isCacheAutoUpdateEnabled() async {
    final enableCacheAutoUpdate =
        _prefs.getBool(Constants.PREFS_ENABLE_CACHE_AUTO_UPDATE);
    final ret = (enableCacheAutoUpdate != null)
        ? enableCacheAutoUpdate
        : Constants.DEFAULT_ENABLE_CACHE_AUTO_UPDATE_VALUE;
    return ret;
  }

  static Future<void> checkAndEnableOrDisableAutoUpdates() async {
    if (await shouldEnableCacheAutoUpdate()) {
      await enableAutoUpdates();
    } else {
      disableAutoUpdates();
    }
  }

  static Future<void> enableAutoUpdates() async {
    disableAutoUpdates();

    final autoUpdateInterval =
        _prefs.getInt(Constants.PREFS_CACHE_AUTO_UPDATE_INTERVAL);
    final interval = (autoUpdateInterval != null)
        ? autoUpdateInterval
        : Constants.DEFAULT_CACHE_AUTO_UPDATE_INTERVAL_VALUE;
    if (interval > 0) {
      _autoUpdateTimer =
          Timer.periodic(Duration(seconds: interval), (t) => reloadImages());
    }
  }

  static void disableAutoUpdates() {
    if (_autoUpdateTimer != null) {
      _autoUpdateTimer!.cancel();
      _autoUpdateTimer = null;
    }
  }

  static Future<void> reloadImages() async {
    _cacheUpdateListeners.forEach((element) {
      element.updateStart(_keys.length);
    });

    var current = 0;
    for (final key in _keys) {
      current++;
      final bytes = await key.downloadBytes();
      if (bytes != null && bytes.isNotEmpty) {
        unawaited(ImagesCache.write(key, bytes));
      }
      _cacheUpdateListeners.forEach((element) {
        element.updateProgress(current, _keys.length);
      });
    }
    _cacheUpdateListeners.forEach((element) {
      element.updateEnd();
    });
  }

  static Future<void> updateImagesTTL() async {
    for (final key in _keys) {
      final base64StoredImage = await cache.load(
        key,
        Uint8List.fromList(<int>[]),
      ) as String?;
      if (base64StoredImage != null && base64StoredImage.isNotEmpty) {
        unawaited(cache.write(key, base64StoredImage, _getImageTTL()));
      } else {
        destroy(key);
      }
    }
  }

  static int getCacheItemsCount() {
    return _keys.length;
  }

  static int? _getImageTTL() {
    int? ret;
    final enableCacheTTL = _prefs.getBool(Constants.PREFS_ENABLE_CACHE_TTL);
    final value = (enableCacheTTL != null)
        ? enableCacheTTL
        : Constants.DEFAULT_ENABLE_CACHE_TTL_VALUE;
    if (value) {
      ret = _prefs.getInt(Constants.PREFS_CACHE_TTL_VALUE);
      ret = (ret == 0) ? null : ret;
    }
    return ret;
  }
}
