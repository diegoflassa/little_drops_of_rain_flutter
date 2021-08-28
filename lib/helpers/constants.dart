import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class Constants {
  static const String APP_NAME = 'The Productsbook';
  static const String APP_PACKAGE_NAME = 'br.com.little_drops_of_rain_flutter.little_drops_of_rain_flutter';
  static const String APP_EMAIL = 'little_drops_of_rain_flutter@thehreoesbook.com.br';
  static const String SOCIAL_LINK_FACEBOOK =
      'https://www.facebook.com/little_drops_of_rain_flutter/';
  static const String SOCIAL_LINK_TWITTER =
      'https://www.twitter.com/little_drops_of_rain_flutter/';
  static const String ADMOB_APP_ID = 'ca-app-pub-8777866873579970~4137085789';
  static const String ADMOB_BANNER_ID =
      'ca-app-pub-8777866873579970/2449240221';
  static const String ADMOB_INTERSTITIAL_ID =
      'ca-app-pub-8777866873579970/8823076882';
  static const String ADMOB_INTERSTITIAL_VIDEO_ID = 'TODO';
  static const String ADMOB_REWARDED_ID =
      'ca-app-pub-8777866873579970/5945825620';
  static const String ADMOB_REWARDED_INTERSTITIAL_ID = 'TODO';
  static const String ADMOB_ADVANCED_NATIVE_ID =
      'ca-app-pub-8777866873579970/4828007460';
  static const String ADMOB_ADVANCED_NATIVE_VIDEO_ID = 'TODO';
  static const String ADMOB_APP_OPEN_ID =
      'ca-app-pub-8777866873579970/1399898343';
  static const String DEFAULT_HEROESBOOK_URL =
      'https://little_drops_of_rain_flutter.web.app/#/';

  static const String ADMOB_TEST_APP_OPEN_ID_ANDROID =
      'ca-app-pub-3940256099942544/3419835294';
  static const String ADMOB_TEST_BANNER_ID_ANDROID =
      'ca-app-pub-3940256099942544/6300978111';
  static const String ADMOB_TEST_INTERSTITIAL_ID_ANDROID =
      'ca-app-pub-3940256099942544/1033173712';
  static const String ADMOB_TEST_INTERSTITIAL_VIDEO_ID_ANDROID =
      'ca-app-pub-3940256099942544/8691691433';
  static const String ADMOB_TEST_REWARDED_ID_ANDROID =
      'ca-app-pub-3940256099942544/5224354917';
  static const String ADMOB_TEST_REWARDED_INTERSTITIAL_ID_ANDROID =
      'ca-app-pub-3940256099942544/5354046379';
  static const String ADMOB_TEST_NATIVE_ADVANCED_ID_ANDROID =
      'ca-app-pub-3940256099942544/2247696110';
  static const String ADMOB_TEST_NATIVE_ADVANCED_VIDEO_ID_ANDROID =
      'ca-app-pub-3940256099942544/1044960115';

  static const String ADMOB_TEST_APP_OPEN_ID_IOS =
      'ca-app-pub-3940256099942544/5662855259';
  static const String ADMOB_TEST_BANNER_ID_IOS =
      'ca-app-pub-3940256099942544/2934735716';
  static const String ADMOB_TEST_INTERSTITIAL_ID_IOS =
      'ca-app-pub-3940256099942544/4411468910';
  static const String ADMOB_TEST_INTERSTITIAL_VIDEO_ID_IOS =
      'ca-app-pub-3940256099942544/5135589807';
  static const String ADMOB_TEST_REWARDED_ID_IOS =
      'ca-app-pub-3940256099942544/1712485313';
  static const String ADMOB_TEST_REWARDED_INTERSTITIAL_ID_IOS =
      'ca-app-pub-3940256099942544/6978759866';
  static const String ADMOB_TEST_NATIVE_ADVANCED_ID_IOS =
      'ca-app-pub-3940256099942544/3986624511';
  static const String ADMOB_TEST_NATIVE_ADVANCED_VIDEO_ID_IOS =
      'ca-app-pub-3940256099942544/2521693316';

  static const String ERR_NO_UNIVERSE_FOUND = 'No universe found:';
  static const int DEFAULT_MAX_UPLOAD_FILE_SIZE = 10485760;
  static const double DEFAULT_CARD_WIDTH = 350;
  static const String DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_FADE = 'Fade';
  static const String DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_SLIDE = 'Slide';
  static const String DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_SCALE = 'Scale';
  static const String DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_ROTATION =
      'Rotation';
  static const String DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_SIZE = 'Size';
  static const String DEFAULT_PAGE_TRANSITION_TYPE_VALUE_FOR_HERO = 'Product';
  static const double DEFAULT_TIME_DILATION_VALUE_FOR_HYPER_SLOW = 50;
  static const double DEFAULT_TIME_DILATION_VALUE_FOR_ULTRA_SLOW = 30;
  static const double DEFAULT_TIME_DILATION_VALUE_FOR_MEGA_SLOW = 15;
  static const double DEFAULT_TIME_DILATION_VALUE_FOR_VERY_SLOW = 10;
  static const double DEFAULT_TIME_DILATION_VALUE_FOR_SLOW = 5;
  static const double DEFAULT_TIME_DILATION_VALUE_FOR_NORMAL = 1;
  static const double DEFAULT_TIME_DILATION_VALUE_FOR_FAST = 0.5;
  static const double DEFAULT_TIME_DILATION_VALUE_FOR_VERY_FAST = 0.1;
  static const int DEFAULT_CHECK_EVENT_EXECUTION_TIME_DELAY = 30000;
  static const int DEFAULT_UNDO_STACK_LENGTH = 8;
  static const int DEFAULT_MAX_ERRORS_LOADING_ADS = 10;
  static const int DEFAULT_DELAY_TO_TEST_SPEED = 2000;
  static const int DEFAULT_DELAY_TO_UPDATED_ENTITIES = 2000;
  static const int DEFAULT_DELAY_TO_SEARCH = 300;
  static const int DEFAULT_DELAY_TO_VALIDATE = 3000;
  static const int DEFAULT_DELAY_TO_GET_HEROES = 2000;
  static const int DEFAULT_DELAY_TO_ADD_CHOICES = 100;
  static const int DEFAULT_DELAY_TO_REFRESH_DATA = 2000;
  static const int DEFAULT_DELAY_TO_RETURN_TO_TOP = 2000;
  static const int DEFAULT_DELAY_TO_RECHECK_CONNECTION = 5000;
  static const int DEFAULT_DELAY_TO_RELOAD_HEROES_SUGGESTIONS = 5000;
  static const String DEFAULT_HERO_HERO_IMAGE_TAG = 'HERO_HERO_IMAGE_TAG';
  static const String DEFAULT_UNIVERSE_COLOR_CONTAINER_TAG =
      'UNIVERSE_COLOR_CONTAINER_TAG';
  static const String DEFAULT_STORY_COLOR_CONTAINER_TAG =
      'STORY_COLOR_CONTAINER_TAG';
  static const String PREFS_PAGE_TRANSITION_TYPE = 'page_transition_type';
  static const String DEFAULT_PAGE_TRANSITION_TYPE_VALUE = 'fade';
  static const String PREFS_CARD_TO_DETAILS_TRANSITION_TYPE =
      'card_to_details_transition_type';
  static const String DEFAULT_CARD_TO_DETAILS_TRANSITION_TYPE_VALUE = 'fade';
  static const String PREFS_TIME_DILATION = 'time_dilation';
  static const double DEFAULT_TIME_DILATION_VALUE = 1;
  static const String PREFS_ENABLE_CACHE = 'enable_cache';
  static const bool DEFAULT_ENABLE_CACHE_VALUE = true;
  static const String PREFS_ENABLE_CACHE_TTL = 'enable_cache_ttl';
  static const bool DEFAULT_ENABLE_CACHE_TTL_VALUE = false;
  static const String PREFS_CACHE_TTL_VALUE = 'cache_ttl_value';
  static const int DEFAULT_CACHE_TTL_VALUE = 0;
  static const String PREFS_ENABLE_CACHE_AUTO_UPDATE =
      'enable_cache_auto_update';
  static const bool DEFAULT_ENABLE_CACHE_AUTO_UPDATE_VALUE = true;
  static const String PREFS_CACHE_AUTO_UPDATE_INTERVAL =
      'cache_auto_update_interval';
  static const int DEFAULT_CACHE_AUTO_UPDATE_INTERVAL_VALUE = 900;
  static const String PREFS_ENABLE_COMPRESSION = 'enable_compression';
  static const bool DEFAULT_ENABLE_COMPRESSION_VALUE = true;
  static const String PREFS_COMPRESSION_LEVEL = 'compression_level';
  static const int DEFAULT_COMPRESSION_LEVEL_VALUE = 9;
  static const String PREFS_REMEMBER_ME = 'remember_me';
  static const bool DEFAULT_REMEMBER_ME_VALUE = true;
  static const String PREFS_USER_EMAIL = 'user_email';
  static const String PREFS_USER_PASSWORD = 'user_password';
  static const String PREFS_SENT_CONFIRM_CODE = 'sent_confirmation_code';
  static const int DEFAULT_SAVING_OR_UPDATING_MESSAGE_DELAY = 500;
  static const int DEFAULT_FORM_VALIDATION_DELAY = 1000;
  static const double AD_ANCHOR_OFFSET = 15;
  static const double AD_HORIZONTAL_CENTER_OFFSET = 0;
  static const Color DEFAULT_EXPANSION_TILE_ARROW_COLOR = Color(0xFF707070);
  static const double DEFAULT_APP_BAR_ICON_WIDTH_AND_HEIGHT = 26;
  static const double DEFAULT_SEARCH_FIELD_FONT_SIZE = 16;
  static const double DEFAULT_SOCIAL_ICONS_SPACING = 10;
  static const double DEFAULT_TAB_BAR_HEIGHT = 30;
  static const double DEFAULT_FACE_IMAGE_WIDTH = 100;
  static const double DEFAULT_FACE_IMAGE_HEIGHT = 100;
  static const double DEFAULT_HERO_IMAGE_WIDTH = 300;
  static const double DEFAULT_HERO_IMAGE_HEIGHT = 300;
  static const double DEFAULT_EDIT_ICON_WIDTH = 24;
  static const double DEFAULT_EDIT_ICON_HEIGHT = 24;
  static const double DEFAULT_SOCIAL_ICON_WIDTH = 100;
  static const double DEFAULT_SOCIAL_ICON_HEIGHT = 100;
  static const double DEFAULT_CONTACT_ICON_WIDTH = 100;
  static const double DEFAULT_CONTACT_ICON_HEIGHT = 100;
  static const double DEFAULT_CARD_FACE_IMAGE_WIDTH = 100;
  static const double DEFAULT_CARD_FACE_IMAGE_HEIGHT = 100;
  static const double DEFAULT_CARD_FACE_IMAGE_WIDTH_COMPAT = 50;
  static const double DEFAULT_CARD_FACE_IMAGE_HEIGHT_COMPAT = 50;
  static const double DEFAULT_CARD_BK_IMAGE_WIDTH = 640;
  static const double DEFAULT_CARD_BK_IMAGE_HEIGHT = 640;
  static const double DEFAULT_MY_PROFILE_IMAGE_WIDTH = 100;
  static const double DEFAULT_MY_PROFILE_IMAGE_HEIGHT = 100;
  static const double DEFAULT_GO_TO_ALL_HEROES_ICON_WIDTH = 35;
  static const double DEFAULT_GO_TO_ALL_HEROES_ICON_HEIGHT = 35;
  static const double DEFAULT_SHARE_ICON_WIDTH = 50;
  static const double DEFAULT_SHARE_ICON_HEIGHT = 50;
  static const double DEFAULT_FORM_PROGRESS_INDICATOR_PADDING = 5;
  static const double DEFAULT_FORM_PROGRESS_INDICATOR_WIDTH = 20;
  static const double DEFAULT_FORM_PROGRESS_INDICATOR_HEIGHT = 20;
  static const double DEFAULT_LIST_HEROES_HEIGHT = 500;
  static const double DEFAULT_ALL_COMMENTS_HEIGHT = 1000;
  static const double DEFAULT_TITLE_SPACING = 10;
  static const double DEFAULT_AD_BOTTOM_SPACE = !kIsWeb ? 45 : 195;
  static const double DEFAULT_MIN_FONT_SIZE = 4;
  static const double DEFAULT_MIN_FONT_SIZE_FOR_UPDATING_CACHE = 2;
  static const double DEFAULT_MIN_FONT_SIZE_FOR_RECHECK_CONNECTION = 2;
  static const int DEFAULT_DELAY_TO_GO_TO_HOME = 250;
  static const int DEFAULT_MAX_LINES = 3;
  static const int DEFAULT_MAX_LINES_FOR_UPDATING_CACHE = 2;
  static const int DEFAULT_MAX_LINES_FOR_RECHECK_CONNECTION = 1;
  static const int DEFAULT_AD_CACHE_INITIAL_SIZE = 5;
  static const int DEFAULT_AD_CACHE_MINIMAL_TO_CREATE = 1;
  static const int DEFAULT_AD_CACHE_THRESHOLD_TO_CLEAN = 10;
  static const int DEFAULT_AD_CACHE_THRESHOLD_TO_REMOVE = 3;
  static const int DEFAULT_CARD_BK_IMAGE_RESIZED = 640;
  static const int DEFAULT_LISTENER_AWAIT_TIMEOUT = 15000;
  static const int DEFAULT_SPACE_BETWEEN_ADS = 5;
  static const double DEFAULT_CARD_BK_IMAGE_ON_HOVER_OPACITY = 0.25;
  static const double DEFAULT_DROPDOWN_FACE_IMAGE_WIDTH = 25;
  static const double DEFAULT_DROPDOWN_FACE_IMAGE_HEIGHT = 25;
  static const double DEFAULT_APP_BAR_LOGO_WIDTH = 50;
  static const double DEFAULT_APP_BAR_LOGO_HEIGHT = 50;
  static const double DEFAULT_DRAWER_WIDTH = 250;
  static const double DEFAULT_DRAWER_HEADER_HEIGHT = 115;
  static const double APP_DRAWER_AVATAR_DEFAULT_WIDTH = 30;
  static const double APP_DRAWER_AVATAR_DEFAULT_HEIGHT = 30;
  static const double APP_DRAWER_AVATAR_DEFAULT_ICON_SIZE = 30;
  static const double DEFAULT_EDGE_INSETS_ALL_QUARTER = 4;
  static const double DEFAULT_EDGE_INSETS_ALL_HALF = 8;
  static const double DEFAULT_EDGE_INSETS_ALL = 16;
  static const double DEFAULT_EDGE_INSETS_LEFT = 16;
  static const double DEFAULT_EDGE_INSETS_RIGHT = 16;
  static const double DEFAULT_EDGE_INSETS_RIGHT_HALF = 8;
  static const double DEFAULT_EDGE_INSETS_VERTICAL = 16;
  static const double DEFAULT_EDGE_INSETS_VERTICAL_HALF = 8;
  static const double DEFAULT_EDGE_INSETS_VERTICAL_QUARTER = 4;
  static const double DEFAULT_BORDER_SPACE = 8;
  static const double DEFAULT_EDGE_INSETS_HORIZONTAL = 16;
  static const double DEFAULT_DRAWER_ITEM_HEIGHT = 20;
  static const double DEFAULT_CARD_COLOR_SQUARE_WIDTH = 50;
  static const double DEFAULT_CARD_COLOR_SQUARE_HEIGHT = 50;
  static const double DEFAULT_UNIVERSE_CARD_ASPECT_RATIO = 2.5 / 1;
  static const double DEFAULT_STORY_CARD_ASPECT_RATIO = 3 / 1;
  static const double DEFAULT_HERO_CARD_ASPECT_RATIO = 2.5 / 1;
  static const double DEFAULT_LIST_HERO_CARD_ASPECT_RATIO = 2.5 / 1;
  static const double DEFAULT_AD_CARD_ASPECT_RATIO = 4 / 1;
  static const int DEFAULT_CARD_CROSS_AXIS_COUNT = 1;
  static const double DEFAULT_CARD_MAIN_AXIS_SPACING = 5;
  static const double DEFAULT_CARD_CROSS_AXIS_SPACING = 5;
  static const Color DEFAULT_ELEMENTS_COLOR = Colors.blue;
  static const int DEFAULT_GET_IMAGE_TRY_LIMIT = 3;
  static const int DEFAULT_GET_FACE_IMAGE_TRY_LIMIT = 3;
  static const int DEFAULT_STAR_COUNT = 5;
  static const double DEFAULT_STAR_SIZE = 20;
  static const double DEFAULT_STAR_SIZE_DETAILS = 40;
  static const double DEFAULT_STAR_SPACING = 2;
  static const int DEFAULT_PAGE_SIZE_MOBILE = 3; //6
  static const int DEFAULT_PAGE_SIZE_WEB = DEFAULT_PAGE_SIZE_MOBILE * 2; //12
  static const int DEFAULT_SECONDS_TO_RELOAD_PAGE = 6;
  static const int DEFAULT_TRANSLATION_DELAY_TIME = 500;
  static const int DEFAULT_GET_MY_UNIVERSES_DELAY_TIME = 4000;
  static const int DEFAULT_SCROLL_TO_BOTTOM_DELAY = 1000;
  static const String FIREBASE_STORAGE_BASE_URL =
      'firebasestorage.googleapis.com';
  static const String FIREBASE_BUCKET_BASE_URL =
      'little_drops_of_rain_flutter-firebase.appspot.com';
  static const String DEFAULT_APP_FONT_FAMILY = 'Arial';
  static const String DEFAULT_HERO_CODENAME_CARD_FONT_FAMILY =
      'CartoonistKooky';
  static const String FILE_METADATA_KEY_FILE_PATH = 'picked-file-path';
  static const String FILE_METADATA_KEY_ORIGINAL_NAME = 'original-name';
  static const String FILE_METADATA_KEY_WIDTH = 'width';
  static const String FILE_METADATA_KEY_HEIGHT = 'height';
}
