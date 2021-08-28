import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_drops_of_rain_flutter/anim/open_container_hero_wrapper.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/products_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/products_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/states/products_states.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart' as my_app;
import 'package:little_drops_of_rain_flutter/enums/element_type.dart';
import 'package:little_drops_of_rain_flutter/enums/order_by.dart';
import 'package:little_drops_of_rain_flutter/enums/page_mode.dart';
import 'package:little_drops_of_rain_flutter/extensions/list_extensions.dart';
import 'package:little_drops_of_rain_flutter/extensions/build_context_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/logged_user.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/interfaces/card_actions_callbacks.dart';
import 'package:little_drops_of_rain_flutter/interfaces/on_order_by_change.dart';
import 'package:little_drops_of_rain_flutter/models/view_products_model.dart';
import 'package:little_drops_of_rain_flutter/routing/routing_data.dart';
import 'package:little_drops_of_rain_flutter/ui/my_scaffold.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/empty_items_page.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/error_page.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/loading_page.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_color_scheme.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/loading_card.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/order_by_widget.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:pedantic/pedantic.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class ViewProductsPage extends StatefulWidget {
  const ViewProductsPage(
      {Key? key, this.title = Constants.APP_NAME, this.routingData})
      : super(key: key);

  static Route<dynamic> route(String title, RoutingData routingData) {
    return MaterialPageRoute<dynamic>(
        builder: (context) =>
            ViewProductsPage(title: title, routingData: routingData));
  }

  static const String ROUTING_PARAM_PRODUCT_ID = 'myProducts';
  static const String routeName = '/viewProducts';
  final RoutingData? routingData;
  final String? title;

  @override
  _ViewProductsPageState createState() => _ViewProductsPageState();
}

// 🚀Global Functional Injection
// This state will be auto-disposed when no longer used, and also testable and mockable.
final model = RM.inject<ViewProductsModel>(
      () => ViewProductsModel(),
  undoStackLength: Constants.DEFAULT_UNDO_STACK_LENGTH,
  //Called after new state calculation and just before state mutation
  middleSnapState: (middleSnap) {
    //Log all state transition.
    MyLogger().logger.i(middleSnap.currentSnap);
    MyLogger().logger.i(middleSnap.nextSnap);

    MyLogger().logger.i('');
    middleSnap.print(preMessage: '[ViewProductsModel]'); //Build-in logger
    //Can return another state
  },
  onDisposed: (state) => MyLogger().logger.i('[ViewProductsModel]Disposed'),
);

