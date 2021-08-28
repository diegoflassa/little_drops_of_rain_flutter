import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:language_pickers/language_pickers.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/products_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/products_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/states/products_states.dart';
import 'package:little_drops_of_rain_flutter/data/dao/users_dao.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart';
import 'package:little_drops_of_rain_flutter/enums/element_type.dart';
import 'package:little_drops_of_rain_flutter/enums/page_mode.dart';
import 'package:little_drops_of_rain_flutter/extensions/build_context_extensions.dart';
import 'package:little_drops_of_rain_flutter/extensions/uri_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/logged_user.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/listeners/firebase_listener.dart';
import 'package:little_drops_of_rain_flutter/real_main.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:little_drops_of_rain_flutter/routing/routing_data.dart';
import 'package:little_drops_of_rain_flutter/ui/my_scaffold.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/empty_item_page.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/error_page.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/loading_page.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/hero_form.dart';

import 'package:pedantic/pedantic.dart';

class CreateProductPageArguments {
  CreateProductPageArguments({this.clearForm = true});

  final bool clearForm;
}

class ViewProductPage extends StatefulWidget {
  const ViewProductPage(this.routingData,
      {Key? key, this.title = Constants.APP_NAME})
      : super(key: key);

  static const String ROUTING_PARAM_PRODUCT_UID = 'productUID';
  static const String routeNameView = '/viewProduct';
  final RoutingData routingData;
  final String? title;

  @override
  _ViewProductPageState createState() => _ViewProductPageState();
}

class _ViewProductPageState extends State<ViewProductPage> {
  Product _product = Product();

  late FirebaseListener universesListener;
  late FirebaseListener storiesListener;

  // ignore: cancel_subscriptions
  StreamSubscription<User?>? _unsubscribe;

  PageMode _pageMode = PageMode.UNKNOWN;

