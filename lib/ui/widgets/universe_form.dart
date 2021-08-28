import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:little_drops_of_rain_flutter/ads/ad_helper_mixin.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/products_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/universes_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/products_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/states/products_states.dart';
import 'package:little_drops_of_rain_flutter/bloc/states/universes_states.dart';
import 'package:little_drops_of_rain_flutter/bloc/universes_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/universes_listener_bloc.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart' as my_app;
import 'package:little_drops_of_rain_flutter/data/entities/universe.dart';
import 'package:little_drops_of_rain_flutter/enums/element_type.dart';
import 'package:little_drops_of_rain_flutter/enums/name_validation_result.dart';
import 'package:little_drops_of_rain_flutter/enums/order_by.dart';
import 'package:little_drops_of_rain_flutter/enums/page_mode.dart';
import 'package:little_drops_of_rain_flutter/extensions/build_context_extensions.dart';
import 'package:little_drops_of_rain_flutter/extensions/string_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/dialogs.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/logged_user.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/helpers/little_drops_of_rain_flutter_icons.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/models/create_universe_model.dart';
import 'package:little_drops_of_rain_flutter/routing/routing_data.dart';
import 'package:little_drops_of_rain_flutter/ui/comments/all_comments_widget.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/error_page.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_color_scheme.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_text_style.dart';
import 'package:little_drops_of_rain_flutter/ui/universes/create_universe.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/list_products.dart';

// ignore: must_be_immutable
class UniverseForm extends StatefulWidget {
  UniverseForm(this.universe, this.state, this.pageMode, this.routingData,
      {Key? key, this.clearForm = false})
      : super(key: key);

  final Universe universe;
  final UniversesStates state;
  PageMode pageMode;
  final RoutingData? routingData;
  final bool clearForm;

  @override
  _UniverseFormState createState() => _UniverseFormState();
}

// 🚀Global Functional Injection
// This state will be auto-disposed when no longer used, and also testable and mockable.
final model = RM.inject<CreateUniverseModel>(
      () => CreateUniverseModel(),
  undoStackLength: Constants.DEFAULT_UNDO_STACK_LENGTH,
  //Called after new state calculation and just before state mutation
  middleSnapState: (middleSnap) {
    //Log all state transition.
    MyLogger().logger.i(middleSnap.currentSnap);
    MyLogger().logger.i(middleSnap.nextSnap);

    MyLogger().logger.i('');
    middleSnap.print(preMessage: '[CreateUniverseModel]'); //Build-in logger
    //Can return another state
  },
  onDisposed: (state) => MyLogger().logger.i('[CreateUniverseModel]Disposed'),
);

