import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// ignore: import_of_legacy_library_into_null_safe
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:image_cropper/image_cropper.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:image_picker/image_picker.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:intl/intl.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:keyboard_visibility/keyboard_visibility.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:language_pickers/languages.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:mailto/mailto.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:pedantic/pedantic.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:share/share.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:little_drops_of_rain_flutter/ads/ad_helper_mixin.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/products_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/universes_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/products_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/products_listener_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/states/products_states.dart';
import 'package:little_drops_of_rain_flutter/bloc/states/universes_states.dart';
import 'package:little_drops_of_rain_flutter/bloc/universes_bloc.dart';
import 'package:little_drops_of_rain_flutter/data/dao/products_dao.dart';
import 'package:little_drops_of_rain_flutter/data/dao/universes_dao.dart';
import 'package:little_drops_of_rain_flutter/data/entities/grade.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart' as my_app;
import 'package:little_drops_of_rain_flutter/data/entities/universe.dart';
import 'package:little_drops_of_rain_flutter/enums/element_type.dart';
import 'package:little_drops_of_rain_flutter/enums/name_validation_result.dart';
import 'package:little_drops_of_rain_flutter/enums/order_by.dart';
import 'package:little_drops_of_rain_flutter/enums/page_mode.dart';
import 'package:little_drops_of_rain_flutter/extensions/build_context_extensions.dart';
import 'package:little_drops_of_rain_flutter/extensions/document_extensions.dart';
import 'package:little_drops_of_rain_flutter/extensions/list_extensions.dart';
import 'package:little_drops_of_rain_flutter/extensions/uri_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/dialogs.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/logged_user.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/helpers/little_drops_of_rain_flutter_icons.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/models/create_product_model.dart';
import 'package:little_drops_of_rain_flutter/real_main.dart';
import 'package:little_drops_of_rain_flutter/resources/resources.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:little_drops_of_rain_flutter/routing/routing_data.dart';
import 'package:little_drops_of_rain_flutter/ui/comments/all_comments_widget.dart';
import 'package:little_drops_of_rain_flutter/ui/cropper/image_crop_widget.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/error_page.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_color_scheme.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_text_style.dart';
import 'package:little_drops_of_rain_flutter/ui/universes/create_universe.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/list_products.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/overlaid_product_suggestions.dart';
import 'package:little_drops_of_rain_flutter/universal_ui/universal_ui.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:universal_html/html.dart' as html;

// ignore: import_of_legacy_library_into_null_safe
import 'package:url_launcher/url_launcher.dart';

class ProductForm extends StatefulWidget {
  const ProductForm(this.product, this.state, this.pageMode, this.routingData,
      {Key? key, this.clearForm = false})
      : super(key: key);

  final my_app.Product product;
  final ProductsStates state;
  final PageMode pageMode;
  final RoutingData routingData;
  final bool clearForm;

  @override
  _ProductFormState createState() => _ProductFormState();
}

// 🚀Global Functional Injection
// This state will be auto-disposed when no longer used, and also testable and mockable.
final model = RM.inject<CreateProductModel>(
  () => CreateProductModel(),
  undoStackLength: Constants.DEFAULT_UNDO_STACK_LENGTH,
  //Called after new state calculation and just before state mutation
  middleSnapState: (middleSnap) {
    //Log all state transition.
    MyLogger().logger.i(middleSnap.currentSnap);
    MyLogger().logger.i(middleSnap.nextSnap);

    MyLogger().logger.i('');
    middleSnap.print(preMessage: '[CreateProductModel]'); //Build-in logger
    //Can return another state
  },
  onDisposed: (state) => MyLogger().logger.i('[CreateProductModel]Disposed'),
);

