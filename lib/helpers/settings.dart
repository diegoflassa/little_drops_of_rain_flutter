// ignore: import_of_legacy_library_into_null_safe
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/images_cache.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/real_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: avoid_classes_with_only_static_members
class Settings {
  static SharedPreferences _prefs = MyApp.getSharedPreferences();
  static bool _isInitialized = false;
  static bool _appliedSettings = false;

  static Future<bool?> initialize() async {
    await _initializeImagesCachePreferences();
    await _initializeAnimationsPreferences();
    return _isInitialized = true;
  }

  static bool isInitialized() {
    return _isInitialized;
  }

  static void applySettings() {
    try {
      _applySettings();
    } catch (ex) {
      MyLogger().logger.e('Error applying settings. Got: ${ex.toString()}');
      reset();
      _applySettings();
    }
    _appliedSettings = true;
  }

  static void _applySettings() {
  }

  static bool appliedSettings() {
    return _appliedSettings;
  }

  static Future<void> _initializeImagesCachePreferences() async {
    if (!_prefs.containsKey(Constants.PREFS_ENABLE_CACHE)) {
      await _prefs.setBool(
          Constants.PREFS_ENABLE_CACHE, Constants.DEFAULT_ENABLE_CACHE_VALUE);
    }
    if (!_prefs.containsKey(Constants.PREFS_ENABLE_CACHE_AUTO_UPDATE)) {
      await _prefs.setBool(Constants.PREFS_ENABLE_CACHE_AUTO_UPDATE,
          Constants.DEFAULT_ENABLE_CACHE_AUTO_UPDATE_VALUE);
    }
    if (!_prefs.containsKey(Constants.PREFS_CACHE_AUTO_UPDATE_INTERVAL)) {
      await _prefs.setInt(Constants.PREFS_CACHE_AUTO_UPDATE_INTERVAL,
          Constants.DEFAULT_CACHE_AUTO_UPDATE_INTERVAL_VALUE);
    }
    if (!_prefs.containsKey(Constants.PREFS_ENABLE_CACHE_TTL)) {
      await _prefs.setBool(Constants.PREFS_ENABLE_CACHE_TTL,
          Constants.DEFAULT_ENABLE_CACHE_TTL_VALUE);
    }
    if (!_prefs.containsKey(Constants.PREFS_CACHE_TTL_VALUE)) {
      await _prefs.setInt(
          Constants.PREFS_CACHE_TTL_VALUE, Constants.DEFAULT_CACHE_TTL_VALUE);
    }
    if (!_prefs.containsKey(Constants.PREFS_ENABLE_COMPRESSION)) {
      await _prefs.setBool(Constants.PREFS_ENABLE_COMPRESSION,
          Constants.DEFAULT_ENABLE_COMPRESSION_VALUE);
    }
    if (!_prefs.containsKey(Constants.PREFS_COMPRESSION_LEVEL)) {
      await _prefs.setInt(Constants.PREFS_COMPRESSION_LEVEL,
          Constants.DEFAULT_COMPRESSION_LEVEL_VALUE);
    }
  }

  static Future<void> _initializeAnimationsPreferences() async {
    _prefs = MyApp.getSharedPreferences();
    if (!_prefs.containsKey(Constants.PREFS_CARD_TO_DETAILS_TRANSITION_TYPE)) {
      await _prefs.setString(Constants.PREFS_CARD_TO_DETAILS_TRANSITION_TYPE,
          Constants.DEFAULT_CARD_TO_DETAILS_TRANSITION_TYPE_VALUE);
    }
    if (!_prefs.containsKey(Constants.PREFS_TIME_DILATION)) {
      await _prefs.setDouble(
          Constants.PREFS_TIME_DILATION, Constants.DEFAULT_TIME_DILATION_VALUE);
    }
    if (!_prefs.containsKey(Constants.PREFS_PAGE_TRANSITION_TYPE)) {
      await _prefs.setString(Constants.PREFS_PAGE_TRANSITION_TYPE,
          Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE);
    }
  }

  static Future<bool?> reset() async {
    await resetImagesCache();
    await resetAnimations();
    return true;
  }

  static Future<bool> resetImagesCache() async {
    _prefs = MyApp.getSharedPreferences();
    await _prefs.setBool(
        Constants.PREFS_ENABLE_CACHE, Constants.DEFAULT_ENABLE_CACHE_VALUE);
    await _prefs.setBool(Constants.PREFS_ENABLE_CACHE_AUTO_UPDATE,
        Constants.DEFAULT_ENABLE_CACHE_AUTO_UPDATE_VALUE);
    await _prefs.setInt(Constants.PREFS_CACHE_AUTO_UPDATE_INTERVAL,
        Constants.DEFAULT_CACHE_AUTO_UPDATE_INTERVAL_VALUE);
    await _prefs.setBool(Constants.PREFS_ENABLE_CACHE_TTL,
        Constants.DEFAULT_ENABLE_CACHE_TTL_VALUE);
    await _prefs.setInt(
        Constants.PREFS_CACHE_TTL_VALUE, Constants.DEFAULT_CACHE_TTL_VALUE);
    await _prefs.setBool(Constants.PREFS_ENABLE_COMPRESSION,
        Constants.DEFAULT_ENABLE_COMPRESSION_VALUE);
    await _prefs.setInt(Constants.PREFS_COMPRESSION_LEVEL,
        Constants.DEFAULT_COMPRESSION_LEVEL_VALUE);
    await ImagesCache.updateImagesTTL();
    if (await ImagesCache.shouldEnableCacheAutoUpdate()) {
      await ImagesCache.enableAutoUpdates();
    } else {
      ImagesCache.disableAutoUpdates();
    }
    return true;
  }

  static Future<bool> resetAnimations() async {
    _prefs = MyApp.getSharedPreferences();
    await _prefs.setString(Constants.PREFS_CARD_TO_DETAILS_TRANSITION_TYPE,
        Constants.DEFAULT_CARD_TO_DETAILS_TRANSITION_TYPE_VALUE);
    await _prefs.setString(Constants.PREFS_PAGE_TRANSITION_TYPE,
        Constants.DEFAULT_PAGE_TRANSITION_TYPE_VALUE);
    await _prefs.setDouble(
        Constants.PREFS_TIME_DILATION, Constants.DEFAULT_TIME_DILATION_VALUE);
    return true;
  }
}