class _UniverseFormState extends State<UniverseForm>
    with TickerProviderStateMixin, AdHelperMixin {
  final _formKey = GlobalKey<FormState>();
  final _textFieldControllerName = TextEditingController();
  final _textFieldControllerComment = TextEditingController();
  late TabController _tabController;
  final List<TabController> _tabControllers = <TabController>[];
  var _scrollController = ScrollController(initialScrollOffset: 5);
  bool _returnUniverse = false;
  final FocusNode _nameFocusNode = FocusNode();
  bool _saveEnabled = true;
  bool _hasShowPleaseLogin = false;
  int _tabIndex = 0;
  List<my_app.Product> _products = <my_app.Product>[];
  Timer? _timerValidateNameDebouncer;
  final KeyboardVisibilityNotification _keyboardVisibility =
  KeyboardVisibilityNotification();
  int _keyboardVisibilitySubscriberId = 0;

  final List<Tab> _tabs = [];
  Container? _bannerAd;

  @override
  void initState() {
    super.initState();
    // Exhaustively handle all four status
    On.all(
      // If is Idle
      onIdle: () => MyLogger().logger.i('[CreateUniverseModel]Idle'),
      // If is waiting
      onWaiting: () => MyLogger().logger.i('[CreateUniverseModel]Waiting'),
      // If has error
      onError: (dynamic err, refresh) =>
          MyLogger()
              .logger
              .e('[CreateUniverseModel]Error:$err. Refresh:$refresh'),
      // If has Data
      onData: () => MyLogger().logger.i('[CreateUniverseModel]Data'),
    );

    if (widget.clearForm) {
      _clearForm();
    }

    if (!kIsWeb) {
      getBannerAd().then((value) {
        setState(() {
          setState(() {
            _bannerAd = value;
          });
        });
      });
    }
    var tabController = TabController(length: 1, vsync: this);
    _tabControllers.add(tabController);
    tabController = TabController(length: 2, vsync: this);
    _tabControllers.add(tabController);
    _tabController = tabController;
    _generateTabs(dummy: true);
    if (widget.pageMode != PageMode.CREATE ||
        widget.pageMode != PageMode.EDIT && !widget.clearForm) {
      _textFieldControllerName.text = model.state.universe.name;
      _textFieldControllerComment.text = model.state.universe.comment;
    }
    _textFieldControllerName.addListener(_onNameChangedListener);
    _processRoutingData(context);
    if (widget.state is UniverseSavedState ||
        widget.state is UniverseUpdatedState) {
      _saveEnabled = true;
    }
    _addListeners();
  }

  @override
  void dispose() {
    _textFieldControllerName.dispose();
    _textFieldControllerComment.dispose();
    _tabControllers.forEach((controller) => controller.dispose());
    _scrollController.dispose();
    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
    _keyboardVisibility.dispose();
    if (!kIsWeb && _bannerAd != null) {
      _bannerAd = null;
      disposeAd();
    }
    super.dispose();
  }

  void _addListeners() {
    _textFieldControllerName.addListener(() {
      model.state.universe.name = _textFieldControllerName.text;
    });
    _textFieldControllerComment.addListener(() {
      model.state.universe.comment = _textFieldControllerComment.text;
    });
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
    _textFieldControllerName.clear();
    _textFieldControllerComment.clear();
    model.state.clear();
  }

  void _tabControllerListener() {
    MyLogger().logger.i('Selected tab${_tabController.index}');
    setState(() {
      _tabIndex = _tabController.index;
    });
  }

  bool _validateName() {
    return _textFieldControllerName.text.isNotEmpty &&
        (widget.pageMode == PageMode.CREATE);
  }

  bool _isPageReadOnly() {
    return widget.pageMode == PageMode.VIEW;
  }

  void _updatePickedColor(Color color) {
    setState(() {
      model.state.pickedColor = color;
      widget.universe.color = color.toString();
    });
  }

  void _onNameChangedListener() {
    if (LoggedUser().hasUser() && _validateName() && context.isCurrent(this)) {
      if (_textFieldControllerName.text.isNotEmpty &&
          _textFieldControllerName.text != model.state.universe.name) {
        model.state.universe.name = _textFieldControllerName.text;
        model.state.scrollPosition = _scrollController.position.pixels;
        if (_timerValidateNameDebouncer != null) {
          _timerValidateNameDebouncer!.cancel();
        }
        _timerValidateNameDebouncer = Timer(
            const Duration(milliseconds: Constants.DEFAULT_DELAY_TO_VALIDATE),
                () {
              BlocProvider.of<UniversesBloc>(context).add(
                  ValidateUniverseNameEvent(
                      Constants.DEFAULT_HEROESBOOK_URL +
                          _textFieldControllerName.text,
                      LoggedUser().user!.uid!));
            });
      }
    }
  }

  void _openKeyboardForName() {
    FocusScope.of(context).requestFocus(_nameFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    if (!LoggedUser().hasUser() && !_hasShowPleaseLogin && !_isPageReadOnly()) {
      _hasShowPleaseLogin = true;
      Future.delayed(const Duration(seconds: 3), () {
        Helper.showSnackBar(context, AppLocalizations
            .of(context)
            .pleaseLogIn);
      });
    }
    _generateTabs();
    Widget ret = ErrorPage(
        exception: Exception(
            '${AppLocalizations
                .of(context)
                .stateNotSupportedError}: ${widget.state.toString()}'));

    if (widget.state is UniversesInitialState ||
        widget.state is GotUniverseByNameState ||
        widget.state is GotUniverseState ||
        widget.state is UniverseTranslatedState ||
        widget.state is ValidatedUniverseNameState ||
        widget.state is UniverseSavedState ||
        widget.state is UniverseUpdatedState ||
        widget.pageMode == PageMode.CREATE) {
      if (widget.state is ValidatedUniverseNameState) {
        final state = widget.state as ValidatedUniverseNameState;
        Future.delayed(
            const Duration(
                milliseconds: Constants.DEFAULT_FORM_VALIDATION_DELAY),
                () => _formKey.currentState?.validate());
        if (!state.isValid) {
          _saveEnabled = true;
          _openKeyboardForName();
        } else if (model.state.shouldSave) {
          _saveUniverse();
        }
        model.state.shouldSave = false;
      }

      if (widget.state is GotUniverseByNameState ||
          widget.state is GotUniverseState ||
          widget.pageMode == PageMode.VIEW) {
        if (model.state.previousUniverse != widget.universe) {
          model.state.previousUniverse = widget.universe;
          _textFieldControllerName.text = widget.universe.name;
          _textFieldControllerComment.text = widget.universe.comment;
          model.state.pickedColor = widget.universe.getColorObject();
        }
      }

      if (widget.universe.uid != null &&
          _products.isEmpty &&
          context.isCurrent(this)) {
        BlocProvider.of<ProductsBloc>(context)
            .add(GetAllProductsByUniverseEvent(widget.universe.uid!));
      }

      ret = Padding(
        padding: const EdgeInsets.all(Constants.DEFAULT_EDGE_INSETS_ALL),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(
                Size(640, MediaQuery
                    .of(context)
                    .size
                    .height)),
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
                    _getNameTextWidget(widget.state),
                    _getTabBar(),
                    _getTabBarView(),
                    if (_isPageReadOnly() && _tabIndex == 0)
                      _getListProductsWidget(),
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
          '[UniverseForm]Error page for state: ${widget.state
              .toString()}, pageMode:${widget.pageMode}. Exception: ${ret
              .exception.toString()}');
    }
    if (_bannerAd != null) {
      ret = Stack(alignment: Alignment.bottomCenter, children: <Widget>[
        Container(height: MediaQuery
            .of(context)
            .size
            .height),
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
            : Text(AppLocalizations
            .of(context)
            .details,
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
            AppLocalizations
                .of(context)
                .comments,
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
        if (!_isPageReadOnly()) _getPickColorRow(),
        _getSaveUniverseWidget(widget.state),
        _getDeleteUniverseWidget(),
        _getCommentWidget(),
      ],
    );
  }

  Widget _getCommentsTabBody() {
    return _getAllCommentsWidget();
  }

  Widget _getListProductsWidget() {
    return BlocListener<ProductsBloc, ProductsStates>(
        listener: (context, state) {
          if (state is GotAllProductsByUniverseState) {
            if (state.products.isNotEmpty &&
                state.products[0].universeUID == widget.universe.uid) {
              setState(() {
                _products = state.products;
              });
            } else {
              _products.clear();
            }
          }
        },
        child: ListProductsWidget(products: _products, compact: false));
  }

  Widget _getNameTextWidget(UniversesStates state) {
    Widget ret;
    if (_isPageReadOnly() || widget.pageMode == PageMode.EDIT) {
      ret = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
          child: Text(
            widget.universe.name,
            style: const TextStyle(
                fontSize: 30,
                fontFamily: Constants.DEFAULT_HERO_CODENAME_CARD_FONT_FAMILY),
          ),
        ),
      );
    } else {
      ret = Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL,
            horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
        child: TextFormField(
          autofocus: true,
          focusNode: _nameFocusNode,
          controller: _textFieldControllerName,
          readOnly: _isPageReadOnly(),
          decoration: _getInputDecoration(
            AppLocalizations
                .of(context)
                .universeName,
            AppLocalizations
                .of(context)
                .name,
          ),
          validator: (widget.pageMode == PageMode.CREATE)
              ? (value) {
            String? ret;
            if (_validateName()) {
              if (widget.state is ValidatedUniverseNameState) {
                final state = widget.state as ValidatedUniverseNameState;
                switch (state.validationResult) {
                  case NameValidationResult.VALID:
                    if (value != null) {
                      widget.universe.name = value;
                      ret = null;
                    } else {
                      ret = AppLocalizations
                          .of(context)
                          .theNameIsEmpty;
                    }
                    break;
                  case NameValidationResult.INVALID_EMPTY:
                    ret = AppLocalizations
                        .of(context)
                        .theNameIsEmpty;
                    break;
                  case NameValidationResult.INVALID_ALREADY_EXISTS:
                    ret = AppLocalizations
                        .of(context)
                        .pleaseSelectAnotherName;
                    break;
                  case NameValidationResult.INVALID_CHARACTERS:
                    ret =
                    '${AppLocalizations
                        .of(context)
                        .invalidCharacters} ${state.characters}';
                    break;
                  case NameValidationResult.UNKNOWN:
                    ret = AppLocalizations
                        .of(context)
                        .errorUnknown;
                }
              } else {
                if (value == null || value.isEmpty) {
                  ret = AppLocalizations
                      .of(context)
                      .universeName;
                } else {
                  ret =
                  '${AppLocalizations
                      .of(context)
                      .invalidCharacters} ${value.getInvalidURLCharacters()}';
                }
              }
            }
            return ret;
          }
              : null,
        ),
      );
    }
    return ret;
  }

  Widget _getCommentWidget() {
    Widget ret;
    if (_isPageReadOnly()) {
      ret = Text(widget.universe.comment);
    } else {
      ret = TextFormField(
        controller: _textFieldControllerComment,
        readOnly: _isPageReadOnly(),
        maxLines: 10,
        decoration: _getInputDecoration(
            AppLocalizations
                .of(context)
                .universeComment,
            AppLocalizations
                .of(context)
                .comment),
        validator: (value) {
          return null;
        },
      );
    }
    return ret;
  }

  Product _getColorProduct() {
    return Product(
      tag:
      '${Constants.DEFAULT_UNIVERSE_COLOR_CONTAINER_TAG}_${widget.universe
          .name}',
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
        Text(AppLocalizations
            .of(context)
            .pickColor),
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

  Widget _getSaveUniverseWidget(UniversesStates state) {
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
                if (widget.state is ValidatedUniverseNameState &&
                    _validateName()) {
                  final state =
                  widget.state as ValidatedUniverseNameState;
                  if (!state.isValid) {
                    _nameFocusNode.requestFocus();
                  }
                  switch (state.validationResult) {
                    case NameValidationResult.VALID:
                      _saveUniverse();
                      break;
                    case NameValidationResult.INVALID_EMPTY:
                      Helper.showSnackBar(
                          context,
                          AppLocalizations
                              .of(context)
                              .theNameIsEmpty);
                      break;
                    case NameValidationResult
                        .INVALID_ALREADY_EXISTS:
                      Helper.showSnackBar(
                          context,
                          AppLocalizations
                              .of(context)
                              .pleaseSelectAnotherName);
                      break;
                    case NameValidationResult.INVALID_CHARACTERS:
                      Helper.showSnackBar(context,
                          '${AppLocalizations
                              .of(context)
                              .invalidCharacters} ${state.characters}');
                      break;
                    case NameValidationResult.UNKNOWN:
                      Helper.showSnackBar(
                          context,
                          AppLocalizations
                              .of(context)
                              .errorUnknown);
                      break;
                  }
                } else {
                  if (widget.pageMode == PageMode.CREATE) {
                    if (context.isCurrent(this)) {
                      BlocProvider.of<UniversesBloc>(context).add(
                          ValidateUniverseNameEvent(
                              Constants.DEFAULT_HEROESBOOK_URL +
                                  _textFieldControllerName.text,
                              LoggedUser().user!.uid!));
                      setState(() {
                        model.state.shouldSave = true;
                        _saveEnabled = false;
                      });
                    }
                  } else {
                    _saveUniverse();
                  }
                }
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
              } else {
                Helper.showSnackBar(context,
                    AppLocalizations
                        .of(context)
                        .pleaseLogIn);
              }
            }
          }
              : null,
          child: Text(AppLocalizations
              .of(context)
              .save),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    )
        : const SizedBox(width: 1, height: 1);
  }

  Widget _getDeleteUniverseWidget() {
    return (_isPageReadOnly() &&
        LoggedUser().hasUser() &&
        LoggedUser().isMyUniverse(widget.universe))
        ? Row(
      children: <Widget>[
        const Spacer(),
        ElevatedButton(
          onPressed: () async {
            final ret =
            await Dialogs.showDeleteConfirmationDialog(context);
            if (ret == Dialogs.DELETE_DIALOG_RET_CONFIRM) {
              if (mounted) {
                if (context.isCurrent(this)) {
                  BlocProvider.of<UniversesBloc>(context).add(
                      CanDeleteUniverseEvent(
                          widget.universe, LoggedUser().user!.uid!));
                }
              }
            }
          },
          child: Text(AppLocalizations
              .of(context)
              .delete),
        ),
      ],
    )
        : const SizedBox(width: 1, height: 1);
  }

  Widget _getAllCommentsWidget() {
    return (_isPageReadOnly() && widget.universe.uid != null)
        ? AllCommentsWidget(ElementType.UNIVERSE, widget.universe.uid!)
        : const SizedBox(width: 1, height: 1);
  }

  void _saveUniverse() {
    if (context.isCurrent(this)) {
      widget.universe.userUID = LoggedUser().user!.uid;
      widget.universe.name = _textFieldControllerName.text;
      widget.universe.comment = _textFieldControllerComment.text;
      widget.universe.color = model.state.pickedColor.toString();
      if (widget.pageMode == PageMode.CREATE) {
        BlocProvider.of<UniversesBloc>(context)
            .add(SaveUniverseEvent(widget.universe, _returnUniverse));
        Future.delayed(
            const Duration(
                milliseconds:
                Constants.DEFAULT_SAVING_OR_UPDATING_MESSAGE_DELAY), () {
          Helper.showSnackBar(context, AppLocalizations
              .of(context)
              .saving);
        });
      } else if (widget.pageMode == PageMode.EDIT) {
        BlocProvider.of<UniversesBloc>(context)
            .add(UpdateUniverseEvent(widget.universe));
        Future.delayed(
            const Duration(
                milliseconds:
                Constants.DEFAULT_SAVING_OR_UPDATING_MESSAGE_DELAY), () {
          Helper.showSnackBar(context, AppLocalizations
              .of(context)
              .updating);
        });
      } else {
        throw Exception(
            'Invalid page mode for saving universe:${widget.pageMode}');
      }
    } else {
      throw Exception('Page is not currently visible');
    }
    Future.delayed(
        const Duration(
            milliseconds: Constants.DEFAULT_DELAY_TO_UPDATED_ENTITIES), () {
      BlocProvider.of<UniversesListenerBloc>(context).add(
          GetAllUniversesPaginatedTranslatedAndOrderedEvent(
              orderBy: OrderBy.CREATION_DATE));
    });
  }

  void _processRoutingData(BuildContext context) {
    if (widget.routingData != null) {
      if (widget
          .routingData![CreateUniversePage.ROUTING_PARAM_RETURN_UNIVERSE] !=
          null) {
        _returnUniverse = widget
            .routingData![CreateUniversePage.ROUTING_PARAM_RETURN_UNIVERSE]!
            .parseBool();
      }
    }
  }

  InputDecoration _getInputDecoration(String hintText, String labelText) {
    return InputDecoration(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: widget.universe.getColorObject()),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: widget.universe.getColorObject()),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(
            color: (_isPageReadOnly())
                ? widget.universe.getColorObject()
                : Colors.grey),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      icon: Icon(TheProductsbookIcons.broadsword,
          color: widget.universe.getColorObject()),
      hintText: hintText,
      labelText: labelText,
    );
  }
}
