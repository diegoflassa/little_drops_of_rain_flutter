import 'dart:async';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:auto_size_text/auto_size_text.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_svg/flutter_svg.dart';

import 'package:little_drops_of_rain_flutter/enums/element_type.dart';
import 'package:little_drops_of_rain_flutter/extensions/build_context_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/images_cache.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/helpers/text_editing_controller_workaround.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/interfaces/on_cache_update_callback.dart';
import 'package:little_drops_of_rain_flutter/interfaces/on_order_by_change.dart';
import 'package:little_drops_of_rain_flutter/models/my_scaffold_model.dart';
import 'package:little_drops_of_rain_flutter/network/connection_status_singleton.dart';
import 'package:little_drops_of_rain_flutter/resources/resources.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_color_scheme.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_text_style.dart';
import 'package:pedantic/pedantic.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

typedef OnNewQueryCallback = void Function(String newQuery);

class MyScaffold extends StatefulWidget {
  const MyScaffold({
    Key? key,
    this.appBar,
    this.hasAppBar = true,
    this.appDrawer,
    this.hasDrawer = true,
    this.hasOrderBy = false,
    this.body,
    this.title = Constants.APP_NAME,
    this.isSearchMode = false,
    this.elementType = ElementType.UNKNOWN,
    this.onNewQuery,
    this.onOrderByChange,
  }) : super(key: key);

  final AppBar? appBar;
  final bool hasAppBar;
  final Widget? appDrawer;
  final bool hasDrawer;
  final bool hasOrderBy;
  final Widget? body;
  final String? title;
  final bool isSearchMode;
  final ElementType elementType;
  final OnNewQueryCallback? onNewQuery;
  final OnOrderByChange? onOrderByChange;

  @override
  _MyScaffoldState createState() => _MyScaffoldState();
}

// 🚀Global Functional Injection
// This state will be auto-disposed when no longer used, and also testable and mockable.
final myScaffoldModel = RM.inject<MyScaffoldModel>(
      () => MyScaffoldModel(),
  undoStackLength: Constants.DEFAULT_UNDO_STACK_LENGTH,
  //Called after new state calculation and just before state mutation
  middleSnapState: (middleSnap) {
    //Log all state transition.
    MyLogger().logger.i(middleSnap.currentSnap);
    MyLogger().logger.i(middleSnap.nextSnap);

    MyLogger().logger.i('');
    middleSnap.print(preMessage: '[MyScaffoldModel]'); //Build-in logger
    //Can return another state
  },
  onDisposed: (state) => MyLogger().logger.i('[MyScaffoldModel]Disposed'),
);