  RoutingData? _routingData;
  bool _hasShowProductSaved = false;
  bool _hasShowProductUpdated = false;
  bool _clearForm = false;

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute
        .of(context)
        ?.settings
        .arguments as CreateProductPageArguments?;
    if (args != null) {
      _clearForm = args.clearForm;
    }
    final scaffold = MyScaffold(
      title: (widget.title != null) ? widget.title : '',
      body: _buildBody(context),
    );
    return scaffold;
  }

  @override
  void initState() {
    super.initState();
    _pageMode = PageMode.CREATE;
    _processRoutingData(context);
    if (!LoggedUser().hasUser()) {
      LoggedUser().addListener(_loggedUserListener);
      final auth = FirebaseAuth.instance;
      _unsubscribe = auth.authStateChanges().listen(
            (user) async {
          final userFromFirebase = Helper.firebaseUserToUser(user);
          if (userFromFirebase != null) {
            LoggedUser().user =
            await UsersDao().getByEmail(userFromFirebase.email);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    if (_unsubscribe != null) {
      _unsubscribe!.cancel();
    }
    LoggedUser().removeListener(_loggedUserListener);
    super.dispose();
  }

  Future<void> _loggedUserListener() async {}

  bool _listenWhenFilter(ProductsStates previousState,
      ProductsStates currentState) {
    return context.isCurrent(this) &&
        (previousState != currentState) &&
        (currentState is! ProductsInitialState) &&
        (currentState is! GettingProductsDataState) &&
        (currentState is! GettingProductDataState) &&
        (currentState is! GotAllProductsPaginatedAndTranslatedState) &&
        (currentState is! GotAllProductsPaginatedTranslatedAndOrderedState) &&
        (currentState is! GotMyProductsPaginatedAndTranslatedState) &&
        (currentState is! GotMyProductsPaginatedTranslatedAndOrderedState) &&
        (currentState is! GotAllProductsState) &&
        (currentState is! GotAllProductsByUniverseState) &&
        (currentState is! GotMyProductsState) &&
        (currentState is! GotMyProductState) &&
        (currentState is! GotProductState) &&
        (currentState is! GotProductsByCivilNameState) &&
        (currentState is! GotProductByCodeNameState) &&
        (currentState is! GotProductsByCodeNameState) &&
        (currentState is! GotProductsByCivilOrCodeNameState) &&
        (currentState is! ProductsChangedState) &&
        //(currentState is! SavingProductState) &&
        //(currentState is! ProductSavedState) &&
        //(currentState is! UpdatingProductState) &&
        //(currentState is! ProductUpdatedState) &&
        //(currentState is! CanDeleteProductState) &&
        //(currentState is! ProductDeletedState) &&
        (currentState is! ProductsEmptyState) &&
        (currentState is! SearchProductsResultsState) &&
        (currentState is! ValidatedProductCodeNameState) &&
        (currentState is! ProductErrorState) &&
        (currentState is! GotProductErrorState) &&
        (currentState is! ProductTranslationErrorState);
  }

  bool _buildWhenFilter(ProductsStates previousState, ProductsStates currentState) {
    return context.isCurrent(this) &&
        (previousState != currentState) &&
        //(currentState is ProductsInitialState) &&
        (currentState is! GettingProductsDataState) &&
        (currentState is! GotAllProductsPaginatedAndTranslatedState) &&
        (currentState is! GotAllProductsPaginatedTranslatedAndOrderedState) &&
        (currentState is! GotMyProductsPaginatedAndTranslatedState) &&
        (currentState is! GotMyProductsPaginatedTranslatedAndOrderedState) &&
        (currentState is! GotAllProductsState) &&
        (currentState is! GotAllProductsByUniverseState) &&
        (currentState is! GotMyProductsState) &&
        //(currentState is! GotMyProductState) &&
        //(currentState is! GotProductState) &&
        //(currentState is! GotProductByCodeNameState) &&
        (currentState is! GotProductsByCodeNameState) &&
        //(currentState is! GotProductsByCivilNameState) &&
        //!(currentState is! GotProductsByCivilOrCodeNameState) &&
        (currentState is! ProductsChangedState) &&
        (currentState is! SavingProductState) &&
        //(currentState is! ProductSavedState) &&
        (currentState is! UpdatingProductState) &&
        //(currentState is! ProductUpdatedState) &&
        (currentState is! CanDeleteProductState) &&
        (currentState is! ProductDeletedState) &&
        //(currentState is! ProductsEmptyState) &&
        (currentState is! SearchProductsResultsState);
    //(currentState is! ValidatedProductCodeNameState) &&
    //(currentState is! ProductErrorState) &&
    //(currentState is! GotProductErrorState) &&
    //(currentState is! ProductTranslationErrorState);
  }

  bool _buildWhenFilterDataState(ProductsStates previousState,
      ProductsStates currentState) {
    var ret = true;
    if (currentState is GettingProductDataState) {
      ret = context.isCurrent(this) &&
          currentState.event is! ValidateProductCodeNameEvent &&
          currentState.event is! GetAllProductsByUniverseEvent;
    }
    return ret;
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<ProductsBloc, ProductsStates>(
      listenWhen: (previousState, currentState) {
        final listen = _listenWhenFilter(previousState, currentState);
        MyLogger().logger.d(
            '[CreateProduct]listenWhen. Received previous state -> $previousState. Current state -> $currentState. Listen:$listen');
        return listen;
      },
      buildWhen: (previousState, currentState) {
        final build = _buildWhenFilter(previousState, currentState) &&
            _buildWhenFilterDataState(previousState, currentState);
        MyLogger().logger.d(
            '[CreateProduct]buildWhen. Received previous state -> $previousState. Current state -> $currentState. Build:$build');
        return build;
      },
      listener: (context, state) async {
        MyLogger()
            .logger
            .d('[CreateProduct]listener. Received state -> ${state.toString()}');
        if (state is CanDeleteProductState) {
          if (state.can) {
            if (context.isCurrent(this)) {
              BlocProvider.of<ProductsBloc>(context).add(DeleteProductEvent(_product));
            }
          } else {
            Helper.processCanDeleteResult(
                state.result, state.references, context);
          }
        }
        if (state is ProductDeletedState) {
          Helper.showSnackBar(
            context,
            AppLocalizations
                .of(context)
                .productDeleted,
          );
          unawaited(Navigator.pushNamed(
              context,
              Routes.getParameterizedRouteByViewElements(ElementType.PRODUCT,
                  myElements: true)));
        }
        if (state is SavingProductState) {
          _hasShowProductSaved = false;
        }
        if (state is ProductSavedState) {
          _pageMode = PageMode.VIEW;
          if (!_hasShowProductSaved) {
            _hasShowProductSaved = true;
            Helper.showSnackBar(
              context,
              AppLocalizations
                  .of(context)
                  .productSaved,
            );
          }
        }
        if (state is UpdatingProductState) {
          _hasShowProductUpdated = false;
        }
        if (state is ProductUpdatedState) {
          _pageMode = PageMode.VIEW;
          if (!_hasShowProductUpdated) {
            _hasShowProductUpdated = true;
            Helper.showSnackBar(
              context,
              AppLocalizations
                  .of(context)
                  .productUpdated,
            );
          }
        }
        return;
      },
      builder: (context, state) {
        if (_product.language.isEmpty) {
          final language = LanguagePickerUtils.getLanguageByIsoCode(
              MyApp.locale.languageCode);
          _product.language = language.name;
        }
        MyLogger()
            .logger
            .d('[CreateProduct]builder. Received state -> ${state.toString()}');
        Widget ret = ErrorPage(
            exception: Exception(
                '${AppLocalizations
                    .of(context)
                    .thisPageShouldNotBeVisible}. State: ${state.toString()}'));
        if (state is GotProductErrorState) {
          _product = Product();
          ret = ErrorPage(
              exception: state.e,
              countDownMessage: AppLocalizations
                  .of(context)
                  .reloadingIn,
              secondsToGo: Constants.DEFAULT_SECONDS_TO_RELOAD_PAGE);
          _reloadProduct(context, Constants.DEFAULT_SECONDS_TO_RELOAD_PAGE);
        } else if (state is GettingProductDataState ||
            state is GettingProductsDataState ||
            state is ProductsEmptyState ||
            state is GotAllProductsPaginatedTranslatedAndOrderedState ||
            state is GotMyProductsPaginatedTranslatedAndOrderedState) {
          ret = LoadingPage(AppLocalizations
              .of(context)
              .loadingProduct);
        } else if (state is ProductsEmptyState) {
          ret = EmptyItemPage(
            routingData: widget.routingData,
            elementType: ElementType.PRODUCT,
          );
        } else if (state is ProductsInitialState ||
            state is GotProductsByCivilOrCodeNameState ||
            state is GotProductsByCivilNameState ||
            state is GotProductByCodeNameState ||
            state is GotProductState ||
            state is ValidatedProductCodeNameState ||
            state is ProductSavedState ||
            state is ProductUpdatedState ||
            _pageMode == PageMode.CREATE) {
          if (state is GotProductsByCivilNameState &&
              _pageMode != PageMode.CREATE) {
            _product = state.products.first;
          } else if (state is GotProductByCodeNameState &&
              _pageMode != PageMode.CREATE) {
            _product = state.product;
          } else if (state is GotProductsByCivilOrCodeNameState &&
              _pageMode != PageMode.CREATE) {
            _product = state.products.first;
          } else if (state is GotProductState && _pageMode != PageMode.CREATE) {
            _product = state.product;
          }

          //if (_pageMode == PageMode.CREATE) {
          ret = ProductForm(_product, state, _pageMode, _routingData!,
              key: UniqueKey(), clearForm: _clearForm);
          if (_clearForm) {
            _clearForm = false;
          }
          //} else {
          //ret = RefreshIndicator(
          //onRefresh: _refreshData,
          //child: ProductForm(_product, state, _pageMode, _routingData!),
          //);
          //}
        }
        if (ret is ErrorPage) {
          MyLogger().logger.e(
              '[CreateProduct]Error page for state: ${state
                  .toString()}, pageMode:$_pageMode. Exception: ${ret.exception
                  .toString()}');
        }
        return ret;
      },
    );
  }

  /*
  Future<void> _refreshData() async {
    await Future<void>.delayed(
        const Duration(milliseconds: Constants.DEFAULT_DELAY_TO_REFRESH_DATA));
    _reloadProduct(context, 0);
    setState(() {});
  }
   */

  void _reloadProduct(BuildContext context, int delay) {
    Future.delayed(Duration(seconds: delay), () {
      _processRoutingData(context);
    });
  }

  void _processRoutingData(BuildContext context) {
    _routingData = widget.routingData;
    _product = Product();
    if (_routingData != null) {
      if (Routes.containsRouteViewProduct(_routingData!.route!.path)) {
        final productUID = _routingData![ViewProductPage.ROUTING_PARAM_PRODUCT_UID];
        if (productUID != null ){
          _pageMode = PageMode.VIEW;
        } else {
          _pageMode = PageMode.UNKNOWN;
          throw Exception('Invalid page mode : Unknown');
        }
      } else if (_routingData!.route!.pathSegments.length == 2) {
        _pageMode = PageMode.VIEW;
        final productCodename =
        Helper.parameterToString(_routingData!.route!.lastPath());
        final productUniverse =
        Helper.parameterToString(_routingData!.route!.penultimatePath());
        if (productCodename != null &&
            productUniverse != null &&
            productCodename.isNotEmpty &&
            productUniverse.isNotEmpty) {
          BlocProvider.of<ProductsBloc>(context).add(GetProductByCodeNameEvent(
              LoggedUser().hasUser() ? LoggedUser().user!.uid! : null,
              productCodename,
              productUniverse));
        }
      } else {
        _pageMode = PageMode.UNKNOWN;
        throw Exception('Invalid page mode : Unknown');
      }
    } else {
      _pageMode = PageMode.UNKNOWN;
      throw Exception('Invalid page mode : Unknown');
    }
  }

  bool _isPageReadOnly() {
    return _pageMode == PageMode.VIEW;
  }
}
