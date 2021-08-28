import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:keyboard_visibility/keyboard_visibility.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:language_pickers/language_pickers.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:language_pickers/languages.dart';
import 'package:pedantic/pedantic.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:little_drops_of_rain_flutter/ads/ad_helper_mixin.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/stories_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/universes_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/states/stories_states.dart';
import 'package:little_drops_of_rain_flutter/bloc/states/universes_states.dart';
import 'package:little_drops_of_rain_flutter/bloc/stories_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/stories_listener_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/universes_listener_bloc.dart';
import 'package:little_drops_of_rain_flutter/data/dao/products_dao.dart';
import 'package:little_drops_of_rain_flutter/data/dao/universes_dao.dart';
import 'package:little_drops_of_rain_flutter/data/entities/story.dart';
import 'package:little_drops_of_rain_flutter/data/entities/universe.dart';
import 'package:little_drops_of_rain_flutter/enums/element_type.dart';
import 'package:little_drops_of_rain_flutter/enums/name_validation_result.dart';
import 'package:little_drops_of_rain_flutter/enums/order_by.dart';
import 'package:little_drops_of_rain_flutter/enums/page_mode.dart';
import 'package:little_drops_of_rain_flutter/extensions/build_context_extensions.dart';
import 'package:little_drops_of_rain_flutter/extensions/document_extensions.dart';
import 'package:little_drops_of_rain_flutter/extensions/list_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/dialogs.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/logged_user.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/helpers/little_drops_of_rain_flutter_icons.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/models/create_story_model.dart';
import 'package:little_drops_of_rain_flutter/real_main.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:little_drops_of_rain_flutter/routing/routing_data.dart';
import 'package:little_drops_of_rain_flutter/ui/comments/all_comments_widget.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/error_page.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_color_scheme.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_text_style.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/overlaid_product_suggestions.dart';
import 'package:little_drops_of_rain_flutter/universal_ui/universal_ui.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class StoryForm extends StatefulWidget {
  StoryForm(this.story, this.state, this.pageMode, this.routingData,
      {Key? key, this.clearForm = false})
      : super(key: key);

  final Story story;
  final StoriesStates state;
  PageMode pageMode;
  final RoutingData routingData;
  final bool clearForm;

  @override
  _StoryFormState createState() => _StoryFormState();
}

// 🚀Global Functional Injection
// This state will be auto-disposed when no longer used, and also testable and mockable.
final model = RM.inject<CreateStoryModel>(
  () => CreateStoryModel(),
  undoStackLength: Constants.DEFAULT_UNDO_STACK_LENGTH,
  //Called after new state calculation and just before state mutation
  middleSnapState: (middleSnap) {
    //Log all state transition.
    MyLogger().logger.i(middleSnap.currentSnap);
    MyLogger().logger.i(middleSnap.nextSnap);

    MyLogger().logger.i('');
    middleSnap.print(preMessage: '[CreateStoryModel]'); //Build-in logger
    //Can return another state
  },
  onDisposed: (state) => MyLogger().logger.i('[CreateStoryModel]Disposed'),
);