class _ViewProductsPageState extends State<ViewProductsPage>
    implements
        CardActionsCallbacks<my_app.Product>,
        OnOrderByChange {
  final ScrollController _scrollController =
  ScrollController(initialScrollOffset: 5);
  Container? _bannerAd;

  final _productsAsCards = <Widget>[];
  static var _isFirstRun = true;

  @override
  void initState() {
    super.initState();
    model.state.clear();

    // Exhaustively handle all four status
    On.all(
      // If is Idle
      onIdle: () => MyLogger().logger.i('[ViewProductsModel]Idle'),
      // If is waiting
      onWaiting: () => MyLogger().logger.i('[ViewProductsModel]Waiting'),
      // If has error
      onError: (dynamic err, refresh) =>
          MyLogger().logger.e('[ViewProductsModel]Error:$err. Refresh:$refresh'),
      // If has Data
      onData: () => MyLogger().logger.i('[ViewProductsModel]Data'),
    );

    model.state.unsubscribe =
        FirebaseAuth.instance.authStateChanges().listen((user) async {
          if (!model.state.isFirstRun) {
            unawaited(_reloadProducts(context, 0));
          } else {
            model.state.isFirstRun = false;
          }
        });
    _processRoutingData(context);
    _scrollController.addListener(_scrollListener);
    if (_isFirstRun) {
      _isFirstRun = false;
    }
  }

  @override
  void dispose() {
    model.state.unsubscribe?.cancel();
    _scrollController.dispose();
    if (!kIsWeb && _bannerAd != null) {
      _bannerAd = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = MyScaffold(
      title: (widget.title != null) ? widget.title : '',
      elementType: ElementType.PRODUCT,
      body: Builder(
        builder: _buildBody,
      ),
    );
    return scaffold;
  }

  void checkEventExecutionTime() {
    model.state.checkEventExecutionTimeTimer?.cancel();
    model.state.checkEventExecutionTimeTimer = Timer(
        const Duration(
            milliseconds: Constants.DEFAULT_CHECK_EVENT_EXECUTION_TIME_DELAY),
            () {
          if (model.state.lastEvent != null) {
            Helper.showSnackBar(context,
                AppLocalizations
                    .of(context)
                    .looksLikeItIsTakingALongTimeRetrying);
            BlocProvider.of<ProductsBloc>(context)
                .add(model.state.lastEvent!);
          } else {
            Helper.showSnackBar(context,
                AppLocalizations
                    .of(context)
                    .looksLikeItIsTakingALongTimeReload);
          }
        });
  }

  bool _listenWhenFilter(ProductsStates previousState,
      ProductsStates currentState) {
    return context.isCurrent(this) &&
        (previousState != currentState) &&
        (currentState is! ProductsInitialState) &&
        (currentState is! GettingProductsDataState) &&
        // ignore: unrelated_type_equality_checks
        //(currentState.event is! ProductsChangedEvent)) &&
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
        (currentState is! GotProductByCodeNameState) &&
        (currentState is! GotProductsByCivilNameState) &&
        (currentState is! GotProductsByCivilOrCodeNameState) &&
        (currentState is! ProductsChangedState) &&
        (currentState is! SavingProductState) &&
        (currentState is! ProductSavedState) &&
        (currentState is! UpdatingProductState) &&
        (currentState is! ProductUpdatedState) &&
        //(currentState is! CanDeleteProductState) &&
        (currentState is! ProductDeletedState) &&
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
        //(currentState is! ProductsInitialState) &&
        (currentState is! GettingProductsDataState) &&
        // ignore: unrelated_type_equality_checks
        //(currentState.event != ProductsChangedEvent)) &&
        (currentState is! GettingProductDataState) &&
        //(currentState is! GotAllProductsPaginatedAndTranslatedState) &&
        //(currentState is! GotAllProductsPaginatedTranslatedAndOrderedState) &&
        //(currentState is! GotMyProductsPaginatedAndTranslatedState) &&
        //(currentState is! GotMyProductsPaginatedTranslatedAndOrderedState) &&
        (currentState is! GotAllProductsState) &&
        //(currentState is! GotAllProductsByUniversState) &&
        (currentState is! GotMyProductsState) &&
        (currentState is! GotMyProductState) &&
        (currentState is! GotProductState) &&
        (currentState is! GotProductByCodeNameState) &&
        (currentState is! GotProductsByCivilNameState) &&
        (currentState is! GotProductsByCivilOrCodeNameState) &&
        (currentState is! ProductsChangedState) &&
        (currentState is! SavingProductState) &&
        (currentState is! ProductSavedState) &&
        (currentState is! UpdatingProductState) &&
        (currentState is! ProductUpdatedState) &&
        (currentState is! CanDeleteProductState) &&
        //(currentState is! ProductDeletedState) &&
        //(currentState is! ProductsEmptyState) &&
        (currentState is! SearchProductsResultsState) &&
        (currentState is! ValidatedProductCodeNameState) &&
        (currentState is! ProductErrorState);
    //(currentState is! GotProductErrorState) &&
    //(currentState is! ProductTranslationErrorState);
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<ProductsBloc, ProductsStates>(
      listenWhen: (previousState, currentState) {
        final listen = _listenWhenFilter(previousState, currentState);
        MyLogger().logger.d(
            '[ViewProducts]listenWhen. Received previous state -> $previousState. Current state -> $currentState. Listen:$listen');
        return listen;
      },
      buildWhen: (previousState, currentState) {
        final build = _buildWhenFilter(previousState, currentState);
        MyLogger().logger.d(
            '[ViewProducts]buildWhen. Received previous state -> $previousState. Current state -> $currentState. Build:$build');
        return build;
      },
      listener: (context, state) {
        if (state is CanDeleteProductState) {
          if (state.can) {
            for (final product in model.state.products) {
              if (product.uid == state.product.uid) {
                BlocProvider.of<ProductsBloc>(context)
                    .add(DeleteProductEvent(product));
                setState(() {
                  model.state.products.remove(product);
                });
                break;
              }
            }
          } else {
            Helper.processCanDeleteResult(
                state.result, state.references, context);
          }
        }
      },
      builder: (context, state) {
        if (model.state.shouldReload) {
          _reloadProducts(context, 0);
          model.state.shouldReload = false;
        }
        MyLogger()
            .logger
            .d('[ViewProducts]builder. Received state -> ${state.toString()}');
        model.state.checkEventExecutionTimeTimer?.cancel();
        model.state.checkEventExecutionTimeTimer = null;
        model.state.lastEvent = null;
        Widget ret = ErrorPage(
            exception: Exception(
                '${AppLocalizations
                    .of(context)
                    .thisPageShouldNotBeVisible}. State: ${state.toString()}'));
        if (state is ProductsEmptyState) {
          ret = EmptyItemsPage(
              countDownMessage: AppLocalizations
                  .of(context)
                  .reloadingIn,
              secondsToGo: Constants.DEFAULT_SECONDS_TO_RELOAD_PAGE);
          model.state.products = <my_app.Product>[];
          _reloadProducts(context, Constants.DEFAULT_SECONDS_TO_RELOAD_PAGE);
        } else if (state is GettingProductsDataState &&
            model.state.products.isEmpty) {
          ret = LoadingPage(AppLocalizations
              .of(context)
              .loadingProducts);
        } else if (state is GotProductErrorState) {
          model.state.products = <my_app.Product>[];
          ret = ErrorPage(
              exception: state.e,
              countDownMessage: AppLocalizations
                  .of(context)
                  .reloadingIn,
              secondsToGo: Constants.DEFAULT_SECONDS_TO_RELOAD_PAGE);
          _reloadProducts(context, Constants.DEFAULT_SECONDS_TO_RELOAD_PAGE);
          model.state.products = <my_app.Product>[];
        } else if (model.state.products.isNotEmpty ||
            state is ProductDeletedState ||
            state is ProductsInitialState ||
            state is GotAllProductsByUniverseState ||
            state is GotMyProductsPaginatedAndTranslatedState ||
            state is GotMyProductsPaginatedTranslatedAndOrderedState ||
            state is GotAllProductsPaginatedAndTranslatedState ||
            state is GotAllProductsPaginatedTranslatedAndOrderedState ||
            state is SearchProductsResultsState) {
          if (state is GotAllProductsByUniverseState) {
            model.state.endOfItems = true;
            if (model.state.clearByState == GotAllProductsByUniverseState) {
              model.state.products.clear();
              _productsAsCards.clear();
              model.state.clearByState = null;
            }
            model.state.products.addAllUnique(state.products);
            model.state.isLoading = false;
            model.state.lastLanguageTranslated = 'auto';
          } else if (state is GotMyProductsPaginatedAndTranslatedState) {
            model.state.endOfItems = state.endOfList;
            if (model.state.clearByState ==
                GotMyProductsPaginatedAndTranslatedState ||
                state.page == 1) {
              model.state.products.clear();
              _productsAsCards.clear();
              model.state.clearByState = null;
            }
            if (model.state.waitForFirstPage) {
              model.state.waitForFirstPage = false;
              if (state.page == 1) {
                model.state.products.addAllUnique(state.products);
              }
            } else {
              model.state.products.addAllUnique(state.products);
            }
            model.state.isLoading = false;
            model.state.lastLanguageTranslated =
            (state.to != null) ? state.to! : 'auto';
          } else if (state is GotMyProductsPaginatedTranslatedAndOrderedState) {
            model.state.endOfItems = state.endOfList;
            if (model.state.clearByState ==
                GotMyProductsPaginatedTranslatedAndOrderedState ||
                state.page == 1) {
              model.state.products.clear();
              _productsAsCards.clear();
              model.state.clearByState = null;
            }
            if (model.state.waitForFirstPage) {
              model.state.waitForFirstPage = false;
              if (state.page == 1) {
                model.state.products.addAllUnique(state.products);
              }
            } else {
              model.state.products.addAllUnique(state.products);
            }
            model.state.isLoading = false;
          } else if (state is GotAllProductsPaginatedAndTranslatedState) {
            model.state.endOfItems = state.endOfList;
            if (model.state.clearByState ==
                GotAllProductsPaginatedAndTranslatedState ||
                state.page == 1) {
              model.state.products.clear();
              _productsAsCards.clear();
              model.state.clearByState = null;
            }
            if (model.state.waitForFirstPage) {
              model.state.waitForFirstPage = false;
              if (state.page == 1) {
                model.state.products.addAllUnique(state.products);
              }
            } else {
              model.state.products.addAllUnique(state.products);
            }
            model.state.isLoading = false;
            model.state.lastLanguageTranslated =
            (state.to != null) ? state.to! : 'auto';
          } else if (state is GotAllProductsPaginatedTranslatedAndOrderedState) {
            model.state.endOfItems = state.endOfList;
            if (model.state.clearByState ==
                GotAllProductsPaginatedTranslatedAndOrderedState ||
                state.page == 1) {
              model.state.products.clear();
              _productsAsCards.clear();
              model.state.clearByState = null;
            }
            if (model.state.waitForFirstPage) {
              model.state.waitForFirstPage = false;
              if (state.page == 1) {
                model.state.products.addAllUnique(state.products);
              }
            } else {
              model.state.products.addAllUnique(state.products);
            }
            model.state.isLoading = false;
            model.state.lastLanguageTranslated =
            (state.to != null) ? state.to! : 'auto';
          }
          final newList = _getListOfProductsAsCards(model.state.products);
          _updateProductsCards(newList);
          if (_productsAsCards.isNotEmpty) {
            ret = SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: Scrollbar(
                  controller: _scrollController,
                  isAlwaysShown: kIsWeb,
                  child: CustomScrollView(
                    shrinkWrap: true,
                    controller: _scrollController,
                    slivers: <Widget>[
                      if (_productsAsCards.length > 1)
                        SliverAppBar(
                          backgroundColor: MyColorScheme().background,
                          titleSpacing: Constants.DEFAULT_TITLE_SPACING,
                          title: OrderByWidget(
                              orderBy: model.state.orderBy,
                              orderDirection: model.state.descending,
                              elementType: ElementType.PRODUCT,
                              onOrderByChange: this),
                          pinned: true,
                        ),
                      // Build the items lazily
                      SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: (MediaQuery
                              .of(context)
                              .size
                              .width /
                              Constants.DEFAULT_CARD_WIDTH)
                              .round(),
                          mainAxisSpacing:
                          Constants.DEFAULT_CARD_MAIN_AXIS_SPACING,
                          crossAxisSpacing:
                          Constants.DEFAULT_CARD_CROSS_AXIS_SPACING,
                          childAspectRatio:
                          Constants.DEFAULT_HERO_CARD_ASPECT_RATIO,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return _productsAsCards[index];
                          },
                          // addAutomaticKeepAlives: false,
                          childCount: _productsAsCards.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            ret = const EmptyItemsPage();
          }
        }
        if (ret is ErrorPage) {
          MyLogger().logger.e(
              '[ViewProducts]Error page for state: ${state
                  .toString()}. Exception: ${ret.exception.toString()} ${(ret
                  .exception is Error) ? (ret.exception as Error).stackTrace
                  .toString() : ""}');
        }
        if (_bannerAd != null) {
          ret = Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[ret, _bannerAd!]);
        }
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (_scrollController.hasClients &&
              ((_scrollController.position.maxScrollExtent == 0) ||
                  (model.state.previousMaxScrollExtent !=
                      _scrollController.position.maxScrollExtent)) &&
              _scrollController.position.maxScrollExtent <=
                  _scrollController.position.viewportDimension &&
              !model.state.isLoading &&
              !model.state.endOfItems) {
            model.state.previousMaxScrollExtent =
                _scrollController.position.maxScrollExtent;
            model.state.loadMore = true;
            _scrollListener();
          }
        });
        return ret;
      },
    );
  }

  void _updateProductsCards(List<OpenContainerProductWrapper> newList) {
    var shouldContinue = true;
    while (_productsAsCards.isNotEmpty && shouldContinue) {
      if (_productsAsCards[_productsAsCards.length - 1] is SizedBox) {
        _productsAsCards.removeAt(_productsAsCards.length - 1);
      } else if (_productsAsCards[_productsAsCards.length - 1] is LoadingCard) {
        _productsAsCards.removeAt(_productsAsCards.length - 1);
        shouldContinue = false;
      } else {
        shouldContinue = false;
      }
    }
    for (final product in newList) {
      var contains = false;
      for (final productAsCard in _productsAsCards) {
        if (productAsCard is OpenContainerProductWrapper) {
          if (productAsCard.product == product.product) {
            contains = true;
            break;
          }
        }
      }
      if (!contains) {
        _productsAsCards.add(product);
      }
    }
    final productsToRemove = <Widget>[];
    for (final productAsCard in _productsAsCards) {
      var contains = false;
      for (final product in newList) {
        if (productAsCard is OpenContainerProductWrapper) {
          if (productAsCard.product == product.product) {
            contains = true;
            break;
          }
        }
      }
      if (!contains && productAsCard is OpenContainerProductWrapper) {
        productsToRemove.add(productAsCard);
      }
    }
    productsToRemove.forEach(_productsAsCards.remove);
    if (!model.state.endOfItems) {
      _productsAsCards.add(const LoadingCard());
    }
    _productsAsCards.add(const SizedBox(
      height: Constants.DEFAULT_AD_BOTTOM_SPACE,
      width: 1,
    ));
  }

  Future<void> _refreshData() async {
    await Future<void>.delayed(
        const Duration(milliseconds: Constants.DEFAULT_DELAY_TO_REFRESH_DATA));
    model.state.waitForFirstPage = true;
    if (mounted) {
      await _reloadProducts(context, 0);
    }
    setState(() {});
  }

  List<OpenContainerProductWrapper> _getListOfProductsAsCards(
      List<my_app.Product> products) {
    final myProducts = <OpenContainerProductWrapper>[];
    for (final product in products) {
      myProducts.add(OpenContainerProductWrapper(
          product: product, cardActionsCallbacks: this, pageMode: PageMode.VIEW));
    }
    return myProducts;
  }

  void _scrollToLastPosition() {
    _scrollController.jumpTo(model.state.scrollPosition);
  }

  void _scrollListener() {
    if (!model.state.isLoading &&
        (model.state.loadMore ||
            (_scrollController.offset >=
                _scrollController.position.maxScrollExtent))) {
      model.state.loadMore = false;
      if (!model.state.endOfItems) {
        MyLogger().logger.d('comes to bottom $model.state.isLoading');
        if (!model.state.isLoading) {
          model.state.isLoading = true;
          MyLogger().logger.d('Loading more');
          ProductsEvents? event;
          if (model.state.myProducts && LoggedUser().hasUser()) {
            event = GetMyProductsPaginatedTranslatedAndOrderedEvent(
                LoggedUser().user!.uid!,
                orderBy: model.state.orderBy,
                startAt: model.state.products.last,
                from: model.state.lastLanguageTranslated,
                to: model.state.lastLanguageTo,
                descending: model.state.descending);
          } else {
            event = GetAllProductsPaginatedTranslatedAndOrderedEvent(
                orderBy: model.state.orderBy,
                startAt: model.state.products.last,
                from: model.state.lastLanguageTranslated,
                to: model.state.lastLanguageTo,
                descending: model.state.descending);
          }
          model.state.scrollPosition = _scrollController.offset;
          if (context.isCurrent(this)) {
            model.state.lastEvent = event;
            BlocProvider.of<ProductsBloc>(context).add(event);
            checkEventExecutionTime();
          }
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Future.delayed(
                const Duration(
                    milliseconds: Constants.DEFAULT_SCROLL_TO_BOTTOM_DELAY),
                _scrollToLastPosition);
          });
        }
      }
    }
  }

  Future<void> _reloadProducts(BuildContext context, int delay) {
    return Future.delayed(Duration(seconds: delay), () {
      _processRoutingData(context);
    });
  }

  void _processRoutingData(BuildContext context) {
    model.state.routingData = widget.routingData;
    model.state.waitForFirstPage = true;
    if (model.state.routingData != null) {
      if (model.state.isMine != model.state.myProducts) {
        model.state.isMine = model.state.myProducts;
        model.state.products.clear();
        _productsAsCards.clear();
      }
      if (model.state.myProducts && LoggedUser().hasUser()) {
        final productsEvent = GetMyProductsPaginatedTranslatedAndOrderedEvent(
            LoggedUser().user!.uid!,
            orderBy: model.state.orderBy,
            descending: model.state.descending);
        model.state.lastEvent = productsEvent;
        BlocProvider.of<ProductsBloc>(context).add(productsEvent);
        checkEventExecutionTime();
        model.state.clearByState =
            GotMyProductsPaginatedTranslatedAndOrderedState;
      } else {
        BlocProvider.of<ProductsBloc>(context)
            .add(GetAllProductsPaginatedTranslatedAndOrderedEvent(
          orderBy: model.state.orderBy,
          descending: model.state.descending,
        ));
        model.state.clearByState =
            GotAllProductsPaginatedTranslatedAndOrderedState;
      }
    } else {
      if (model.state.isMine != false) {
        model.state.isMine = false;
        model.state.products.clear();
        _productsAsCards.clear();
      }
      final productsEvent = GetAllProductsPaginatedTranslatedAndOrderedEvent(
          orderBy: model.state.orderBy, descending: model.state.descending);
      model.state.lastEvent = productsEvent;
      BlocProvider.of<ProductsBloc>(context).add(productsEvent);
      checkEventExecutionTime();
      model.state.clearByState = GotAllProductsPaginatedTranslatedAndOrderedState;
    }
  }

  @override
  void onOrderByChange(OrderBy? orderBy) {
    if (orderBy != model.state.orderBy) {
      model.state.orderBy = orderBy!;
      ProductsEvents? event;
      if (model.state.myProducts && LoggedUser().hasUser()) {
        event = GetMyProductsPaginatedTranslatedAndOrderedEvent(
            LoggedUser().user!.uid!,
            from: model.state.lastLanguageTranslated,
            to: model.state.lastLanguageTo,
            orderBy: model.state.orderBy,
            descending: model.state.descending);
        model.state.clearByState =
            GotMyProductsPaginatedTranslatedAndOrderedState;
      } else {
        event = GetAllProductsPaginatedTranslatedAndOrderedEvent(
            from: model.state.lastLanguageTranslated,
            to: model.state.lastLanguageTo,
            orderBy: model.state.orderBy,
            descending: model.state.descending);
        model.state.clearByState =
            GotAllProductsPaginatedTranslatedAndOrderedState;
      }
      model.state.scrollPosition = 0;
      if (context.isCurrent(this)) {
        model.state.lastEvent = event;
        BlocProvider.of<ProductsBloc>(context).add(event);
        checkEventExecutionTime();
      }
    }
  }

  @override
  void onOrderDirectionChange(bool descending) {
    if (descending != model.state.descending) {
      model.state.descending = descending;
      ProductsEvents? event;
      if (model.state.myProducts && LoggedUser().hasUser()) {
        event = GetMyProductsPaginatedTranslatedAndOrderedEvent(
            LoggedUser().user!.uid!,
            from: model.state.lastLanguageTranslated,
            to: model.state.lastLanguageTo,
            orderBy: model.state.orderBy,
            descending: model.state.descending);
        model.state.clearByState =
            GotMyProductsPaginatedTranslatedAndOrderedState;
      } else {
        event = GetAllProductsPaginatedTranslatedAndOrderedEvent(
            from: model.state.lastLanguageTranslated,
            to: model.state.lastLanguageTo,
            orderBy: model.state.orderBy,
            descending: model.state.descending);
        model.state.clearByState =
            GotAllProductsPaginatedTranslatedAndOrderedState;
      }
      model.state.scrollPosition = 0;
      if (context.isCurrent(this)) {
        model.state.lastEvent = event;
        BlocProvider.of<ProductsBloc>(context).add(event);
        checkEventExecutionTime();
      }
    }
  }

  @override
  void onDelete(my_app.Product element) {
    // Do nothing
  }

  @override
  void onEdit(my_app.Product element) {
    //BlocProvider.of<ProductsBloc>(context)
    //    .add(ProductsInitialStateEvent());
  }

  @override
  void onView(my_app.Product element) {
    //BlocProvider.of<ProductsBloc>(context)
    //    .add(ProductsInitialStateEvent());
  }

  @override
  void onViewed(my_app.Product element) {
    model.state.shouldReload = true;
  }
}