class _ProductFormState extends State<ProductForm>
    with TickerProviderStateMixin, AdHelperMixin {
  final _formKey = GlobalKey<FormState>();

  final FocusNode _focusNodeQuill = FocusNode();
  final FocusNode _focusNodeCodename = FocusNode();
  late TabController _tabController;
  final List<TabController> _tabControllers = <TabController>[];

  final _scrollControllerListView = ScrollController(initialScrollOffset: 5);
  final _scrollControllerQuill = ScrollController(initialScrollOffset: 5);
  var _scrollController = ScrollController(initialScrollOffset: 5);
  var _controllerQuill = quill.QuillController.basic();

  final TextEditingController _controllerCivilName = TextEditingController();
  final TextEditingController _controllerWeapons = TextEditingController();
  final TextEditingController _controllerCodename = TextEditingController();
  final TextEditingController _controllerHabilities = TextEditingController();
  final TextEditingController _controllerAge = TextEditingController();
  final TextEditingController _controllerLanguage = TextEditingController();
  final TextEditingController _controllerBirthplace = TextEditingController();
  final TextEditingController _controllerTrainningplace =
      TextEditingController();
  final TextEditingController _controllerProfession = TextEditingController();

  late final AssetImage _imagePlaceholder;
  late final AssetImage _faceImagePlaceholder;

  List<my_app.Product> _productFriends = <my_app.Product>[];
  my_app.Product? _dropDownFriendsSelectedValue;
  List<my_app.Product> _productEnemies = <my_app.Product>[];
  my_app.Product? _dropDownEnemiesSelectedValue;
  Universe? _selectedUniverse;
  Universe? _previousSelectedUniverse;
  List<Universe> _universes = <Universe>[];
  XFile? _pickedFile;
  late double pixelRatio;
  bool _saveEnabled = true;
  bool _hasShowPleaseLogin = false;
  String _ownerName = '';
  String _universeName = '';
  int _tabIndex = 0;
  bool _isShareSupported = true;
  Uri? _faceImageUrl;
  Uint8List? _faceImageBytes;
  Uri? _imageUrl;
  List<DropdownMenuItem<my_app.Product>> _productFriendsAsDropDownMenuItems =
      <DropdownMenuItem<my_app.Product>>[];
  List<DropdownMenuItem<my_app.Product>> _productEnemiesAsDropDownMenuItems =
      <DropdownMenuItem<my_app.Product>>[];
  my_app.Product? _previousProduct;
  bool _productViewsUpdated = false;
  Widget _image = const Image(
    image: AssetImage(Images.noProduct),
    fit: BoxFit.cover,
  );
  bool _gettingImage = false;
  bool _gotImage = false;
  bool _gotDefaultImage = false;
  int _gotDefaultImageTriesCount = 0;
  bool _gettingFaceImage = false;
  bool _gotFaceImage = false;
  bool _gotDefaultFaceImage = false;
  int _gotDefaultFaceImageTriesCount = 0;
  bool _useCroppedImage = false;
  bool _useCroppedFaceImage = false;
  late Widget _widgetChecked;
  late Widget _widgetUnchecked;
  bool _isGettingUniverses = false;
  bool _isGettingProductsByUniverse = false;
  bool _isGettingFriends = false;
  bool _isGettingEnemies = false;
  Timer? _timerValidateCodenameDebouncer;
  final KeyboardVisibilityNotification _keyboardVisibility =
      KeyboardVisibilityNotification();
  int _keyboardVisibilitySubscriberId = 0;

  Widget _faceImage = const Image(
    gaplessPlayback: true,
    image: AssetImage(Images.noFace),
    fit: BoxFit.cover,
    width: Constants.DEFAULT_FACE_IMAGE_WIDTH,
    height: Constants.DEFAULT_FACE_IMAGE_HEIGHT,
  );

  final List<Tab> _tabs = [];
  Container? _bannerAd;

  @override
  void initState() {
    super.initState();
    // Exhaustively handle all four status
    On.all(
      // If is Idle
      onIdle: () => MyLogger().logger.i('[CreateProductModel]Idle'),
      // If is waiting
      onWaiting: () => MyLogger().logger.i('[CreateProductModel]Waiting'),
      // If has error
      onError: (dynamic err, refresh) =>
          MyLogger().logger.e('[CreateProductModel]Error:$err. Refresh:$refresh'),
      // If has Data
      onData: () => MyLogger().logger.i('[CreateProductModel]Data'),
    );

    if (widget.clearForm) {
      _clearForm();
    }

    _widgetChecked = SvgPicture.asset(
      'assets/images/font_awesome/solid/check.svg',
      color: Colors.red,
      placeholderBuilder: (context) => const SizedBox(
          width: Constants.DEFAULT_DROPDOWN_FACE_IMAGE_WIDTH,
          height: Constants.DEFAULT_DROPDOWN_FACE_IMAGE_HEIGHT,
          child: FittedBox(
              fit: BoxFit.scaleDown, child: CircularProgressIndicator())),
      width: Constants.DEFAULT_DROPDOWN_FACE_IMAGE_WIDTH,
      height: Constants.DEFAULT_DROPDOWN_FACE_IMAGE_HEIGHT,
    );
    _widgetUnchecked = const SizedBox(
      width: Constants.DEFAULT_DROPDOWN_FACE_IMAGE_WIDTH,
      height: Constants.DEFAULT_DROPDOWN_FACE_IMAGE_HEIGHT,
    );
    _imagePlaceholder = const AssetImage(Images.noProduct);
    _faceImagePlaceholder = const AssetImage(Images.noFace);
    _productViewsUpdated = false;
    if (!kIsWeb) {
      getBannerAd().then((value) {
        setState(() {
          _bannerAd = value;
        });
      });
    }
    _imageUrl = widget.product.imageUrl;
    _faceImageUrl = widget.product.faceImageUrl;
    var tabController = TabController(length: 1, vsync: this);
    _tabControllers.add(tabController);
    tabController = TabController(length: 2, vsync: this);
    _tabControllers.add(tabController);
    _tabController = tabController;
    _generateTabs(dummy: true);
    if (widget.pageMode == PageMode.CREATE ||
        widget.pageMode == PageMode.EDIT && !widget.clearForm) {
      _controllerCivilName.text = model.state.product.civilName;
      _controllerWeapons.text = model.state.product.weapons;
      _controllerCodename.text = model.state.product.codename;
      _controllerHabilities.text = model.state.product.habilities;
      _controllerAge.text = model.state.product.age;
      _controllerLanguage.text = model.state.product.language;
      if (widget.product.language.isNotEmpty) {
        _controllerLanguage.text = widget.product.language;
      }
      _controllerBirthplace.text = model.state.product.birthplace;
      _controllerTrainningplace.text = model.state.product.trainningPlace;
      _controllerProfession.text = model.state.product.profession;
      _faceImageUrl = model.state.faceImageUrl;
      _imageUrl = model.state.imageUrl;
      _faceImageBytes = model.state.faceImageBytes;
      _pickedFile = model.state.pickedFile;
      _selectedUniverse = model.state.selectedUniverse;
      if (model.state.product.friendsUIDS.isNotEmpty) {
        widget.product.friendsUIDS = model.state.product.friendsUIDS;
      }
      if (model.state.product.enemiesUIDS.isNotEmpty) {
        widget.product.enemiesUIDS = model.state.product.enemiesUIDS;
      }
      if (model.state.product.story.isNotEmpty) {
        _controllerQuill.dispose();
        _controllerQuill = quill.QuillController(
            document: quill.Document.fromJson(
                jsonDecode(model.state.product.story) as List<dynamic>),
            selection: const TextSelection.collapsed(offset: 0));
      }
      if (_pickedFile != null) {
        _updatePickedImage(Uri.parse(_pickedFile!.path));
      } else if (_imageUrl != null) {
        _updatePickedImage(_imageUrl!);
      }
      if (_faceImageBytes != null) {
        _updatePickedFaceImageAsBytes(_faceImageBytes!);
      } else if (_faceImageUrl != null) {
        _updatePickedFaceImage(_faceImageUrl!);
      }
      _scrollController =
          ScrollController(initialScrollOffset: model.state.scrollPosition);
    }
    unawaited(widget.product.getUniverse());
    if (widget.pageMode == PageMode.VIEW || widget.pageMode == PageMode.EDIT) {
      _getImage();
    }
    if (widget.pageMode == PageMode.VIEW) {
      _getFriends();
      _getEnemies();
    }
    if (widget.pageMode == PageMode.EDIT) {
      _getFaceImage();
    }
    if (widget.pageMode == PageMode.CREATE ||
        widget.pageMode == PageMode.EDIT) {
      model.state.replaceState = true;
    }
    _addListeners();
  }

  @override
  void dispose() {
    _focusNodeQuill.dispose();
    _focusNodeCodename.dispose();
    _tabControllers.forEach((controller) => controller.dispose());
    _controllerQuill.dispose();
    _controllerCivilName.dispose();
    _controllerWeapons.dispose();
    _controllerCodename.removeListener(_onCodeNameChangedListener);
    _controllerCodename.dispose();
    _controllerHabilities.dispose();
    _controllerAge.dispose();
    _controllerLanguage.dispose();
    _controllerBirthplace.dispose();
    _controllerTrainningplace.dispose();
    _controllerProfession.dispose();
    _scrollController.dispose();
    _scrollControllerListView.dispose();
    _scrollControllerQuill.dispose();
    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
    _keyboardVisibility.dispose();
    if (!kIsWeb && _bannerAd != null) {
      _bannerAd = null;
      disposeAd();
    }
    super.dispose();
  }

  void _addListeners() {
    _controllerQuill.addListener(() {
      model.state.product.story =
          jsonEncode(_controllerQuill.document.toDelta().toJson());
    });
    _controllerCivilName.addListener(() {
      model.state.product.civilName = _controllerCivilName.text;
    });
    _controllerWeapons.addListener(() {
      model.state.product.weapons = _controllerWeapons.text;
    });
    _controllerCodename.addListener(_onCodeNameChangedListener);
    _controllerHabilities.addListener(() {
      model.state.product.habilities = _controllerHabilities.text;
    });
    _controllerAge.addListener(() {
      model.state.product.age = _controllerAge.text;
    });
    _controllerLanguage.addListener(() {
      model.state.product.language = _controllerLanguage.text;
    });
    _controllerBirthplace.addListener(() {
      model.state.product.birthplace = _controllerBirthplace.text;
    });
    _controllerTrainningplace.addListener(() {
      model.state.product.trainningPlace = _controllerTrainningplace.text;
    });
    _controllerProfession.addListener(() {
      model.state.product.profession = _controllerProfession.text;
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
    _controllerCivilName.clear();
    _controllerWeapons.clear();
    _controllerCodename.clear();
    _controllerHabilities.clear();
    _controllerAge.clear();
    _controllerLanguage.clear();
    if (widget.product.language.isNotEmpty) {
      _controllerLanguage.text = widget.product.language;
    }
    _controllerBirthplace.clear();
    _controllerTrainningplace.clear();
    _controllerProfession.clear();
    model.state.clear();
    _productFriends.clear();
    _productEnemies.clear();
    _productFriendsAsDropDownMenuItems.clear();
    _productEnemiesAsDropDownMenuItems.clear();
    _universes.clear();
    _selectedUniverse = null;
    _previousSelectedUniverse = null;
    _dropDownFriendsSelectedValue = null;
    _dropDownEnemiesSelectedValue = null;
  }

  void _tabControllerListener() {
    MyLogger().logger.i('Selected tab${_tabController.index}');
    setState(() {
      _tabIndex = _tabController.index;
    });
  }

  void _onCodeNameChangedListener() {
    if (!_isPageReadOnly()) {
      if (_selectedUniverse != null &&
          _selectedUniverse!.uid != null &&
          _validateCodename() &&
          context.isCurrent(this)) {
        if (_controllerCodename.text.isNotEmpty &&
            _controllerCodename.text != model.state.product.codename) {
          model.state.product.codename = _controllerCodename.text;
          model.state.scrollPosition = _scrollController.position.pixels;
          if (_timerValidateCodenameDebouncer != null) {
            _timerValidateCodenameDebouncer!.cancel();
          }
          _timerValidateCodenameDebouncer = Timer(
              const Duration(milliseconds: Constants.DEFAULT_DELAY_TO_VALIDATE),
              () {
            BlocProvider.of<ProductsBloc>(context).add(ValidateProductCodeNameEvent(
                Constants.DEFAULT_HEROESBOOK_URL + _controllerCodename.text,
                _selectedUniverse!.uid!));
            _timerValidateCodenameDebouncer!.cancel();
            _timerValidateCodenameDebouncer = null;
          });
        }
      }
    }
  }

  void _updatePickedLanguage(Language language) {
    setState(() {
      widget.product.language = language.name;
      _controllerLanguage.text = language.name;
    });
  }

  bool _validateCodename() {
    return _controllerCodename.text.isNotEmpty &&
        (widget.pageMode == PageMode.CREATE);
  }

  bool _isPageReadOnly() {
    return widget.pageMode == PageMode.VIEW;
  }

  void _updatePickedColor(Color color) {
    setState(() {
      model.state.pickedColor = color;
      widget.product.color = color.toString();
    });
  }

  void _updatePickedImage(Uri filePath) {
    model.state.imageUrl = filePath;
    _imageUrl = filePath;
    _gotImage = false;
    _gotDefaultImage = false;
    _gettingImage = false;
    _useCroppedImage = true;
    _getImage();
  }

  void _updatePickedFaceImage(Uri filePath) {
    model.state.faceImageUrl = filePath;
    _faceImageUrl = filePath;
    _gotFaceImage = false;
    _gotDefaultFaceImage = false;
    _gettingFaceImage = false;
    _useCroppedFaceImage = true;
    _getFaceImage();
  }

  void _updatePickedFaceImageAsBytes(Uint8List bytes) {
    model.state.faceImageBytes = bytes;
    _faceImageBytes = bytes;
    _gotFaceImage = false;
    _gotDefaultFaceImage = false;
    _gettingFaceImage = false;
    _useCroppedFaceImage = true;
    _getFaceImage();
  }

  void _openKeyboardForCodename() {
    FocusScope.of(context).requestFocus(_focusNodeCodename);
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.state is ProductSavedState || widget.state is ProductUpdatedState) &&
        widget.pageMode == PageMode.VIEW) {
      WidgetsBinding.instance
          ?.addPostFrameCallback((_) => _onAfterBuild(context));
      _saveEnabled = true;
      if (kIsWeb && model.state.replaceState) {
        model.state.replaceState = false;
        html.window.history.replaceState(null, '',
            '/#${Routes.getParameterizedRouteForViewProduct(widget.product)}');
      }
    }
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

    if (widget.state is ProductsInitialState ||
        widget.state is GotProductsByCivilOrCodeNameState ||
        widget.state is GotProductsByCivilNameState ||
        widget.state is GotProductByCodeNameState ||
        widget.state is GotProductState ||
        widget.state is ProductTranslatedState ||
        widget.state is ValidatedProductCodeNameState ||
        widget.state is ProductViewsIncrementedState ||
        widget.state is ProductSavedState ||
        widget.state is ProductUpdatedState ||
        widget.pageMode == PageMode.CREATE) {
      if (widget.state is ProductTranslatedState) {
        final state = widget.state as ProductTranslatedState;
        _controllerQuill = quill.QuillController(
            document: DocumentExtensions.fromPlainText(state.product.story),
            selection: const TextSelection.collapsed(offset: 0));
      }

      if (LoggedUser().hasUser() && !_isPageReadOnly() && _universes.isEmpty) {
        _getMyUniverses(context, Constants.DEFAULT_GET_MY_UNIVERSES_DELAY_TIME);
      }

      if (widget.product.story.isNotEmpty &&
          (widget.state is! ProductTranslatedState)) {
        _controllerQuill = quill.QuillController(
            document: quill.Document.fromJson(
                jsonDecode(widget.product.story) as List<dynamic>),
            selection: const TextSelection.collapsed(offset: 0));
      }

      if (widget.state is GotProductsByCivilOrCodeNameState ||
          widget.state is GotProductsByCivilNameState ||
          widget.state is GotProductByCodeNameState ||
          widget.state is GotProductState ||
          widget.pageMode == PageMode.VIEW) {
        _selectedUniverse = widget.product.universe;

        if (widget.pageMode == PageMode.VIEW) {
          if (_selectedUniverse != null) {
            _universes.addAllUnique([_selectedUniverse!]);
          }
          if (!_productViewsUpdated &&
              widget.product.uid != null &&
              context.isCurrent(this)) {
            _productViewsUpdated = true;
            BlocProvider.of<ProductsBloc>(context)
                .add(IncrementProductViewsEvent(widget.product.uid!));
          }
        }
        if (_previousProduct != widget.product) {
          _previousProduct = widget.product;
          _imageUrl = widget.product.imageUrl;
          _faceImageUrl = widget.product.faceImageUrl;
          _faceImageBytes = null;
          _controllerCivilName.text = widget.product.civilName;
          _controllerWeapons.text = widget.product.weapons;
          _controllerCodename.text = widget.product.codename;
          _controllerHabilities.text = widget.product.habilities;
          _controllerAge.text = widget.product.age.toString();
          _controllerLanguage.text = widget.product.language;
          _controllerBirthplace.text = widget.product.birthplace;
          _controllerTrainningplace.text = widget.product.trainningPlace;
          _controllerProfession.text = widget.product.profession;
          model.state.pickedColor = widget.product.getColorObject();
          _getFriends();
          _getEnemies();
        }
      }

      if (widget.state is ValidatedProductCodeNameState) {
        final state = widget.state as ValidatedProductCodeNameState;
        Future.delayed(
            const Duration(
                milliseconds: Constants.DEFAULT_FORM_VALIDATION_DELAY),
            () => _formKey.currentState?.validate());
        if (!state.isValid) {
          _saveEnabled = true;
          _openKeyboardForCodename();
        } else if (model.state.shouldSave) {
          _saveProduct(context);
        }
        model.state.shouldSave = false;
      }

      if (widget.pageMode == PageMode.VIEW ||
          widget.pageMode == PageMode.EDIT) {
        _getImage();
      }
      if (widget.pageMode == PageMode.EDIT) {
        _getFaceImage();
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
                    const SizedBox(height: 5),
                    _getPageHeaderPadding(),
                    _getTabBar(),
                    _getTabBarViewPart1(),
                    if (_tabIndex == 0) ..._getStoryWidget(),
                    if (_tabIndex == 0) _getTabBarViewPart2(),
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
          '[ProductForm]Error page for state: ${widget.state.toString()}, pageMode:${widget.pageMode}. Exception: ${ret.exception.toString()}');
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

  void checkEventExecutionTime() {
    model.state.checkEventExecutionTimeTimer?.cancel();
    model.state.checkEventExecutionTimeTimer = Timer(
        const Duration(
            milliseconds: Constants.DEFAULT_CHECK_EVENT_EXECUTION_TIME_DELAY),
        () {
      if (model.state.lastEvent != null) {
        Helper.showSnackBar(context,
            AppLocalizations.of(context).looksLikeItIsTakingALongTimeRetrying);
        BlocProvider.of<ProductsListenerBloc>(context)
            .add(model.state.lastEvent!);
      } else {
        Helper.showSnackBar(
            context,
            AppLocalizations.of(context)
                .looksLikeItIsTakingALongTimeReselectUniverse);
      }
    });
  }

  void _getFriends() {
    if (!_isGettingFriends &&
        !_hasGotProducts(widget.product.friendsUIDS, _productFriends)) {
      _isGettingFriends = true;
      widget.product.getFriends().then((friends) {
        _productFriends = friends;
        _dropDownFriendsSelectedValue =
            (_productFriends.isNotEmpty) ? _productFriends.first : null;
        setState(() {
          _isGettingFriends = false;
        });
      });
    }
  }

  void _getEnemies() {
    if (!_isGettingEnemies &&
        !_hasGotProducts(widget.product.enemiesUIDS, _productEnemies)) {
      _isGettingEnemies = true;
      widget.product.getEnemies().then((enemies) {
        _productEnemies = enemies;
        _dropDownEnemiesSelectedValue =
            (_productEnemies.isNotEmpty) ? _productEnemies.first : null;
        setState(() {
          _isGettingEnemies = false;
        });
      });
    }
  }

  bool _hasGotProducts(List<String> uids, List<my_app.Product> products) {
    var ret = false;
    if (uids.isNotEmpty && products.isNotEmpty) {
      if (uids.length == products.length) {
        var contains = false;
        for (final uid in uids) {
          contains = false;
          for (final product in products) {
            if (product.uid == uid) {
              contains = true;
              break;
            }
          }
          if (!contains) {
            break;
          }
        }
        if (contains) {
          ret = true;
        }
      }
    } else if (uids.length != products.length) {
      ret = false;
    } else {
      ret = true;
    }
    return ret;
  }

  void _onAfterBuild(BuildContext context) {
    if (_scrollController.hasClients &&
        (_scrollController.offset >=
            (_scrollController.position.maxScrollExtent -
                Constants.DEFAULT_AD_BOTTOM_SPACE -
                100)) &&
        !_scrollController.position.outOfRange) {
      _scrollController.animateTo(_scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    }
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

  Padding _getPageHeaderPadding() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL,
          horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              _getGoToAllProductsArrow(),
              Text(
                AppLocalizations.of(context).products,
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
            ],
          ),
          _getImagesColumn(),
          if (_isPageReadOnly() || widget.pageMode == PageMode.EDIT)
            _getCodenameTitlePadding(),
          if (_isPageReadOnly()) _getUniversePadding(),
        ],
      ),
    );
  }

  InkWell _getGoToAllProductsArrow() {
    return InkWell(
        onTap: () {
          Navigator.pushNamed(
              context,
              Routes.getParameterizedRouteByViewElements(ElementType.HERO));
        },
        child: SvgPicture.asset(
            'assets/images/font_awesome/solid/arrow-left.svg',
            placeholderBuilder: (context) => const SizedBox(
                width: Constants.DEFAULT_GO_TO_ALL_HEROES_ICON_WIDTH,
                height: Constants.DEFAULT_GO_TO_ALL_HEROES_ICON_HEIGHT,
                child: FittedBox(
                    fit: BoxFit.scaleDown, child: CircularProgressIndicator())),
            width: Constants.DEFAULT_GO_TO_ALL_HEROES_ICON_WIDTH,
            height: Constants.DEFAULT_GO_TO_ALL_HEROES_ICON_HEIGHT));
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

  Widget _getTabBarViewPart1() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL,
          horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
      child: [
        _getDetailsTabBodyPart1(),
        if (_isPageReadOnly()) _getCommentsTabBody(),
      ][_tabIndex],
    );
  }

  Widget _getTabBarViewPart2() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL,
          horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
      child: _getDetailsTabBodyPart2(),
    );
  }

  Column _getDetailsTabBodyPart1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (_isPageReadOnly()) _getDetailsBasicInfo(),
        if (widget.pageMode == PageMode.CREATE)
          _getCodeNameWidget(widget.state),
        if (!_isPageReadOnly()) _getUniversesBlocBuilder(),
        if (!_isPageReadOnly()) _getCreateUniverseWidget(),
        _getCivilNameTextWidget(),
        _getWeaponsWidget(),
        _getHabilitiesWidget(),
      ],
    );
  }

  Column _getDetailsTabBodyPart2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _getAgeWidget(),
        if (!_isPageReadOnly()) _getLanguageRow(),
        _getBirthPlaceWidget(),
        _getTrainningPlaceWidget(),
        _getProfessionWidget(),
        _getPublishedWidget(),
        if (_isPageReadOnly())
          Row(children: <Widget>[
            _getProductsFriendsBlocConsumer(),
            _getProductsEnemiesBlocConsumer(),
          ]),
        if (!_isPageReadOnly()) _getProductsFriendsBlocConsumer(),
        if (!_isPageReadOnly()) _getProductsEnemiesBlocConsumer(),
        _getPickColorRow(),
        _getSaveProductWidget(widget.state),
        _getDeleteProductWidget(),
      ],
    );
  }

  Widget _getCommentsTabBody() {
    return _getAllCommentsWidget();
  }

  bool _universesBuildWhenFilter(
      UniversesStates previousState, UniversesStates currentState) {
    return (previousState != currentState) &&
        (currentState is GotMyUniversesState) &&
        !_isPageReadOnly() &&
        _universes.isEmpty;
  }

  bool _productsEnemiesListenWhenFilter(
      ProductsStates previousState, ProductsStates currentState) {
    return (previousState != currentState) &&
        ((currentState is GotAllProductsByUniverseState) ||
            (currentState is ProductsEmptyState)) &&
        !_isPageReadOnly();
  }

  bool _productsFriendsListenWhenFilter(
      ProductsStates previousState, ProductsStates currentState) {
    return (previousState != currentState) &&
        ((currentState is GotAllProductsByUniverseState) ||
            (currentState is ProductsEmptyState)) &&
        !_isPageReadOnly();
  }

  bool _productsEnemiesBuildWhenFilter(
      ProductsStates previousState, ProductsStates currentState) {
    return (previousState != currentState) &&
        ((currentState is GotAllProductsByUniverseState) ||
            (currentState is ProductsEmptyState)) &&
        !_isPageReadOnly();
  }

  bool _productsFriendsBuildWhenFilter(
      ProductsStates previousState, ProductsStates currentState) {
    return (previousState != currentState) &&
        ((currentState is GotAllProductsByUniverseState) ||
            (currentState is ProductsEmptyState)) &&
        !_isPageReadOnly();
  }

  Widget _getDetailsBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _getCreatedAndUpdatedDates(),
        _getWrittenInAnOwnerPadding(),
        _getViewsText(),
        _getRatingAndShareRow(),
      ],
    );
  }

  Row _getRatingAndShareRow() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _getRatingWidget(),
          _getShareIcon(),
          const SizedBox(
              width: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL, height: 1),
        ]);
  }

  Widget _getShareIcon() {
    return InkWell(
      onTap: () async {
        if (!kIsWeb || _isShareSupported) {
          await _onShare(context);
        }
      },
      child: (!kIsWeb || _isShareSupported)
          ? _getShareIconCanShare()
          : _getShareIconCantShare(),
    );
  }

  SvgPicture _getShareIconCanShare() {
    return SvgPicture.asset('assets/images/font_awesome/solid/share-alt.svg',
        placeholderBuilder: (context) => const SizedBox(
            width: Constants.DEFAULT_SHARE_ICON_WIDTH,
            height: Constants.DEFAULT_SHARE_ICON_HEIGHT,
            child: FittedBox(
                fit: BoxFit.scaleDown, child: CircularProgressIndicator())),
        width: Constants.DEFAULT_SHARE_ICON_WIDTH,
        height: Constants.DEFAULT_SHARE_ICON_HEIGHT);
  }

  Stack _getShareIconCantShare() {
    return Stack(
      children: <Widget>[
        SvgPicture.asset('assets/images/font_awesome/solid/share-alt.svg',
            placeholderBuilder: (context) => const SizedBox(
                width: Constants.DEFAULT_SHARE_ICON_WIDTH,
                height: Constants.DEFAULT_SHARE_ICON_HEIGHT,
                child: FittedBox(
                    fit: BoxFit.scaleDown, child: CircularProgressIndicator())),
            width: Constants.DEFAULT_SHARE_ICON_WIDTH,
            height: Constants.DEFAULT_SHARE_ICON_HEIGHT),
        SvgPicture.asset('assets/images/font_awesome/solid/ban.svg',
            placeholderBuilder: (context) => const SizedBox(
                width: Constants.DEFAULT_SHARE_ICON_WIDTH,
                height: Constants.DEFAULT_SHARE_ICON_HEIGHT,
                child: FittedBox(
                    fit: BoxFit.scaleDown, child: CircularProgressIndicator())),
            width: Constants.DEFAULT_SHARE_ICON_WIDTH,
            height: Constants.DEFAULT_SHARE_ICON_HEIGHT),
      ],
    );
  }

  Future<void> _onShare(BuildContext context) async {
    if (kIsWeb) {
      final shareData = <String, String>{
        'title':
            '${AppLocalizations.of(context).shareProduct}: ${widget.product.codename}',
        'text':
            '${AppLocalizations.of(context).shareProduct}: ${widget.product.codename}',
        'url': Constants.DEFAULT_HEROESBOOK_URL +
            Routes.getParameterizedRouteForViewProduct(widget.product)
                .replaceFirst('/', ''),
      };
      try {
        if (!kIsWeb) {
          await html.window.navigator.share(shareData);
        } else {
          final mailtoLink = Mailto(
            subject:
                '${AppLocalizations.of(context).shareProduct}: ${widget.product.codename}',
            to: [if (LoggedUser().hasUser()) LoggedUser().user!.email else ''],
            body: shareData['url'],
          );
          // Convert the Mailto instance into a string.
          // Use either Dart's string interpolation
          // or the toString() method.
          await launch('$mailtoLink');
        }
      } catch (_) {
        setState(() {
          Helper.showSnackBar(
              context, AppLocalizations.of(context).sharingNotSupported);
          _isShareSupported = false;
        });
      }
    } else {
      // A builder is used to retrieve the context immediately
      // surrounding the ElevatedButton.
      //
      // The context's `findRenderObject` returns the first
      // RenderObject in its descendent tree when it's not
      // a RenderObjectWidget. The ElevatedButton's RenderObject
      // has its position and size after it's built.
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        await Share.share(
            Constants.DEFAULT_HEROESBOOK_URL + widget.routingData.route!.path,
            subject: AppLocalizations.of(context).shareProduct,
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
      }
    }
    return Future.value(null);
  }

  Text _getViewsText() {
    return Text(
      '${NumberFormat.compact(locale: MyApp.locale.toString()).format(widget.product.views)} ${AppLocalizations.of(context).views}',
    );
  }

  Padding _getUniversePadding() {
    var url = '';
    if (widget.product.universeUID != null && _universeName.isEmpty) {
      widget.product.getUniverse().then(
            (value) => setState(
              () {
                _universeName = value!.name;
                url = Routes.getParameterizedRouteForViewUniverse(value);
              },
            ),
          );
    }
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
                    final ret = await widget.product.getUniverse();
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

  Padding _getWrittenInAnOwnerPadding() {
    if (mounted && _ownerName.isEmpty) {
      widget.product.getUser().then(
        (value) {
          if (mounted && value != null) {
            setState(
              () {
                _ownerName = value.getIdentification();
              },
            );
          }
        },
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
              '${AppLocalizations.of(context).writtenIn}: ${widget.product.language} ${AppLocalizations.of(context).by}: '),
          Text(_ownerName, style: const MyTextStyle.blue())
        ],
      ),
    );
  }

  Row _getCreatedAndUpdatedDates() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[_getCreatedDatePadding(), _getUpdatedDatePadding()]);
  }

  Padding _getCreatedDatePadding() {
    if (widget.product.creationDate != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
        child: Text(
          '${AppLocalizations.of(context).created} ${kIsWeb ? DateFormat.yMMMMd(MyApp.locale.toString()).format(widget.product.creationDate!.toDate()) : DateFormat.yMMMd(MyApp.locale.toString()).format(widget.product.creationDate!.toDate())}',
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
        child: Text(
          AppLocalizations.of(context).unavailable,
        ),
      );
    }
  }

  Padding _getUpdatedDatePadding() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
      child: Text(
        '${AppLocalizations.of(context).updated} ${kIsWeb ? DateFormat.yMMMMd(MyApp.locale.toString()).format(widget.product.updateDate!.toDate()) : DateFormat.yMMMd(MyApp.locale.toString()).format(widget.product.updateDate!.toDate())}',
      ),
    );
  }

  Padding _getCodenameTitlePadding() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
      child: Text(
        widget.product.codename,
        style: const TextStyle(
            fontSize: 30,
            fontFamily: Constants.DEFAULT_HERO_CODENAME_CARD_FONT_FAMILY),
      ),
    );
  }

  Column _getImagesColumn() {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      if (!_isPageReadOnly()) _faceImage,
      const SizedBox(
        height: 10,
      ),
      _image,
      const SizedBox(
        height: 10,
      ),
      if (!_isPageReadOnly())
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                if (!kIsWeb && Platform.isAndroid) {
                  final status = await Permission.storage.status;
                  if (status.isGranted) {
                    await Helper.deleteCacheDir();
                    await Helper.deleteAppUserDataDir();
                  } else {
                    await Permission.storage.request();
                  }
                }
                _pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                //_pickedFile = PickedFile(
                //    '/storage/emulated/0/Download/tardis-wallpaper.jpeg');
                //_pickedFile = PickedFile(
                //    '/assets/images/no_product.jpeg');
                if (_pickedFile != null) {
                  model.state.pickedFile = _pickedFile;
                  final bytes = await _pickedFile!.readAsBytes();
                  if (bytes.lengthInBytes >
                      Constants.DEFAULT_MAX_UPLOAD_FILE_SIZE) {
                    if (mounted) {
                      Helper.showSnackBar(context,
                          '${AppLocalizations.of(context).imageSizeTooBig} ${filesize(bytes.lengthInBytes)}. ${AppLocalizations.of(context).itShouldBeLessThan} ${filesize(Constants.DEFAULT_MAX_UPLOAD_FILE_SIZE)}');
                    }
                  } else {
                    unawaited(_setImageAndCrop());
                  }
                }
              },
              child: Text(AppLocalizations.of(context).productImage),
            ),
            const SizedBox(
              width: 10,
            ),
            if (_pickedFile != null)
              ElevatedButton(
                onPressed: () async {
                  unawaited(_cropImage());
                },
                child: Text(AppLocalizations.of(context).cropImage),
              ),
            const SizedBox(
              width: 10,
            ),
            if (_pickedFile != null)
              ElevatedButton(
                onPressed: () async {
                  _resetImage();
                },
                child: Text(AppLocalizations.of(context).resetImage),
              )
            else
              const SizedBox(height: 1, width: 1),
          ],
        )
      else
        const SizedBox(height: 1, width: 1),
      const SizedBox(
        width: 10,
      ),
    ]);
  }

  void _resetImage() {
    _pickedFile = null;
    _faceImageBytes = null;
    _faceImageUrl = widget.product.faceImageUrl;
    _imageUrl = widget.product.imageUrl;
    _gotImage = false;
    _gotFaceImage = false;
    _gettingImage = false;
    _gettingFaceImage = false;
    _getImage();
    _getFaceImage();
    setState(() {});
  }

  Widget _getCivilNameTextWidget() {
    Widget ret;
    if (_isPageReadOnly()) {
      ret = Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${AppLocalizations.of(context).productCivilname.toUpperCase()}: ',
              style: const MyTextStyle.bold(),
            ),
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 15,
                controller: _controllerCivilName,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ret = TextFormField(
        controller: _controllerCivilName,
        readOnly: _isPageReadOnly(),
        decoration: _getInputDecoration(
            AppLocalizations.of(context).productCivilname,
            AppLocalizations.of(context).productCivilname),
        validator: (value) {
          return null;
        },
      );
    }
    return ret;
  }

  Widget _getWeaponsWidget() {
    Widget ret;
    if (_isPageReadOnly()) {
      ret = Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${AppLocalizations.of(context).productWeapons.toUpperCase()}: ',
              style: const MyTextStyle.bold(),
            ),
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 15,
                controller: _controllerWeapons,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ret = TextFormField(
        controller: _controllerWeapons,
        readOnly: _isPageReadOnly(),
        decoration: _getInputDecoration(
          AppLocalizations.of(context).productWeapons,
          AppLocalizations.of(context).productWeapons,
        ),
        validator: (value) {
          return null;
        },
      );
    }
    return ret;
  }

  Widget _getCodeNameWidget(ProductsStates state) {
    return widget.pageMode != PageMode.EDIT
        ? TextFormField(
            autofocus: true,
            focusNode: _focusNodeCodename,
            controller: _controllerCodename,
            readOnly: _isPageReadOnly() || widget.pageMode == PageMode.EDIT,
            decoration: _getInputDecoration(
              AppLocalizations.of(context).productCodename,
              AppLocalizations.of(context).productCodename,
            ),
            validator: (widget.pageMode == PageMode.CREATE)
                ? (value) {
                    String? ret;
                    if (_validateCodename()) {
                      if (widget.state is ValidatedProductCodeNameState) {
                        final state =
                            widget.state as ValidatedProductCodeNameState;
                        switch (state.validationResult) {
                          case NameValidationResult.VALID:
                            if (value != null) {
                              widget.product.codename = value;
                            }
                            ret = null;
                            break;
                          case NameValidationResult.INVALID_EMPTY:
                            ret =
                                AppLocalizations.of(context).theCodenameIsEmpty;
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
                            ret =
                                AppLocalizations.of(context).invalidCharacters;
                        }
                      } else {
                        if (value == null || value.isEmpty) {
                          ret = AppLocalizations.of(context).productCodename;
                        }
                      }
                    }
                    return ret;
                  }
                : null,
          )
        : Text(widget.product.codename);
  }

  Widget _getHabilitiesWidget() {
    Widget ret;
    if (_isPageReadOnly()) {
      ret = Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${AppLocalizations.of(context).productHabilities.toUpperCase()}: ',
              style: const MyTextStyle.bold(),
            ),
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 15,
                controller: _controllerHabilities,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ret = TextFormField(
        controller: _controllerHabilities,
        readOnly: _isPageReadOnly(),
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        decoration: _getInputDecoration(
          AppLocalizations.of(context).productHabilities,
          AppLocalizations.of(context).productHabilities,
        ),
        validator: (value) {
          if (value != null) {
            widget.product.habilities = value;
          }
          return null;
        },
      );
    }
    return ret;
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
                scrollable: !_isPageReadOnly(),
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
                scrollable: !_isPageReadOnly(),
                focusNode: _focusNodeQuill,
                autoFocus: false,
                readOnly: _isPageReadOnly(),
                expands: false,
                padding: const EdgeInsets.symmetric(
                    horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
                onLaunchUrl: _onLaunchUrl,
              ),
        (_selectedUniverse != null) ? _selectedUniverse!.uid : null,
        addHandCursor: true,
      ),
      if (!_isPageReadOnly())
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
          child: quill.QuillToolbar.basic(controller: _controllerQuill),
        ),
    ];
  }

  Future<void> _onLaunchUrl(String url) async {
    if (kIsWeb) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        //throw 'Could not launch $url';
      }
    } else {
      if (url.startsWith(Constants.DEFAULT_HEROESBOOK_URL)) {
        final uri = Uri.parse(url);
        if (uri.pathSegments.length == 2) {
          String? productUniverse;
          String? productCodename;

          productUniverse = uri.pathSegments[uri.pathSegments.length - 2];
          productCodename = uri.pathSegments[uri.pathSegments.length - 1];

          final universe = await UniversesDao().getByName(productUniverse);
          final products = await ProductsDao().getByCodeName(productCodename,
              universeUID: (universe != null) ? universe.uid : null);
          final ret = products.isNotEmpty ? products[0] : null;
          if (ret != null) {
            if (mounted) {
              unawaited(Navigator.of(context)
                  .pushNamed(Routes.getParameterizedRouteForViewProduct(ret)));
            }
          }
        } else if (uri.pathSegments.length == 1) {
          final universeName = Helper.parameterToString(uri.lastPath());
          final universe = await UniversesDao().getByName(universeName!);
          if (universe != null) {
            if (mounted) {
              unawaited(Navigator.of(context).pushNamed(
                  Routes.getParameterizedRouteForViewUniverse(universe)));
            }
          }
        } else {
          await launch(url);
        }
      } else {
        await launch(url);
      }
    }
    return Future.value(null);
  }

  Widget _getAgeWidget() {
    Widget ret;
    if (_isPageReadOnly()) {
      ret = Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${AppLocalizations.of(context).productAge.toUpperCase()}: ',
              style: const MyTextStyle.bold(),
            ),
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 15,
                controller: _controllerAge,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ret = TextFormField(
        controller: _controllerAge,
        readOnly: _isPageReadOnly(),
        keyboardType: TextInputType.number,
        decoration: _getInputDecoration(
          AppLocalizations.of(context).productAge,
          AppLocalizations.of(context).age,
        ),
        validator: (value) {
          if (value != null) {
            widget.product.age = value;
          }
          return null;
        },
      );
    }
    return ret;
  }

  Row _getLanguageRow() {
    return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Expanded(
        child: TextFormField(
          controller: _controllerLanguage,
          readOnly: true,
          decoration: _getInputDecoration(
            AppLocalizations.of(context).language,
            AppLocalizations.of(context).language,
          ),
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      if (!_isPageReadOnly())
        ElevatedButton(
          onPressed: () {
            Dialogs.showLanguagePickerDialog(context, _updatePickedLanguage);
          },
          child: Text(AppLocalizations.of(context).language),
        )
      else
        const SizedBox(height: 1, width: 1),
      const SizedBox(
        width: 10,
      ),
    ]);
  }

  Widget _getBirthPlaceWidget() {
    Widget ret;
    if (_isPageReadOnly()) {
      ret = Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${AppLocalizations.of(context).productBirthplace.toUpperCase()}: ',
              style: const MyTextStyle.bold(),
            ),
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 15,
                controller: _controllerBirthplace,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ret = TextFormField(
        controller: _controllerBirthplace,
        readOnly: _isPageReadOnly(),
        decoration: _getInputDecoration(
          AppLocalizations.of(context).productBirthplace,
          AppLocalizations.of(context).productBirthplace,
        ),
        validator: (value) {
          if (value != null) {
            widget.product.birthplace = value;
          }
          return null;
        },
      );
    }
    return ret;
  }

  Widget _getTrainningPlaceWidget() {
    Widget ret;
    if (_isPageReadOnly()) {
      ret = Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${AppLocalizations.of(context).productTrainningplace.toUpperCase()}: ',
              style: const MyTextStyle.bold(),
            ),
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 15,
                controller: _controllerTrainningplace,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ret = TextFormField(
        controller: _controllerTrainningplace,
        readOnly: _isPageReadOnly(),
        decoration: _getInputDecoration(
          AppLocalizations.of(context).productTrainningplace,
          AppLocalizations.of(context).productTrainningplace,
        ),
        validator: (value) {
          if (value != null) {
            widget.product.trainningPlace = value;
          }
          return null;
        },
      );
    }
    return ret;
  }

  Widget _getProfessionWidget() {
    Widget ret;
    if (_isPageReadOnly()) {
      ret = Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${AppLocalizations.of(context).productProfession.toUpperCase()}: ',
              style: const MyTextStyle.bold(),
            ),
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 15,
                controller: _controllerProfession,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ret = TextFormField(
        controller: _controllerProfession,
        readOnly: _isPageReadOnly(),
        cursorColor: model.state.pickedColor,
        decoration: _getInputDecoration(
          AppLocalizations.of(context).productProfession,
          AppLocalizations.of(context).productProfession,
        ),
        validator: (value) {
          if (value != null) {
            widget.product.profession = value;
          }
          return null;
        },
      );
    }
    return ret;
  }

  Widget _getPublishedWidget() {
    return (!_isPageReadOnly())
        ? CheckboxListTile(
            value: widget.product.published,
            onChanged: (isChecked) {
              if (!_isPageReadOnly()) {
                setState(() {
                  widget.product.published = isChecked!;
                  model.state.product.published = isChecked;
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
          )
        : const SizedBox(width: 1, height: 1);
  }

  BlocBuilder<UniversesBloc, UniversesStates> _getUniversesBlocBuilder() {
    return BlocBuilder<UniversesBloc, UniversesStates>(
      buildWhen: (previousState, currentState) {
        final build = _universesBuildWhenFilter(previousState, currentState);
        MyLogger().logger.d(
            '[ProductForm]universeBuildWhen. Received previous state -> $previousState. Current state -> $currentState. Build:$build');
        return build;
      },
      builder: (context, state) {
        MyLogger()
            .logger
            .d('[ProductForm]BlocUniverse-builder -> ${state.toString()}');
        if (state is GotMyUniversesState) {
          _isGettingUniverses = false;
          _universes = state.universes;
          if (_selectedUniverse != null &&
              _selectedUniverse != _previousSelectedUniverse &&
              context.isCurrent(this)) {
            _universes.addAllUnique([_selectedUniverse!]);
            Future.delayed(
                const Duration(
                    milliseconds: Constants.DEFAULT_DELAY_TO_GET_HEROES), () {
              final productsEvent =
                  GetAllProductsByUniverseEvent(_selectedUniverse!.uid!);
              model.state.lastEvent = productsEvent;
              BlocProvider.of<ProductsListenerBloc>(context).add(productsEvent);
              checkEventExecutionTime();
            });
          }
        } else if (state is UniversesEmptyState) {
          _isGettingUniverses = false;
        }
        final ret = InputDecorator(
          decoration: _getInputDecoration(
              '', AppLocalizations.of(context).productUniverse,
              isLoading: _isGettingUniverses),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<Universe>(
              value: (widget.pageMode != PageMode.VIEW)
                  ? (_universes.isNotEmpty)
                      ? _selectedUniverse
                      : null
                  : _selectedUniverse,
              hint: Text(AppLocalizations.of(context).productUniverse),
              items: _getListOfUniversesAsDropDownMenuItems(_universes),
              onChanged: _isPageReadOnly()
                  ? (value) {}
                  : (value) {
                      if (context.isCurrent(this)) {
                        setState(() {
                          _previousSelectedUniverse = _selectedUniverse;
                          model.state.selectedUniverse = value;
                          _selectedUniverse = value;
                          if (value != null &&
                              widget.product.universeUID != null &&
                              widget.product.universeUID != value.uid &&
                              context.isCurrent(this)) {
                            _productFriends.clear();
                            _productFriendsAsDropDownMenuItems.clear();
                            widget.product.friends.clear();
                            widget.product.friendsUIDS.clear();
                            // _productEnemies.clear();
                            _productEnemiesAsDropDownMenuItems.clear();
                            widget.product.enemies.clear();
                            widget.product.enemiesUIDS.clear();
                          }
                          if (widget.product.universeUID != value!.uid) {
                            widget.product.universeUID = value.uid;
                            widget.product.clearUniverse();
                            unawaited(widget.product.getUniverse());
                          }
                          if (!_isGettingProductsByUniverse) {
                            _isGettingProductsByUniverse = true;
                          }
                          Future.delayed(
                              const Duration(
                                  milliseconds: Constants
                                      .DEFAULT_DELAY_TO_GET_HEROES), () {
                            final productsEvent = GetAllProductsByUniverseEvent(
                                _selectedUniverse!.uid!);
                            model.state.lastEvent = productsEvent;
                            BlocProvider.of<ProductsListenerBloc>(context)
                                .add(productsEvent);
                            checkEventExecutionTime();
                          });
                        });
                      }
                    },
            ),
          ),
        );
        return ret;
      },
    );
  }

  Widget _getCreateUniverseWidget() {
    return (!_isPageReadOnly())
        ? Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
            child: ElevatedButton(
              onPressed: () async {
                final universe = await Navigator.of(context).pushNamed(
                    Routes.getParameterizedRouteForCreateUniverse(
                        returnUniverse: true),
                    arguments: CreateUniversePageArguments()) as Universe?;
                if (universe != null) {
                  _universes.add(universe);
                  _selectedUniverse = universe;
                  model.state.selectedUniverse = universe;
                  if (mounted) {
                    setState(() {});
                  }
                }
              },
              child: Text(AppLocalizations.of(context).productCreateuniverse),
            ),
          )
        : const SizedBox(height: 1, width: 1);
  }

  BlocConsumer<ProductsListenerBloc, ProductsStates>
      _getProductsFriendsBlocConsumer() {
    return BlocConsumer<ProductsListenerBloc, ProductsStates>(
        listenWhen: (previousState, currentState) {
      final listen =
          _productsFriendsListenWhenFilter(previousState, currentState);
      MyLogger().logger.d(
          '[ProductForm]productsFriendsListenWhen. Received previous state -> $previousState. Current state -> $currentState. Listen:$listen');
      return listen;
    }, buildWhen: (previousState, currentState) {
      final build = _productsFriendsBuildWhenFilter(previousState, currentState);
      MyLogger().logger.d(
          '[ProductForm]productsFriendsBuildWhen. Received previous state -> $previousState. Current state -> $currentState. Build:$build');
      return build;
    }, builder: (context, state) {
      return (_isPageReadOnly())
          ? _getFriendsListView()
          : _getFriendsDropDownList();
    }, listener: (context, state) async {
      MyLogger()
          .logger
          .d('[ProductForm]productsFriendsListen. Current state -> $state');
      model.state.checkEventExecutionTimeTimer?.cancel();
      model.state.checkEventExecutionTimeTimer = null;
      model.state.lastEvent = null;
      if (state is GotAllProductsByUniverseState) {
        state.products.remove(widget.product);
        final previousFriends = _productFriends;
        _productFriends = state.products;
        _productFriendsAsDropDownMenuItems =
            await _getListOfProductsForFriendsAsDropDownMenuItems(
                _productFriends, !_isPageReadOnly() ? _onCheckboxChanged : null);
        _dropDownFriendsSelectedValue = (_dropDownFriendsSelectedValue == null)
            ? _productFriends.first
            : _dropDownFriendsSelectedValue;
        if (_isGettingProductsByUniverse ||
            !previousFriends.containsAll(state.products) ||
            _dropDownFriendsSelectedValue == null) {
          _isGettingProductsByUniverse = false;
        }
      } else if (state is ProductsEmptyState) {
        if (_isGettingProductsByUniverse) {
          _isGettingProductsByUniverse = false;
        }
      }
    });
  }

  Flexible _getFriendsListView() {
    return Flexible(
      child: (_productFriends.isNotEmpty)
          ? ListProductsWidget(
              products: _productFriends,
              title: AppLocalizations.of(context).friends.toUpperCase())
          : Center(
              child: Text(AppLocalizations.of(context).noFriends,
                  style: const MyTextStyle.bold())),
    );
  }

  InputDecorator _getFriendsDropDownList() {
    return InputDecorator(
      decoration: _getInputDecoration(
          '', AppLocalizations.of(context).productFriends,
          isLoading: _isGettingProductsByUniverse),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<my_app.Product>(
          value: _dropDownFriendsSelectedValue,
          validator: (value) {
            return null;
          },
          hint: Text(AppLocalizations.of(context).productFriends),
          items: _productFriendsAsDropDownMenuItems,
          onChanged: (value) async {
            _productFriendsAsDropDownMenuItems =
                await _getListOfProductsForFriendsAsDropDownMenuItems(
                    _productFriends,
                    !_isPageReadOnly() ? _onCheckboxChanged : null);
            _productEnemiesAsDropDownMenuItems =
                await _getListOfProductsForEnemiesAsDropDownMenuItems(
                    _productEnemies,
                    !_isPageReadOnly() ? _onCheckboxChanged : null);
            setState(() {
              _dropDownFriendsSelectedValue = value;
            });
          },
        ),
      ),
    );
  }

  BlocConsumer<ProductsListenerBloc, ProductsStates>
      _getProductsEnemiesBlocConsumer() {
    return BlocConsumer<ProductsListenerBloc, ProductsStates>(
        listenWhen: (previousState, currentState) {
      final listen =
          _productsEnemiesListenWhenFilter(previousState, currentState);
      MyLogger().logger.d(
          '[ProductForm]productsEnemiesListenWhen. Received previous state -> $previousState. Current state -> $currentState. Listen:$listen');
      return listen;
    }, buildWhen: (previousState, currentState) {
      final build = _productsEnemiesBuildWhenFilter(previousState, currentState);
      MyLogger().logger.d(
          '[ProductForm]productsEnemiesBuildWhen. Received previous state -> $previousState. Current state -> $currentState. Build:$build');
      return build;
    }, builder: (context, state) {
      return (_isPageReadOnly())
          ? _getEnemiesListView()
          : _getEnemiesDropDownList();
    }, listener: (context, state) async {
      MyLogger()
          .logger
          .d('[ProductForm]productsEnemiesListen. Current state -> $state');
      if (state is GotAllProductsByUniverseState) {
        model.state.checkEventExecutionTimeTimer?.cancel();
        model.state.checkEventExecutionTimeTimer = null;
        model.state.lastEvent = null;
        state.products.remove(widget.product);
        final previousEnemies = _productEnemies;
        _productEnemies = state.products;
        _productEnemiesAsDropDownMenuItems =
            await _getListOfProductsForEnemiesAsDropDownMenuItems(
                _productEnemies, !_isPageReadOnly() ? _onCheckboxChanged : null);
        _dropDownEnemiesSelectedValue = (_dropDownEnemiesSelectedValue == null)
            ? _productEnemies.first
            : _dropDownEnemiesSelectedValue;
        if (_isGettingProductsByUniverse ||
            !previousEnemies.containsAll(state.products) ||
            _dropDownEnemiesSelectedValue == null) {
          _isGettingProductsByUniverse = false;
        }
      } else if (state is ProductsEmptyState) {
        if (_isGettingProductsByUniverse) {
          _isGettingProductsByUniverse = false;
        }
      }
    });
  }

  Flexible _getEnemiesListView() {
    return Flexible(
      child: (_productEnemies.isNotEmpty)
          ? ListProductsWidget(
              products: _productEnemies,
              title: AppLocalizations.of(context).enemies.toUpperCase())
          : Center(
              child: Text(AppLocalizations.of(context).noEnemies,
                  style: const MyTextStyle.bold())),
    );
  }

  InputDecorator _getEnemiesDropDownList() {
    return InputDecorator(
      decoration: _getInputDecoration(
          '', AppLocalizations.of(context).productEnemies,
          isLoading: _isGettingProductsByUniverse),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<my_app.Product>(
          value: _dropDownEnemiesSelectedValue,
          validator: (value) {
            return null;
          },
          hint: Text(AppLocalizations.of(context).productEnemies),
          items: _productEnemiesAsDropDownMenuItems,
          onChanged: (value) async {
            _productFriendsAsDropDownMenuItems =
                await _getListOfProductsForFriendsAsDropDownMenuItems(
                    _productFriends,
                    !_isPageReadOnly() ? _onCheckboxChanged : null);
            _productEnemiesAsDropDownMenuItems =
                await _getListOfProductsForEnemiesAsDropDownMenuItems(
                    _productEnemies,
                    !_isPageReadOnly() ? _onCheckboxChanged : null);
            setState(() {
              _dropDownEnemiesSelectedValue = value;
            });
          },
        ),
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

  SmoothStarRating _getRatingWidget() {
    return SmoothStarRating(
      rating: widget.product.getMediumGrade(),
      isReadOnly:
          (widget.pageMode == PageMode.VIEW) && (LoggedUser().hasUser()),
      color: Colors.amber,
      borderColor: Colors.amber,
      size: Constants.DEFAULT_STAR_SIZE_DETAILS,
      spacing: Constants.DEFAULT_STAR_SPACING,
      onRated: (rating) {
        if (context.isCurrent(this)) {
          var grade = widget.product.getMyGrade(LoggedUser().user!.uid!);
          if (grade == null) {
            grade = Grade()..userUID = LoggedUser().user!.uid;
            widget.product.grades.add(grade);
          }
          grade.grade = rating;
          BlocProvider.of<ProductsListenerBloc>(context)
              .add(UpdateProductGradesEvent(widget.product.grades, widget.product.uid!));
          Helper.showSnackBar(context, AppLocalizations.of(context).updating);
        }
      },
    );
  }

  Widget _getSaveProductWidget(ProductsStates state) {
    return (!_isPageReadOnly())
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Spacer(),
              ElevatedButton(
                onPressed: _saveEnabled && LoggedUser().hasUser()
                    ? () {
                        // Validate returns true if the form is valid, otherwise false.
                        if (_formKey.currentState!.validate()) {
                          if (LoggedUser().hasUser()) {
                            if (_selectedUniverse != null) {
                              if (widget.state is ValidatedProductCodeNameState &&
                                  _validateCodename()) {
                                final state =
                                    widget.state as ValidatedProductCodeNameState;
                                switch (state.validationResult) {
                                  case NameValidationResult.VALID:
                                    _saveProduct(context);
                                    break;
                                  case NameValidationResult.INVALID_EMPTY:
                                    Helper.showSnackBar(
                                        context,
                                        AppLocalizations.of(context)
                                            .theCodenameIsEmpty);
                                    break;
                                  case NameValidationResult
                                      .INVALID_ALREADY_EXISTS:
                                    Helper.showSnackBar(
                                        context,
                                        AppLocalizations.of(context)
                                            .pleaseSelectAnotherCodename);
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
                                if (!state.isValid) {
                                  _focusNodeCodename.requestFocus();
                                }
                              } else {
                                if (widget.pageMode == PageMode.CREATE) {
                                  if (context.isCurrent(this)) {
                                    BlocProvider.of<ProductsBloc>(context).add(
                                        ValidateProductCodeNameEvent(
                                            Constants.DEFAULT_HEROESBOOK_URL +
                                                _controllerCodename.text,
                                            _selectedUniverse!.uid!));
                                    setState(() {
                                      model.state.shouldSave = true;
                                      _saveEnabled = false;
                                    });
                                  }
                                } else {
                                  _saveProduct(context);
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
        : const SizedBox(height: 1, width: 1);
  }

  Widget _getDeleteProductWidget() {
    return (_isPageReadOnly() &&
            LoggedUser().hasUser() &&
            LoggedUser().isMyProduct(widget.product))
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  final ret =
                      await Dialogs.showDeleteConfirmationDialog(context);
                  if (mounted) {
                    if (ret == Dialogs.DELETE_DIALOG_RET_CONFIRM &&
                        context.isCurrent(this)) {
                      BlocProvider.of<ProductsBloc>(context).add(
                          CanDeleteProductEvent(
                              widget.product, LoggedUser().user!.uid!));
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
    return (_isPageReadOnly() && widget.product.uid != null)
        ? AllCommentsWidget(ElementType.HERO, widget.product.uid!)
        : const SizedBox(height: 1, width: 1);
  }

  void _saveProduct(BuildContext context) {
    widget.product.userUID = LoggedUser().user!.uid;
    widget.product.civilName = _controllerCivilName.text;
    widget.product.weapons = _controllerWeapons.text;
    widget.product.codename = _controllerCodename.text;
    widget.product.habilities = _controllerHabilities.text;
    widget.product.birthplace = _controllerBirthplace.text;
    widget.product.trainningPlace = _controllerTrainningplace.text;
    widget.product.profession = _controllerProfession.text;
    widget.product.age = _controllerAge.text;
    widget.product.story =
        jsonEncode(_controllerQuill.document.toDelta().toJson());
    widget.product.color = model.state.pickedColor.toString();
    _getFriends();
    _getEnemies();
    if (widget.product.universe == null) {
      unawaited(widget.product.getUniverse());
    }
    if (context.isCurrent(this)) {
      if (widget.pageMode == PageMode.CREATE) {
        if (widget.product.imageUrl != null) {
          if (widget.product.imageUrl!.isFromStorage()) {
            widget.product.previousImageUrl = widget.product.imageUrl;
          }
        }
        if (widget.product.faceImageUrl != null) {
          if (widget.product.faceImageUrl!.isFromStorage()) {
            widget.product.previousFaceImageUrl = widget.product.faceImageUrl;
          }
        }
        widget.product.imageUrl = _imageUrl;
        widget.product.faceImageUrl = _faceImageUrl;
        widget.product.faceImageAsBytes = _faceImageBytes;
        BlocProvider.of<ProductsBloc>(context).add(SaveProductEvent(widget.product));
        Future.delayed(
            const Duration(
                milliseconds:
                    Constants.DEFAULT_SAVING_OR_UPDATING_MESSAGE_DELAY), () {
          Helper.showSnackBar(context, AppLocalizations.of(context).saving);
        });
      } else if (widget.pageMode == PageMode.EDIT) {
        if (widget.product.imageUrl != null && widget.product.imageUrl != _imageUrl) {
          if (widget.product.imageUrl!.isFromStorage()) {
            widget.product.previousImageUrl = widget.product.imageUrl;
          } else {
            widget.product.previousImageUrl = null;
          }
        }
        if (widget.product.faceImageUrl != null &&
            widget.product.faceImageUrl != _faceImageUrl) {
          if (widget.product.faceImageUrl!.isFromStorage()) {
            widget.product.previousFaceImageUrl = widget.product.faceImageUrl;
          } else {
            widget.product.previousFaceImageUrl = null;
          }
        }
        if (widget.product.imageUrl != _imageUrl) {
          widget.product.imageUrl = _imageUrl;
          widget.product.faceImageUrl = _faceImageUrl;
          widget.product.faceImageAsBytes = _faceImageBytes;
        }
        BlocProvider.of<ProductsBloc>(context).add(UpdateProductEvent(widget.product));
        Future.delayed(
            const Duration(
                milliseconds:
                    Constants.DEFAULT_SAVING_OR_UPDATING_MESSAGE_DELAY), () {
          Helper.showSnackBar(context, AppLocalizations.of(context).updating);
        });
      } else {
        throw Exception('Invalid page mode for saving product:${widget.pageMode}');
      }
    } else {
      throw Exception('Page is not currently visible');
    }
    Future.delayed(
        const Duration(
            milliseconds: Constants.DEFAULT_DELAY_TO_UPDATED_ENTITIES), () {
      BlocProvider.of<ProductsListenerBloc>(context).add(
          GetAllProductsPaginatedTranslatedAndOrderedEvent(
              orderBy: OrderBy.UPDATE_DATE));
    });
  }

  Future<void> _setImageAndCrop() async {
    if (_pickedFile != null) {
      _updatePickedImage(Uri.parse(_pickedFile!.path));
      unawaited(_cropImage());
    }
  }

  static const String SENDER_ENEMIES = 'ENEMIES';
  static const String SENDER_FRIENDS = 'FRIENDS';

  void _onCheckboxChanged(String sender, my_app.Product product, bool value) {
    switch (sender) {
      case SENDER_ENEMIES:
        {
          if (value) {
            widget.product.friendsUIDS.remove(product.uid);
            widget.product.enemiesUIDS.add(product.uid!);
            widget.product.friends.remove(product);
            widget.product.enemies.add(product);
          } else {
            widget.product.enemiesUIDS.remove(product.uid);
            widget.product.enemies.remove(product);
          }
        }
        break;
      case SENDER_FRIENDS:
        {
          if (value) {
            widget.product.enemiesUIDS.remove(product.uid);
            widget.product.friendsUIDS.add(product.uid!);
            widget.product.enemies.remove(product);
            widget.product.friends.add(product);
          } else {
            widget.product.friendsUIDS.remove(product.uid);
            widget.product.friends.remove(product);
          }
        }
        break;
    }
    unawaited(product.getUniverse());
    widget.product.enemiesUIDS = widget.product.enemiesUIDS.toSet().toList();
    widget.product.friendsUIDS = widget.product.friendsUIDS.toSet().toList();
    model.state.product.enemiesUIDS = widget.product.enemiesUIDS;
    model.state.product.friendsUIDS = widget.product.friendsUIDS;
  }

  Future<Image> _getFaceImageForDropdown(my_app.Product product) async {
    final data = await product.getFaceImage();
    return _setFaceImageForDropdown(data);
  }

  Image _setFaceImageForDropdown(Uint8List? data) {
    Image image;
    if (data != null && data.isNotEmpty) {
      image = Image.memory(
        data,
        fit: BoxFit.cover,
        width: Constants.DEFAULT_DROPDOWN_FACE_IMAGE_WIDTH,
        height: Constants.DEFAULT_DROPDOWN_FACE_IMAGE_HEIGHT,
      );
    } else {
      image = const Image(
        image: AssetImage(Images.noFace),
        fit: BoxFit.cover,
        width: Constants.DEFAULT_DROPDOWN_FACE_IMAGE_WIDTH,
        height: Constants.DEFAULT_DROPDOWN_FACE_IMAGE_HEIGHT,
      );
    }
    return image;
  }

  Future<void> _getFaceImage() async {
    if (!_gotDefaultFaceImage && !_gotFaceImage && !_gettingFaceImage) {
      _gettingFaceImage = true;
      if (_isPageReadOnly() ||
          (widget.pageMode == PageMode.EDIT && !_useCroppedFaceImage)) {
        if (widget.product.hasGotFaceImage()) {
          final bytes = await widget.product.getFaceImageBytes();
          _setFaceImageAsBytes(bytes);
          _gettingFaceImage = false;
        } else if (widget.product.isGettingFaceImage()) {
          showLoadingFaceImage();
          await widget.product.faceImageAsBytesFuture!.then((bytes) {
            _setFaceImageAsBytes(bytes);
            widget.product.faceImageAsBytesFuture = null;
            _gettingFaceImage = false;
          });
        } else {
          showLoadingFaceImage();
          await widget.product.getFaceImage().then((bytes) {
            _setFaceImageAsBytes(bytes);
            widget.product.faceImageAsBytesFuture = null;
            _gettingFaceImage = false;
          });
        }
      } else {
        if (_faceImageBytes != null && _faceImageBytes!.isNotEmpty) {
          _setFaceImageAsBytes(_faceImageBytes);
        } else if (_faceImageUrl != null && _faceImageUrl!.path.isNotEmpty) {
          final bytes = await _faceImageUrl!.downloadBytes();
          _setFaceImageAsBytes(bytes);
        } else {
          _setFaceImageAsBytes(null);
        }
        _gettingFaceImage = false;
      }
    }
  }

  void showLoadingFaceImage() {
    setState(() {
      _faceImage = _getLoadingFaceImagePlaceholder();
    });
  }

  SizedBox _getLoadingFaceImagePlaceholder() {
    return const SizedBox(
      width: Constants.DEFAULT_FACE_IMAGE_WIDTH,
      height: Constants.DEFAULT_FACE_IMAGE_HEIGHT,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  void _setFaceImageAsBytes(Uint8List? bytes) {
    if (bytes != null && bytes.isNotEmpty) {
      _gotFaceImage = true;
      _faceImage = Image.memory(
        bytes,
        gaplessPlayback: true,
        key: UniqueKey(),
        fit: BoxFit.scaleDown,
        cacheWidth: Constants.DEFAULT_FACE_IMAGE_WIDTH.toInt(),
        cacheHeight: Constants.DEFAULT_FACE_IMAGE_HEIGHT.toInt(),
        width: Constants.DEFAULT_FACE_IMAGE_WIDTH,
        height: Constants.DEFAULT_FACE_IMAGE_HEIGHT,
      );
      precacheImage((_faceImage as Image).image, context);
      if (mounted) {
        setState(() {});
      }
    } else {
      _gotDefaultFaceImageTriesCount++;
      if (_gotDefaultFaceImageTriesCount >
          Constants.DEFAULT_GET_FACE_IMAGE_TRY_LIMIT) {
        _gotDefaultFaceImageTriesCount = 0;
        _gotDefaultFaceImage = true;
      }
      _faceImage = Image(
        gaplessPlayback: true,
        image: _faceImagePlaceholder,
        fit: BoxFit.cover,
        width: Constants.DEFAULT_FACE_IMAGE_WIDTH,
        height: Constants.DEFAULT_FACE_IMAGE_HEIGHT,
      );
      precacheImage((_faceImage as Image).image, context);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _getImage() async {
    if (!_gotDefaultImage && !_gotImage && !_gettingImage) {
      _gettingImage = true;
      setState(() {});
      if (_isPageReadOnly() ||
          (widget.pageMode == PageMode.EDIT && !_useCroppedImage)) {
        if (widget.product.hasGotImage()) {
          final bytes = await widget.product.getImageBytes();
          await _setImageAsBytes(bytes);
          _gettingImage = false;
        } else if (widget.product.isGettingImage()) {
          await showLoadingImage();
          await widget.product.imageAsBytesFuture!.then((bytes) async {
            await _setImageAsBytes(bytes);
            widget.product.imageAsBytesFuture = null;
            _gettingImage = false;
          });
        } else {
          await showLoadingImage();
          await widget.product.getImage().then((bytes) async {
            await _setImageAsBytes(bytes);
            widget.product.imageAsBytesFuture = null;
            _gettingImage = false;
          });
        }
      } else {
        if (_imageUrl != null && _imageUrl!.path.isNotEmpty) {
          final bytes = await _imageUrl!.downloadBytes();
          await _setImageAsBytes(bytes);
        } else {
          await _setImageAsBytes(null);
        }
        _gettingImage = false;
      }
    }
  }

  Future<void> showLoadingImage() async {
    _image = await _getLoadingImagePlaceholder();
    setState(() {});
  }

  Future<Product> _getLoadingImagePlaceholder() async {
    final identifier = (await widget.product.getIdentifier()).toUpperCase();
    return Product(
      tag: '${Constants.DEFAULT_HERO_HERO_IMAGE_TAG}_$identifier',
      child: const SizedBox(
        width: 581,
        height: 587,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<void> _setImageAsBytes(Uint8List? bytes) async {
    final identifier = (await widget.product.getIdentifier()).toUpperCase();
    if (bytes != null && bytes.isNotEmpty) {
      _gotImage = true;
      final image = Image.memory(
        bytes,
        gaplessPlayback: true,
        key: UniqueKey(),
        cacheWidth: Constants.DEFAULT_HERO_IMAGE_WIDTH.toInt(),
        cacheHeight: Constants.DEFAULT_HERO_IMAGE_HEIGHT.toInt(),
        //width: Constants.DEFAULT_HERO_IMAGE_WIDTH,
        //height: Constants.DEFAULT_HERO_IMAGE_HEIGHT,
        fit: BoxFit.scaleDown,
      );
      _image = Product(
          tag: '${Constants.DEFAULT_HERO_HERO_IMAGE_TAG}_$identifier',
          child: image);
      if (mounted) {
        await precacheImage(image.image, context);
        setState(() {});
      }
    } else {
      _gotDefaultImageTriesCount++;
      if (_gotDefaultImageTriesCount > Constants.DEFAULT_GET_IMAGE_TRY_LIMIT) {
        _gotDefaultImageTriesCount = 0;
        _gotDefaultImage = true;
      }
      final image = Image(
        gaplessPlayback: true,
        image: _imagePlaceholder,
        fit: BoxFit.cover,
      );
      _image = Product(
          tag: '${Constants.DEFAULT_HERO_HERO_IMAGE_TAG}_$identifier',
          child: image);
      if (mounted) {
        await precacheImage(image.image, context);
        setState(() {});
      }
    }
  }

  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      //if (!kIsWeb) {
      if (false) {
        final cropped = await ImageCropper.cropImage(
            sourcePath: _pickedFile!.path,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            androidUiSettings: AndroidUiSettings(
                toolbarTitle: AppLocalizations.of(context).cropImage,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            iosUiSettings: IOSUiSettings(
              title: AppLocalizations.of(context).cropImage,
            ));
        if (cropped != null) {
          setState(() {
            _updatePickedFaceImage(cropped.uri);
          });
        }
      } else {
        final icwa = ImageCropWidgetArguments(
            imageBytes: await _pickedFile!.readAsBytes());
        Uint8List? bytes;
        if (mounted) {
          bytes = await Navigator.pushNamed(context, Routes.imageCropWidget,
              arguments: icwa) as Uint8List?;
        }
        if (bytes != null) {
          MyLogger()
              .logger
              .i('Received ${bytes.length} bytes from cropping page');
          setState(() {
            _updatePickedFaceImageAsBytes(bytes!);
          });
        } else {
          MyLogger().logger.i('No cropped page returned');
        }
      }
    }
  }

  List<DropdownMenuItem<Universe>> _getListOfUniversesAsDropDownMenuItems(
      List<Universe> universes) {
    final ret = <DropdownMenuItem<Universe>>[];
    for (final universe in universes) {
      final universeText = (kDebugMode || kProfileMode)
          ? '${universe.toString()} - ${AppLocalizations.of(context).products}: ${universe.getNumberOfPublishedProducts()}'
          : universe.toString();
      ret.add(
        DropdownMenuItem<Universe>(
          value: universe,
          child: Text(universeText),
        ),
      );
    }
    return ret;
  }

  Future<List<DropdownMenuItem<my_app.Product>>>
      _getListOfProductsAsDropDownMenuItems(String sender,
          List<my_app.Product> products, Function? onCheckboxChanged) async {
    final ret = <DropdownMenuItem<my_app.Product>>[];
    for (final product in products) {
      final _faceImage = await _getFaceImageForDropdown(product);
      var _checkBoxState = (sender == SENDER_FRIENDS)
          ? widget.product.friendsUIDS.contains(product.uid)
          : widget.product.enemiesUIDS.contains(product.uid);
      ret.add(
        DropdownMenuItem<my_app.Product>(
          onTap: () {
            if (!_isPageReadOnly()) {
              _checkBoxState = !_checkBoxState;
              if (onCheckboxChanged != null) {
                // ignore: avoid_dynamic_calls
                onCheckboxChanged(sender, product, _checkBoxState);
              }
            } else {
              Navigator.of(context)
                  .pushNamed(Routes.getParameterizedRouteForViewProduct(product));
            }
          },
          value: product,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (_checkBoxState) _widgetChecked,
              if (!_checkBoxState) _widgetUnchecked,
              _faceImage,
              Text(product.toString()),
            ],
          ),
        ),
      );
    }

    return ret;
  }

  Future<List<DropdownMenuItem<my_app.Product>>>
      _getListOfProductsForEnemiesAsDropDownMenuItems(
          List<my_app.Product> products, Function? onCheckboxChanged) async {
    return _getListOfProductsAsDropDownMenuItems(
        SENDER_ENEMIES, products, onCheckboxChanged);
  }

  Future<List<DropdownMenuItem<my_app.Product>>>
      _getListOfProductsForFriendsAsDropDownMenuItems(
          List<my_app.Product> products, Function? onCheckboxChanged) async {
    return _getListOfProductsAsDropDownMenuItems(
        SENDER_FRIENDS, products, onCheckboxChanged);
  }

  void _getMyUniverses(BuildContext context, int delay) {
    if (context.isCurrent(this)) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (!_isGettingUniverses) {
          setState(() {
            _isGettingUniverses = true;
          });
        }
        BlocProvider.of<UniversesBloc>(context)
            .add(GetMyUniversesEvent(LoggedUser().user!.uid!));
      });
    }
  }

  InputDecoration _getInputDecoration(String hintText, String labelText,
      {bool isLoading = false}) {
    return InputDecoration(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: widget.product.getColorObject()),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: widget.product.getColorObject()),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(
            color: (_isPageReadOnly())
                ? widget.product.getColorObject()
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
          color: widget.product.getColorObject()),
      hintText: hintText,
      labelText: labelText,
    );
  }
}