class _MyScaffoldState extends State<MyScaffold>
    with TickerProviderStateMixin
    implements OnCacheUpdateCallback {
  StreamSubscription<dynamic>? _connectionChangeStream;
  late AnimationController _rotationController;
  static const POPUP_MENU_ITEM_LICENSES = 'licenses';
  static const POPUP_MENU_ITEM_SETTINGS = 'settings';
  static const POPUP_MENU_ITEM_CONSOLE = 'console';
  static const POPUP_MENU_ITEM_PERFORMANCE_OVERLAY = 'performance_overlay';
  static const POPUP_MENU_ITEM_MATERIAL_GRID = 'material_grid';
  static const POPUP_MENU_ITEM_SEMANTICS_DEBUGGER = 'semantics_debugger';
  bool _isUpdatingCache = false;
  int _updateQuantity = 0;
  int _updateCurrent = 0;
  int? _timeToRecheck;
  Timer? _timeToRecheckValueUpdater;

  final _focusNodeSearchField = FocusNode();
  late TextEditingControllerWorkaround _searchQueryController;
  bool _isSearching = false;


  void _selectPopupMenu(Choice choice) {
    // Causes the app to rebuild with the new _selectedChoice.
    switch (choice.tag) {
      case POPUP_MENU_ITEM_LICENSES:
        {
          showLicensePage(
              context: context,
              applicationName: AppLocalizations
                  .of(context)
                  .appName);
        }
        break;
      case POPUP_MENU_ITEM_SETTINGS:
        {
          Navigator.of(context).pushNamed(Routes.settings);
        }
        break;
      case POPUP_MENU_ITEM_CONSOLE:
        {
          if (kDebugMode || kProfileMode) {
            //LogConsole.init();
            Navigator.of(context).pushNamed(Routes.console);
          }
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    // Exhaustively handle all four status
    On.all(
      // If is Idle
      onIdle: () => MyLogger().logger.i('[MyScaffoldModel]Idle'),
      // If is waiting
      onWaiting: () => MyLogger().logger.i('[MyScaffoldModel]Waiting'),
      // If has error
      onError: (dynamic err, refresh) =>
          MyLogger().logger.e('[MyScaffoldModel]Error:$err. Refresh:$refresh'),
      // If has Data
      onData: () => MyLogger().logger.i('[MyScaffoldModel]Data'),
    );

    if (!ImagesCache.hasListener(this)) {
      ImagesCache.registerListener(this);
    }
    _rotationController = AnimationController(
        duration: const Duration(milliseconds: 5000), vsync: this);
    _searchQueryController = TextEditingControllerWorkaround();
    Future<void>.delayed(
        const Duration(milliseconds: Constants.DEFAULT_DELAY_TO_ADD_CHOICES),
            () {
          choices.add(Choice(
              tag: POPUP_MENU_ITEM_LICENSES,
              title: AppLocalizations
                  .of(context)
                  .licenses,
              icon: Icons.settings));
          choices.add(Choice(
              tag: POPUP_MENU_ITEM_SETTINGS,
              title: AppLocalizations
                  .of(context)
                  .settings,
              icon: Icons.settings));
          if (kDebugMode || kProfileMode) {
            choices.add(Choice(
                tag: POPUP_MENU_ITEM_CONSOLE,
                title: AppLocalizations
                    .of(context)
                    .console,
                icon: Icons.settings));

            choices.add(Choice(
                tag: POPUP_MENU_ITEM_PERFORMANCE_OVERLAY,
                title: AppLocalizations
                    .of(context)
                    .performanceOverlay,
                icon: Icons.settings));

            choices.add(Choice(
                tag: POPUP_MENU_ITEM_MATERIAL_GRID,
                title: AppLocalizations
                    .of(context)
                    .materialGrid,
                icon: Icons.settings));

            choices.add(Choice(
                tag: POPUP_MENU_ITEM_SEMANTICS_DEBUGGER,
                title: AppLocalizations
                    .of(context)
                    .semanticsDebugger,
                icon: Icons.settings));
          }
        });
    final connectionStatus = ConnectionStatusSingleton.getInstance()
      ..initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    _connectionChangeStream?.cancel();
    _rotationController.dispose();
    ImagesCache.removeListener(this);
    _timeToRecheckValueUpdater?.cancel();
    super.dispose();
  }

  void connectionChanged(dynamic hasConnection) {
    if (mounted) {
      setState(() {
        MyLogger().logger.i('Setting connected to : $hasConnection');
        myScaffoldModel.state.isConnected = hasConnection as bool;
        if (!myScaffoldModel.state.isConnected) {
          unawaited(FirebaseFirestore.instance.disableNetwork());
          Navigator.pushNamed(context,
              Routes.getParameterizedRouteByViewElements(ElementType.PRODUCT));
          if (_timeToRecheckValueUpdater != null) {
            _timeToRecheckValueUpdater!.cancel();
            _timeToRecheckValueUpdater = null;
          }

          if (_timeToRecheck == null) {
            _timeToRecheck = 5;
            _timeToRecheckValueUpdater ??= Timer.periodic(
                const Duration(seconds: 1), _updateTimeToRecheck);
          }
        } else {
          unawaited(FirebaseFirestore.instance.enableNetwork());
          if (_timeToRecheckValueUpdater != null) {
            _timeToRecheckValueUpdater!.cancel();
            _timeToRecheckValueUpdater = null;
            _timeToRecheck = null;
          }
        }
      });
    }
  }

  void _updateTimeToRecheck(Timer timer) {
    if (context.isCurrent(this)) {
      if (_timeToRecheck != null) {
        if (mounted) {
          setState(() {
            if (_timeToRecheck! > 0) {
              _timeToRecheck = _timeToRecheck! - 1;
            } else {
              _timeToRecheck = 6;
            }
          });
        }
      } else {
        _timeToRecheck = 6;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            systemNavigationBarColor: MyColorScheme().primary,
            statusBarBrightness: Brightness.dark,
            statusBarColor: MyColorScheme().primary),
      );
    }
    return SafeArea(
      child: Scaffold(
          appBar: widget.hasAppBar
              ? (widget.appBar == null)
              ? AppBar(
            backwardsCompatibility: false,
            systemOverlayStyle: SystemUiOverlayStyle(
                systemNavigationBarColor: MyColorScheme().primary,
                statusBarBrightness: Brightness.dark,
                statusBarColor: MyColorScheme().primary),
            backgroundColor: MyColorScheme().primary,
            brightness: Brightness.dark,
            title: widget.isSearchMode
                ? _buildSearchField(context)
                : _getAppBarLogoAndTitle(),
            actions: _buildActions(),
          )
              : widget.appBar
              : null,
          drawer: widget.hasDrawer
              ? (widget.appDrawer == null)
              ? AppDrawer(isConnected: myScaffoldModel.state.isConnected)
              : widget.appDrawer
              : null,
          body: (widget.body != null) ? widget.body! : _getEmptyBody(context)),
    );
  }

  Widget _getAppBarLogoAndTitle() {
    return Row(children: <Widget>[
      Image.asset(Images.littleDropsOfRainIcon,
          width: Constants.DEFAULT_APP_BAR_LOGO_WIDTH,
          height: Constants.DEFAULT_APP_BAR_LOGO_HEIGHT,
          cacheWidth: Constants.DEFAULT_APP_BAR_LOGO_WIDTH.toInt(),
          cacheHeight: Constants.DEFAULT_APP_BAR_LOGO_HEIGHT.toInt(),
          fit: BoxFit.contain,
          alignment: FractionalOffset.center),
      const SizedBox(height: 1, width: Constants.DEFAULT_BORDER_SPACE),
      if (kIsWeb && MediaQuery
          .of(context)
          .size
          .width > 500)
        Text((widget.title != null) ? widget.title! : ''),
    ]);
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      autofocus: true,
      focusNode: _focusNodeSearchField,
      cursorColor: Colors.white,
      controller: _searchQueryController,
      decoration: InputDecoration(
        hintText: AppLocalizations
            .of(context)
            .searchProduct,
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(
          color: Colors.white,
          fontSize: Constants.DEFAULT_SEARCH_FIELD_FONT_SIZE),
      onChanged: _onQueryChanged,
    );
  }

  void _onQueryChanged(String newQuery) {
    setState(() {
      if (widget.onNewQuery != null) {
        widget.onNewQuery!(newQuery);
      }
    });
  }

  List<Widget> _buildActions() {
    final ret = <Widget>[];
    if (widget.isSearchMode) {
      if (_isSearching) {
        ret.add(
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              if (_searchQueryController.text.isEmpty) {
                Navigator.pop(context);
                return;
              }
              _clearSearchQuery();
            },
          ),
        );
      } else {
        ret.add(
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          ),
        );
      }
    }

    ret.add(
      const SizedBox(
        width: 10,
      ),
    );

     if (!widget.isSearchMode) {
      ret.add(
        Padding(
          padding: const EdgeInsets.only(
              right: Constants.DEFAULT_EDGE_INSETS_RIGHT_HALF),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(Routes.search);
            },
            child: const Icon(
              Icons.search,
              size: Constants.DEFAULT_APP_BAR_ICON_WIDTH_AND_HEIGHT,
            ),
          ),
        ),
      );
    }

    _isUpdatingCache
        ? ret.add(
      Padding(
        padding: const EdgeInsets.only(
            right: Constants.DEFAULT_EDGE_INSETS_RIGHT_HALF),
        child: GestureDetector(
          onTap: () {},
          child: Tooltip(
            message:
            '${_updateCurrent.toString()}/${_updateQuantity.toString()}',
            child: Center(
              child: Stack(
                children: <Widget>[
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0)
                        .animate(_rotationController),
                    child: const Icon(
                      Icons.refresh,
                      size:
                      Constants.DEFAULT_APP_BAR_ICON_WIDTH_AND_HEIGHT,
                    ),
                  ),
                  SizedBox(
                    width:
                    Constants.DEFAULT_APP_BAR_ICON_WIDTH_AND_HEIGHT,
                    height:
                    Constants.DEFAULT_APP_BAR_ICON_WIDTH_AND_HEIGHT,
                    child: Center(
                      child: AutoSizeText(
                        '${_updateCurrent.toString()}/${_updateQuantity
                            .toString()}',
                        style: const MyTextStyle.blackBold(),
                        minFontSize: Constants
                            .DEFAULT_MIN_FONT_SIZE_FOR_UPDATING_CACHE,
                        maxLines: Constants
                            .DEFAULT_MAX_LINES_FOR_UPDATING_CACHE,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    )
        : ret.add(const SizedBox(height: 1, width: 1));

    if (!myScaffoldModel.state.isConnected) {
      ret.add(_getNoConnectionIcon());
    }

    ret.add(
      PopupMenuButton<Choice>(
        onSelected: _selectPopupMenu,
        itemBuilder: (context) {
          return choices.map(
                (choice) {
              return PopupMenuItem<Choice>(
                value: choice,
                child: Text(choice.title),
              );
            },
          ).toList();
        },
      ),
    );

    return ret;
  }

  Center _getNoConnectionIcon() {
    return Center(
      child: Stack(
        children: <Widget>[
          SvgPicture.asset('assets/images/font_awesome/solid/wifi.svg',
              color: Colors.white,
              placeholderBuilder: (context) =>
              const SizedBox(
                  width: 25,
                  height: 25,
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CircularProgressIndicator())),
              width: 25,
              height: 25),
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: SvgPicture.asset('assets/images/font_awesome/solid/ban.svg',
                color: Colors.brown,
                placeholderBuilder: (context) =>
                const SizedBox(
                    width: 25,
                    height: 25,
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: CircularProgressIndicator())),
                width: 25,
                height: 25),
          ),
          SizedBox(
            width: Constants.DEFAULT_APP_BAR_ICON_WIDTH_AND_HEIGHT,
            height: Constants.DEFAULT_APP_BAR_ICON_WIDTH_AND_HEIGHT,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Center(
                child: AutoSizeText(
                  '${(_timeToRecheck != null) ? _timeToRecheck : 0}s',
                  style: const MyTextStyle.blackBold(),
                  minFontSize:
                  Constants.DEFAULT_MIN_FONT_SIZE_FOR_RECHECK_CONNECTION,
                  maxLines: Constants.DEFAULT_MAX_LINES_FOR_RECHECK_CONNECTION,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startSearch() {
    ModalRoute.of(context)
        ?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching = true;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      if (widget.onNewQuery != null) {
        widget.onNewQuery!('');
      }
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  Widget _getEmptyBody(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Text(AppLocalizations
            .of(context)
            .empty),
      ),
    );
  }

  List<Choice> choices = <Choice>[];

  @override
  void updateEnd() {
    setState(() {
      _isUpdatingCache = false;
      _rotationController.stop();
    });
  }

  @override
  void updateProgress(int current, int quantity) {
    _updateCurrent = current;
  }

  @override
  void updateStart(int quantity) {
    setState(() {
      _rotationController.repeat();
      _isUpdatingCache = true;
      _updateQuantity = quantity;
    });
  }
}

class Choice {
  const Choice({this.tag = '', this.title = '', this.icon});

  final String tag;
  final String title;
  final IconData? icon;
}