class _StoryFormState extends State<StoryForm>
    with TickerProviderStateMixin, AdHelperMixin {
  final _formKey = GlobalKey<FormState>();

  void _changeLanguage(Language language) => _updatePickedLanguage(language);
  final TextEditingController _controllerTitle =
      TextEditingController(text: '');
  final TextEditingController _controllerLanguage = TextEditingController();
  final _scrollControllerQuill = ScrollController(initialScrollOffset: 5);
  var _scrollController = ScrollController(initialScrollOffset: 5);
  var _controllerQuill = quill.QuillController.basic();
  late TabController _tabController;
  final List<TabController> _tabControllers = <TabController>[];
  Universe? _selectedUniverse;
  final FocusNode _focusNodeQuill = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  bool _saveEnabled = true;
  bool _hasShowPleaseLogin = false;
  bool _storyViewsUpdated = false;
  String _universeName = '';
  List<Universe> _universes = <Universe>[];
  final List<Tab> _tabs = [];
  int _tabIndex = 0;
  Container? _bannerAd;
  Timer? _timerValidateTitleDebouncer;
  final KeyboardVisibilityNotification _keyboardVisibility =
      KeyboardVisibilityNotification();
  int _keyboardVisibilitySubscriberId = 0;
  bool _isGettingUniverses = false;

  @override
  void initState() {
    super.initState();
    // Exhaustively handle all four status
    On.all(
      // If is Idle
      onIdle: () => MyLogger().logger.i('[CreateStoryModel]Idle'),
      // If is waiting
      onWaiting: () => MyLogger().logger.i('[CreateStoryModel]Waiting'),
      // If has error
      onError: (dynamic err, refresh) =>
          MyLogger().logger.e('[CreateStoryModel]Error:$err. Refresh:$refresh'),
      // If has Data
      onData: () => MyLogger().logger.i('[CreateStoryModel]Data'),
    );

    if (widget.clearForm) {
      _clearForm();
    }

    _storyViewsUpdated = false;
    if (!kIsWeb) {
      getBannerAd().then((value) {
        setState(() {
          _bannerAd = value;
        });
      });
    }
    var tabController = TabController(length: 1, vsync: this);
    _tabControllers.add(tabController);
    tabController = TabController(length: 2, vsync: this);
    _tabControllers.add(tabController);
    _tabController = tabController;
    _generateTabs(dummy: true);
    if (widget.pageMode == PageMode.CREATE) {
      _controllerLanguage.text =
          LanguagePickerUtils.getLanguageByIsoCode(MyApp.locale.languageCode)
              .name;
      model.state.story.language = (model.state.story.language.isNotEmpty)
          ? model.state.story.language
          : _controllerLanguage.text;
    }
    if (widget.pageMode != PageMode.CREATE ||
        widget.pageMode != PageMode.EDIT && !widget.clearForm) {
      _controllerTitle.text = model.state.story.title;
      if (model.state.story.story.isNotEmpty) {
        _controllerQuill = quill.QuillController(
            document: quill.Document.fromJson(
                jsonDecode(model.state.story.story) as List<dynamic>),
            selection: const TextSelection.collapsed(offset: 0));
      }
      _controllerLanguage.text = model.state.story.language;
    }
    if (widget.state is StorySavedState || widget.state is StoryUpdatedState) {
      _saveEnabled = true;
    }
    _addListeners();
  }

  @override
  void dispose() {
    _controllerTitle.dispose();
    _controllerLanguage.dispose();
    _controllerQuill.dispose();
    _tabControllers.forEach((controller) => controller.dispose());
    _scrollController.dispose();
    _focusNodeQuill.dispose();
    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
    _keyboardVisibility.dispose();
    if (!kIsWeb && _bannerAd != null) {
      _bannerAd = null;
      disposeAd();
    }
    super.dispose();
  }

  void _addListeners() {
    _controllerLanguage.addListener(() {
      model.state.story.language = _controllerLanguage.text;
    });
    _controllerQuill.addListener(() {
      model.state.story.story =
          jsonEncode(_controllerQuill.document.toDelta().toJson());
    });
    _controllerTitle.addListener(_onTitleChangedListener);

    if (!kIsWeb) {
      _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
        onChange: (visible) {
          if (visible && _tabIndex == 0) {
            setState(() {
              _scrollController = ScrollController(
                  initialScrollOffset: _scrollController.position.pixels +
                      ((_bannerAd!.child as AdWidget?)!.ad as BannerAd)
                          .size
                          .height +
                      150);
            });
          }
        },
      );
    }
  }

  void _clearForm() {
    _controllerTitle.clear();
    _controllerQuill = quill.QuillController(
        document: quill.Document(),
        selection: const TextSelection.collapsed(offset: 0));
    _controllerLanguage.clear();
    model.state.pickedColor = Constants.DEFAULT_ELEMENTS_COLOR;
    model.state.clear();
  }

  void _tabControllerListener() {
    MyLogger().logger.i('Selected tab${_tabController.index}');
    setState(() {
      _tabIndex = _tabController.index;
    });
  }

  bool _isPageReadOnly() {
    return widget.pageMode == PageMode.VIEW;
  }

  void _updatePickedColor(Color color) {
    setState(() {
      model.state.pickedColor = color;
      widget.story.color = color.toString();
    });
  }

  void _updatePickedLanguage(Language language) {
    setState(() {
      widget.story.language = language.name;
      _controllerLanguage.text = language.name;
    });
  }

  void _onTitleChangedListener() {
    if (_selectedUniverse != null &&
        _validateTitle() &&
        context.isCurrent(this)) {
      if (_controllerTitle.text.isNotEmpty &&
          _controllerTitle.text != model.state.story.title) {
        model.state.story.title = _controllerTitle.text;
        model.state.scrollPosition = _scrollController.position.pixels;
        if (_timerValidateTitleDebouncer != null) {
          _timerValidateTitleDebouncer!.cancel();
        }
        _timerValidateTitleDebouncer = Timer(
            const Duration(milliseconds: Constants.DEFAULT_DELAY_TO_VALIDATE),
            () {
          BlocProvider.of<StoriesBloc>(context).add(ValidateStoryTitleEvent(
              Constants.DEFAULT_HEROESBOOK_URL + _controllerTitle.text,
              _selectedUniverse!.uid!));
        });
      }
    }
  }

  Future<void> _onLaunchUrl(String url) async {
    if (kIsWeb) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        //throw 'Could not launch $url';
      }
    } else {
      final uri = Uri.parse(url);
      String? productUniverse;
      String? productCodename;
      if (uri.pathSegments.length == 2) {
        productUniverse = uri.pathSegments[uri.pathSegments.length - 2];
        productCodename = uri.pathSegments[uri.pathSegments.length - 1];
      }
      if (productCodename != null && productUniverse != null) {
        final universe = await UniversesDao().getByName(productUniverse);
        final products = await ProductsDao().getByCodeName(productCodename,
            universeUID: (universe != null) ? universe.uid : null);
        final ret = products.isNotEmpty ? products[0] : null;
        if (ret != null) {
          if (mounted) {
            unawaited(Navigator.of(context)
                .pushNamed(Routes.getParameterizedRouteForViewProduct(ret)));
          }
        } else {
          if (mounted) {
            Helper.showSnackBar(context,
                '${AppLocalizations.of(context).noProductFound} $productCodename');
          }
        }
      } else {
        if (mounted) {
          Helper.showSnackBar(
              context, '${AppLocalizations.of(context).invalidLink} $url');
        }
      }
    }
  }

  bool _universesBuildWhenFilter(
      UniversesStates previousSate, UniversesStates currentState) {
    return (previousSate != currentState) &&
        (currentState is GotMyUniversesState) &&
        !_isPageReadOnly() &&
        _universes.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (!LoggedUser().hasUser() && !_hasShowPleaseLogin && !_isPageReadOnly()) {
      _hasShowPleaseLogin = true;
      Future.delayed(const Duration(seconds: 3), () {
        Helper.showSnackBar(context, AppLocalizations.of(context).pleaseLogIn);
      });
    }
    _generateTabs();
    Widget ret = ErrorPage(
        exception: Exception(
            '${AppLocalizations.of(context).stateNotSupportedError}: ${widget.state.toString()}'));

    if (widget.state is StoriesInitialState ||
        widget.state is GotStoriesByTitleState ||
        widget.state is GotStoryState ||
        widget.state is StoryTranslatedState ||
        widget.state is ValidatedStoryTitleState ||
        widget.state is StoryViewsUpdatedState ||
        widget.state is StoryViewsIncrementedState ||
        widget.state is StorySavedState ||
        widget.state is StoryUpdatedState ||
        widget.pageMode == PageMode.CREATE) {
      if (widget.state is StoryTranslatedState) {
        final state = widget.state as StoryTranslatedState;
        _controllerQuill = quill.QuillController(
            document: DocumentExtensions.fromPlainText(state.story.story),
            selection: const TextSelection.collapsed(offset: 0));
      }

      if (LoggedUser().hasUser() && !_isPageReadOnly() && _universes.isEmpty) {
        _getMyUniverses(context, Constants.DEFAULT_GET_MY_UNIVERSES_DELAY_TIME);
      }

      if (widget.story.story.isNotEmpty &&
          (widget.state is StoryTranslatedState)) {
        final state = widget.state as StoryTranslatedState;
        _controllerQuill = quill.QuillController(
            document: quill.Document.fromJson(
                jsonDecode(state.story.story) as List<dynamic>),
            selection: const TextSelection.collapsed(offset: 0));
      }

      if (widget.state is GotStoriesByTitleState ||
          widget.state is GotStoryState ||
          widget.pageMode == PageMode.VIEW) {
        _selectedUniverse = widget.story.universe;

        if (widget.pageMode == PageMode.VIEW) {
          if (_selectedUniverse != null) {
            _universes.addAllUnique([_selectedUniverse!]);
          }
          if (!_storyViewsUpdated &&
              widget.story.uid != null &&
              context.isCurrent(this)) {
            _storyViewsUpdated = true;
            BlocProvider.of<StoriesBloc>(context)
                .add(IncrementStoryViewsEvent(widget.story.uid!));
          }
        }
        if (model.state.previousStory != widget.story) {
          model.state.previousStory = widget.story;
          _controllerTitle.text = widget.story.title;
          _controllerLanguage.text = widget.story.language;
          model.state.pickedColor = widget.story.getColorObject();
        }
      }

      if (widget.state is ValidatedStoryTitleState) {
        final state = widget.state as ValidatedStoryTitleState;
        Future.delayed(
            const Duration(
                milliseconds: Constants.DEFAULT_FORM_VALIDATION_DELAY),
            () => _formKey.currentState?.validate());
        if (!state.isValid) {
          _saveEnabled = true;
          _titleFocusNode.requestFocus();
        } else if (model.state.shouldSave) {
          _saveStory();
        }
      }

      ret = Padding(
        padding: const EdgeInsets.all(Constants.DEFAULT_EDGE_INSETS_ALL),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(
                Size(640, MediaQuery.of(context).size.height)),
            child: Form(
              key: _formKey,
              child: Scrollbar(
                controller: _scrollController,
                isAlwaysShown: kIsWeb,
                child: ListView(
                  controller: _scrollController,
                  shrinkWrap: true,
                  children: <Widget>[
                    if (_isPageReadOnly()) _getColorProduct(),
                    const SizedBox(height: 5),
                    _getTitleWidget(widget.state),
                    _getTabBar(),
                    _getTabBarView(),
                    const SizedBox(
                        height: Constants.DEFAULT_AD_BOTTOM_SPACE, width: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (ret is ErrorPage) {
      MyLogger().logger.e(
          '[StoryForm]Error page for state: ${widget.state.toString()}, pageMode:${widget.pageMode}. Exception: ${ret.exception.toString()}');
    }
    if (_bannerAd != null) {
      ret = Stack(alignment: Alignment.bottomCenter, children: <Widget>[
        Container(height: MediaQuery.of(context).size.height),
        ret,
        _bannerAd!
      ]);
    }
    return ret;
  }

  void _generateTabs({bool dummy = false}) {
    _tabs.clear();
    _tabs.add(
      Tab(
        icon: Icon(FontAwesome5.user_tie, color: MyColorScheme().onPrimary),
        child: dummy
            ? const Text('Details')
            : Text(AppLocalizations.of(context).details,
                style: const MyTextStyle.tabText()),
      ),
    );
    if (_isPageReadOnly()) {
      _tabs.add(
        Tab(
          icon: Icon(FontAwesome5.envelope_open,
              color: MyColorScheme().onPrimary),
          child: dummy
              ? const Text('Comments')
              : Text(
                  AppLocalizations.of(context).comments,
                  style: const MyTextStyle.tabText(),
                ),
        ),
      );
    }
    _tabController.removeListener(_tabControllerListener);
    _tabController = _tabControllers[_tabs.length - 1];
    _tabController.addListener(_tabControllerListener);
  }

  Widget _getTabBar() {
    return Material(
      color: MyColorScheme().primary,
      child: TabBar(
        tabs: _tabs,
        indicatorColor: Colors.black,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        onTap: (index) {
          // Should not used it as it only called when tab options are clicked,
          // not when user swapped
          MyLogger().logger.i('Selected index: $index');
        },
      ),
    );
  }

  void checkEventExecutionTime() {
    model.state.checkEventExecutionTimeTimer?.cancel();
    model.state.checkEventExecutionTimeTimer = Timer(
        const Duration(
            milliseconds: Constants.DEFAULT_CHECK_EVENT_EXECUTION_TIME_DELAY),
        () {
      if (model.state.lastEvent != null) {
        Helper.showSnackBar(context,
            AppLocalizations.of(context).looksLikeItIsTakingALongTimeRetrying);
        BlocProvider.of<UniversesListenerBloc>(context)
            .add(model.state.lastEvent!);
      } else {
        Helper.showSnackBar(context,
            AppLocalizations.of(context).looksLikeItIsTakingALongTimeReload);
      }
    });
  }

  Widget _getTabBarView() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL,
          horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
      child: [
        _getDetailsTabBody(),
        if (_isPageReadOnly()) _getCommentsTabBody(),
      ][_tabIndex],
    );
  }

  Column _getDetailsTabBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _getLanguageWidget(),
        if (_isPageReadOnly())
          _getUniversePadding()
        else
          _getUniversesBlocBuilder(),
        _getCreateUniverseWidget(),
        const SizedBox(height: 10),
        ..._getStoryWidget(),
        const SizedBox(height: 10),
        _getPickColorRow(),
        _getPublishedWidget(),
        _getSaveStoryWidget(widget.state),
        _getDeleteStoryWidget(),
      ],
    );
  }

  Widget _getCommentsTabBody() {
    return _getAllCommentsWidget();
  }

  bool _validateTitle() {
    return _controllerTitle.text.isNotEmpty &&
        (widget.pageMode == PageMode.CREATE);
  }

  Widget _getTitleWidget(StoriesStates state) {
    Widget ret;
    if (_isPageReadOnly() || widget.pageMode == PageMode.EDIT) {
      ret = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
          child: Text(
            widget.story.title,
            style: const TextStyle(
                fontSize: 30,
                fontFamily: Constants.DEFAULT_HERO_CODENAME_CARD_FONT_FAMILY),
          ),
        ),
      );
    } else {
      ret = TextFormField(
        focusNode: _titleFocusNode,
        decoration: _getInputDecoration(AppLocalizations.of(context).storyTitle,
            AppLocalizations.of(context).title),
        controller: _controllerTitle,
        readOnly: _isPageReadOnly(),
        validator: (widget.pageMode == PageMode.CREATE)
            ? (value) {
                String? ret;
                if (_validateTitle()) {
                  if (state is ValidatedStoryTitleState) {
                    switch (state.validationResult) {
                      case NameValidationResult.VALID:
                        if (value != null) {
                          widget.story.title = value;
                        }
                        ret = null;
                        break;
                      case NameValidationResult.INVALID_EMPTY:
                        ret = AppLocalizations.of(context).theCodenameIsEmpty;
                        break;
                      case NameValidationResult.INVALID_ALREADY_EXISTS:
                        ret = AppLocalizations.of(context)
                            .pleaseSelectAnotherCodename;
                        break;
                      case NameValidationResult.INVALID_CHARACTERS:
                        ret =
                            '${AppLocalizations.of(context).invalidCharacters} ${state.characters}';
                        break;
                      case NameValidationResult.UNKNOWN:
                        ret = AppLocalizations.of(context).errorUnknown;
                    }
                  } else {
                    if (value == null || value.isEmpty) {
                      ret = AppLocalizations.of(context).storyTitle;
                    } else {
                      widget.story.title = value;
                      ret = null;
                    }
                  }
                }
                return ret;
              }
            : null,
      );
    }
    return ret;
  }

  Widget _getLanguageWidget() {
    Widget ret;
    if (_isPageReadOnly()) {
      ret = Text(
          '${AppLocalizations.of(context).language}:${widget.story.language}');
    } else {
      ret = Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: _controllerLanguage,
              readOnly: true,
              decoration: _getInputDecoration(
                  AppLocalizations.of(context).language,
                  AppLocalizations.of(context).language),
              validator: (value) {
                return null;
              },
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          if (!_isPageReadOnly())
            ElevatedButton(
              onPressed: () {
                Dialogs.showLanguagePickerDialog(context, _changeLanguage);
              },
              child: Text(AppLocalizations.of(context).language),
            )
          else
            const SizedBox(height: 1, width: 1),
          const SizedBox(
            width: 10,
          ),
        ],
      );
    }
    return ret;
  }

  Padding _getUniversePadding() {
    var url = '';
    widget.story.getUniverse().then(
          (value) => setState(
            () {
              _universeName = value!.name;
              url = Routes.getParameterizedRouteForViewUniverse(value);
            },
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Spacer(),
          Text('${AppLocalizations.of(context).universe.toUpperCase()}: '),
          RichText(
            text: TextSpan(
              style: const MyTextStyle.linkWoUnderline(),
              text: _universeName,
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  if (kIsWeb) {
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      //throw 'Could not launch $url';
                    }
                  } else {
                    final ret = await widget.story.getUniverse();
                    if (mounted) {
                      unawaited(Navigator.of(context).pushNamed(
                          Routes.getParameterizedRouteForViewUniverse(ret!)));
                    }
                  }
                },
            ),
          ),
        ],
      ),
    );
  }

  BlocBuilder<UniversesListenerBloc, UniversesStates>
      _getUniversesBlocBuilder() {
    return BlocBuilder<UniversesListenerBloc, UniversesStates>(
      buildWhen: (previousState, currentState) {
        MyLogger().logger.d(
            '[StoryForm]universeBuildWhen. Received previous state -> $previousState. Current state -> $currentState');
        return _universesBuildWhenFilter(previousState, currentState);
      },
      builder: (context, state) {
        MyLogger()
            .logger
            .d('[StoryForm]BlocUniverse-builder -> ${state.toString()}');
        model.state.checkEventExecutionTimeTimer?.cancel();
        model.state.checkEventExecutionTimeTimer = null;
        model.state.lastEvent = null;
        if (state is GotMyUniversesState) {
          _isGettingUniverses = false;
          _universes = state.universes;
          if (_selectedUniverse != null && context.isCurrent(this)) {
            _universes.addAllUnique([_selectedUniverse!]);
          }
        } else if (state is UniversesEmptyState) {
          _isGettingUniverses = false;
        }
        return InputDecorator(
          decoration: _getInputDecoration(
              '', AppLocalizations.of(context).productUniverse,
              isLoading: _isGettingUniverses),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<Universe>(
              disabledHint: _isPageReadOnly()
                  ? null
                  : Text(AppLocalizations.of(context).disabled),
              value: (widget.pageMode != PageMode.VIEW)
                  ? (_universes.isNotEmpty)
                      ? _selectedUniverse
                      : null
                  : _selectedUniverse,
              hint: Text(AppLocalizations.of(context).universe),
              items: _getListOfUniversesAsDropDownMenuItems(_universes),
              onChanged: _isPageReadOnly()
                  ? (value) {}
                  : (value) {
                      setState(() {
                        _selectedUniverse = value;
                        widget.story.universeUID = _selectedUniverse!.uid;
                      });
                    },
            ),
          ),
        );
      },
    );
  }

  Widget _getCreateUniverseWidget() {
    return (!_isPageReadOnly())
        ? ElevatedButton(
            onPressed: () async {
              final universe = await Navigator.of(context).pushNamed(
                  Routes.getParameterizedRouteForCreateUniverse(
                      returnUniverse: true)) as Universe?;
              if (universe != null) {
                _universes.add(universe);
                _selectedUniverse = universe;
                if (mounted) {
                  setState(() {});
                } else {
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    setState(() {});
                  });
                }
              }
            },
            child: Text(AppLocalizations.of(context).productCreateuniverse),
          )
        : const SizedBox(height: 1, width: 1);
  }

  List<Widget> _getStoryWidget() {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF,
            horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
        child: Text(
          '${AppLocalizations.of(context).story.toUpperCase()}:',
          style: const MyTextStyle.bold(),
        ),
      ),
      OverlaidProductSuggestions(
        kIsWeb
            ? quill.QuillEditor(
                controller: _controllerQuill,
                minHeight: 250,
                maxHeight: !_isPageReadOnly() ? 250 : 10000,
                scrollController: _scrollControllerQuill,
                scrollable: true,
                focusNode: _focusNodeQuill,
                autoFocus: false,
                readOnly: _isPageReadOnly(),
                expands: false,
                padding: const EdgeInsets.symmetric(
                    horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
                embedBuilder: defaultEmbedBuilderWeb,
                onLaunchUrl: _onLaunchUrl,
              )
            : quill.QuillEditor(
                controller: _controllerQuill,
                minHeight: 250,
                maxHeight: !_isPageReadOnly() ? 250 : 10000,
                scrollController: _scrollControllerQuill,
                scrollable: true,
                focusNode: _focusNodeQuill,
                autoFocus: false,
                readOnly: _isPageReadOnly(),
                expands: false,
                padding: const EdgeInsets.symmetric(
                    horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
                onLaunchUrl: _onLaunchUrl,
              ),
        (_selectedUniverse != null) ? _selectedUniverse!.uid : null,
      ),
      if (!_isPageReadOnly())
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
          child: quill.QuillToolbar.basic(controller: _controllerQuill),
        ),
    ];
  }

  Product _getColorProduct() {
    return Product(
      tag:
          '${Constants.DEFAULT_STORY_COLOR_CONTAINER_TAG}_${widget.story.title}',
      child: Container(
        width: 100,
        height: 100,
        color: model.state.pickedColor,
      ),
    );
  }

  Row _getPickColorRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Spacer(),
        Text(AppLocalizations.of(context).pickColor),
        GestureDetector(
          onTap: () {
            if (!_isPageReadOnly()) {
              Dialogs.showColorPickerDialog(context,
                  onColorChanged: _updatePickedColor);
            }
          },
          child: Container(
            width: 35,
            height: 35,
            color: model.state.pickedColor,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Widget _getPublishedWidget() {
    return Row(
      children: <Widget>[
        const Spacer(),
        SizedBox(
          width: 250,
          child: CheckboxListTile(
            value: widget.story.published,
            onChanged: (isChecked) {
              if (!_isPageReadOnly()) {
                setState(() {
                  widget.story.published = isChecked!;
                });
              }
            },
            subtitle: Text(AppLocalizations.of(context).publishedSubtitle),
            title: Text(
              AppLocalizations.of(context).published,
              style: const TextStyle(fontSize: 14),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Colors.green,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Widget _getSaveStoryWidget(StoriesStates state) {
    return (!_isPageReadOnly())
        ? Row(
            children: <Widget>[
              const Spacer(),
              ElevatedButton(
                onPressed: _saveEnabled && LoggedUser().hasUser()
                    ? () {
                        // Validate returns true if the form is valid, otherwise false.
                        if (_formKey.currentState!.validate()) {
                          if (LoggedUser().hasUser()) {
                            if (_selectedUniverse != null) {
                              if (state is ValidatedStoryTitleState &&
                                  _validateTitle()) {
                                switch (state.validationResult) {
                                  case NameValidationResult.VALID:
                                    _saveStory();
                                    break;
                                  case NameValidationResult.INVALID_EMPTY:
                                    Helper.showSnackBar(
                                        context,
                                        AppLocalizations.of(context)
                                            .theTitleIsEmpty);
                                    break;
                                  case NameValidationResult
                                      .INVALID_ALREADY_EXISTS:
                                    Helper.showSnackBar(
                                        context,
                                        AppLocalizations.of(context)
                                            .pleaseSelectAnotherTitle);
                                    break;
                                  case NameValidationResult.INVALID_CHARACTERS:
                                    Helper.showSnackBar(context,
                                        '${AppLocalizations.of(context).invalidCharacters} ${state.characters}');
                                    break;
                                  case NameValidationResult.UNKNOWN:
                                    Helper.showSnackBar(
                                        context,
                                        AppLocalizations.of(context)
                                            .errorUnknown);
                                    break;
                                }
                              } else {
                                if (widget.pageMode == PageMode.CREATE) {
                                  if (context.isCurrent(this)) {
                                    BlocProvider.of<StoriesBloc>(context).add(
                                        ValidateStoryTitleEvent(
                                            Constants.DEFAULT_HEROESBOOK_URL +
                                                _controllerTitle.text,
                                            _selectedUniverse!.uid!));
                                    setState(() {
                                      model.state.shouldSave = true;
                                      _saveEnabled = false;
                                    });
                                  }
                                } else {
                                  _saveStory();
                                }
                              }
                            } else {
                              Helper.showSnackBar(
                                  context,
                                  AppLocalizations.of(context)
                                      .pleaseSelectAUniverse);
                            }
                          } else {
                            Helper.showSnackBar(context,
                                AppLocalizations.of(context).pleaseLogIn);
                          }
                        }
                      }
                    : null,
                child: Text(AppLocalizations.of(context).save),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          )
        : const SizedBox(width: 1, height: 1);
  }

  Widget _getDeleteStoryWidget() {
    return (_isPageReadOnly() &&
            LoggedUser().hasUser() &&
            LoggedUser().isMyStory(widget.story))
        ? Row(
            children: <Widget>[
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  final ret =
                      await Dialogs.showDeleteConfirmationDialog(context);
                  if (mounted) {
                    if (ret == Dialogs.DELETE_DIALOG_RET_CONFIRM &&
                        context.isCurrent(this)) {
                      BlocProvider.of<StoriesBloc>(context).add(
                          CanDeleteStoryEvent(
                              widget.story, LoggedUser().user!.uid!));
                    }
                  }
                },
                child: Text(AppLocalizations.of(context).delete),
              ),
            ],
          )
        : const SizedBox(width: 1, height: 1);
  }

  Widget _getAllCommentsWidget() {
    return (_isPageReadOnly() && widget.story.uid != null)
        ? AllCommentsWidget(ElementType.STORY, widget.story.uid!)
        : const SizedBox(width: 1, height: 1);
  }

  List<DropdownMenuItem<Universe>> _getListOfUniversesAsDropDownMenuItems(
      List<Universe> universes) {
    final ret = <DropdownMenuItem<Universe>>[];
    for (final universe in universes) {
      ret.add(
        DropdownMenuItem<Universe>(
          value: universe,
          child: Text(universe.toString()),
        ),
      );
    }
    return ret;
  }

  void _saveStory() {
    if (context.isCurrent(this)) {
      widget.story.userUID = LoggedUser().user!.uid;
      widget.story.title = _controllerTitle.text;
      widget.story.story =
          jsonEncode(_controllerQuill.document.toDelta().toJson());
      widget.story.color = model.state.pickedColor.toString();
      if (widget.pageMode == PageMode.CREATE) {
        BlocProvider.of<StoriesBloc>(context).add(SaveStoryEvent(widget.story));
        Future.delayed(
            const Duration(
                milliseconds:
                    Constants.DEFAULT_SAVING_OR_UPDATING_MESSAGE_DELAY), () {
          Helper.showSnackBar(context, AppLocalizations.of(context).saving);
        });
      } else if (widget.pageMode == PageMode.EDIT) {
        BlocProvider.of<StoriesBloc>(context)
            .add(UpdateStoryEvent(widget.story));
        Future.delayed(
            const Duration(
                milliseconds:
                    Constants.DEFAULT_SAVING_OR_UPDATING_MESSAGE_DELAY), () {
          Helper.showSnackBar(context, AppLocalizations.of(context).updating);
        });
      } else {
        throw Exception(
            'Invalid page mode for saving story:${widget.pageMode}');
      }
    } else {
      throw Exception('Page is not currently visible');
    }
    Future.delayed(
        const Duration(
            milliseconds: Constants.DEFAULT_DELAY_TO_UPDATED_ENTITIES), () {
      BlocProvider.of<StoriesListenerBloc>(context).add(
          GetAllStoriesPaginatedTranslatedAndOrderedEvent(
              orderBy: OrderBy.CREATION_DATE));
    });
  }

  void _getMyUniverses(BuildContext context, int delay) {
    if (context.isCurrent(this)) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (!_isGettingUniverses) {
          setState(() {
            _isGettingUniverses = true;
          });
        }
        final universesEvent = GetMyUniversesEvent(LoggedUser().user!.uid!);
        model.state.lastEvent = universesEvent;
        BlocProvider.of<UniversesListenerBloc>(context).add(universesEvent);
        checkEventExecutionTime();
      });
    }
  }

  InputDecoration _getInputDecoration(String hintText, String labelText,
      {bool isLoading = false}) {
    return InputDecoration(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: widget.story.getColorObject()),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: widget.story.getColorObject()),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(
            color: (_isPageReadOnly())
                ? widget.story.getColorObject()
                : Colors.grey),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      prefix: isLoading
          ? const Padding(
              padding: EdgeInsets.only(
                  right: Constants.DEFAULT_FORM_PROGRESS_INDICATOR_PADDING),
              child: SizedBox(
                  width: Constants.DEFAULT_FORM_PROGRESS_INDICATOR_WIDTH,
                  height: Constants.DEFAULT_FORM_PROGRESS_INDICATOR_HEIGHT,
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CircularProgressIndicator())))
          : null,
      icon: Icon(TheProductsbookIcons.broadsword,
          color: widget.story.getColorObject()),
      hintText: hintText,
      labelText: labelText,
    );
  }
}
