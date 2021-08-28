import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/products_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/states/products_states.dart';
import 'package:little_drops_of_rain_flutter/data/dao/products_dao.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart';
import 'package:little_drops_of_rain_flutter/enums/can_delete_result.dart';
import 'package:little_drops_of_rain_flutter/enums/element_type.dart';
import 'package:little_drops_of_rain_flutter/enums/name_validation_result.dart';
import 'package:little_drops_of_rain_flutter/enums/order_by.dart';
import 'package:little_drops_of_rain_flutter/extensions/string_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:pedantic/pedantic.dart';

class ProductsBloc extends Bloc<ProductsEvents, ProductsStates> {
  ProductsBloc() : super(ProductsInitialState()) {
    _productsEventController.stream.listen(mapEventToState);
  }

  ProductsDao productsDao = ProductsDao();

  // init StreamController
  final _productsStateController = StreamController<ProductsStates>();

  StreamSink<ProductsStates> get stateSink => _productsStateController.sink;

  // expose data from stream
  Stream<ProductsStates> get streamStates => _productsStateController.stream;

  final _productsEventController = StreamController<ProductsEvents>();

  Sink<ProductsEvents> get productsEventSink => _productsEventController.sink;

  @override
  Stream<ProductsStates> mapEventToState(ProductsEvents event) async* {
    MyLogger().logger.i('[ProductsBloc]Received state:${event.runtimeType}');
    switch (event.runtimeType) {
      case ProductsInitialStateEvent:
        {
          yield ProductsInitialState();
        }
        break;
      case GetAllProductsEvent:
        {
          try {
            yield GettingProductsDataState<GetAllProductsEvent>(
                event as GetAllProductsEvent);
            final products = await productsDao.getAllPublished();
            if (products.isNotEmpty) {
              for (final product in products) {
                unawaited(product.getFaceImage());
              }
              yield GotAllProductsState(products);
            } else {
              yield ProductsEmptyState();
            }
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
          break;
        }

      case GetAllProductsPaginatedAndTranslatedEvent:
        {
          try {
            final eventCast = event as GetAllProductsPaginatedAndTranslatedEvent;
            yield GettingProductsDataState<
                GetAllProductsPaginatedAndTranslatedEvent>(eventCast);
            final idx = await _getIndexOfPublishedProduct(eventCast.startAt);
            final products = await productsDao.getAllPublishedPaginated(
                eventCast.startAt, eventCast.pageSize);
            final page = (idx / eventCast.pageSize).ceil();
            final endOfList = products.length < eventCast.pageSize;
            if (products.isNotEmpty) {
              for (final product in products) {
                unawaited(product.getFaceImage());
              }
              yield GotAllProductsPaginatedAndTranslatedState(
                  products, endOfList, page,
                  from: eventCast.from, to: eventCast.to);
            } else {
              yield ProductsEmptyState();
            }
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case GetAllProductsPaginatedTranslatedAndOrderedEvent:
        {
          try {
            final eventCast =
                event as GetAllProductsPaginatedTranslatedAndOrderedEvent;
            yield GettingProductsDataState<
                GetAllProductsPaginatedTranslatedAndOrderedEvent>(eventCast);
            final orderBy = (eventCast.orderBy != OrderBy.RATING)
                ? Helper.orderByEnumToString(
                    eventCast.orderBy, ElementType.PRODUCT)
                : null;
            final List<Product> products;
            var endOfList = false;
            var page = 0;
            final idx = await _getIndexOfPublishedProduct(eventCast.startAt);
            if (orderBy != null) {
              products = await productsDao.getAllPublishedPaginated(
                  eventCast.startAt, eventCast.pageSize,
                  orderBy: orderBy, descending: eventCast.descending);
              endOfList = products.length < eventCast.pageSize;
              page = (idx / eventCast.pageSize).ceil();
            } else {
              products = await productsDao.getAllPublishedPaginated(
                  eventCast.startAt, eventCast.pageSize);
              endOfList = products.length < eventCast.pageSize;
              page = (idx / eventCast.pageSize).ceil();
            }
            if (products.isNotEmpty) {
              for (final product in products) {
                unawaited(product.getFaceImage());
              }
              yield GotAllProductsPaginatedTranslatedAndOrderedState(products,
                  eventCast.orderBy, eventCast.descending, endOfList, page,
                  from: eventCast.from, to: eventCast.to);
            } else {
              yield ProductsEmptyState();
            }
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case GetMyProductsPaginatedAndTranslatedEvent:
        {
          try {
            final eventCast = event as GetMyProductsPaginatedAndTranslatedEvent;
            yield GettingProductsDataState<
                GetMyProductsPaginatedAndTranslatedEvent>(eventCast);
            final idx = await _getIndexOfProductByUserUID(
                eventCast.startAt, eventCast.userUID);
            final products = await productsDao.getAllPaginatedByUserUID(
                eventCast.userUID, eventCast.startAt, eventCast.pageSize);
            final page = (idx / eventCast.pageSize).ceil();
            final endOfList = products.length < eventCast.pageSize;
            if (products.isNotEmpty) {
              for (final product in products) {
                unawaited(product.getFaceImage());
              }
              yield GotMyProductsPaginatedAndTranslatedState(
                  eventCast.userUID, products, endOfList, page,
                  from: eventCast.from, to: eventCast.to);
            } else {
              yield ProductsEmptyState();
            }
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case GetMyProductsPaginatedTranslatedAndOrderedEvent:
        {
          try {
            final eventCast =
                event as GetMyProductsPaginatedTranslatedAndOrderedEvent;
            yield GettingProductsDataState<
                GetMyProductsPaginatedTranslatedAndOrderedEvent>(eventCast);
            final orderBy = (eventCast.orderBy != OrderBy.RATING)
                ? Helper.orderByEnumToString(
                    eventCast.orderBy, ElementType.PRODUCT)
                : null;
            final List<Product> products;
            var endOfList = false;
            var page = 0;
            final idx = await _getIndexOfProductByUserUID(
                eventCast.startAt, eventCast.userUID);
            if (orderBy != null) {
              products = await productsDao.getAllPaginatedByUserUID(
                  eventCast.userUID, eventCast.startAt, eventCast.pageSize,
                  orderBy: orderBy, descending: eventCast.descending);
              endOfList = products.length < eventCast.pageSize;
              page = (idx / eventCast.pageSize).ceil();
            } else {
              products = await productsDao.getAllPaginatedByUserUID(
                  eventCast.userUID, eventCast.startAt, eventCast.pageSize);
              endOfList = products.length < eventCast.pageSize;
              page = (idx / eventCast.pageSize).ceil();
            }
            if (products.isNotEmpty) {
              for (final product in products) {
                unawaited(product.getFaceImage());
              }
              yield GotMyProductsPaginatedTranslatedAndOrderedState(
                  eventCast.userUID,
                  products,
                  eventCast.orderBy,
                  eventCast.descending,
                  endOfList,
                  page,
                  from: eventCast.from,
                  to: eventCast.to);
            } else {
              yield ProductsEmptyState();
            }
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case GetAllProductsByUniverseEvent:
        {
          try {
            final eventCast = event as GetAllProductsByUniverseEvent;
            yield GettingProductsDataState<GetAllProductsByUniverseEvent>(
                eventCast);
            final products = await productsDao
                .getAllPublishedByUniverse(eventCast.universeUID);
            if (products.isNotEmpty) {
              for (final product in products) {
                unawaited(product.getFaceImage());
              }
              yield GotAllProductsByUniverseState(products);
            } else {
              yield ProductsEmptyState();
            }
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case GetMyProductsEvent:
        {
          try {
            final eventCast = event as GetMyProductsEvent;
            yield GettingProductsDataState<GetMyProductsEvent>(eventCast);
            final products = await productsDao.getByUser(eventCast.userUID);
            if (products.isNotEmpty) {
              for (final product in products) {
                unawaited(product.getFaceImage());
              }
              yield GotMyProductsState(products);
            } else {
              yield ProductsEmptyState();
            }
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case GetMyProductEvent:
        {
          try {
            final eventCast = event as GetMyProductEvent;
            yield GettingProductDataState<GetMyProductEvent>(eventCast);
            final product = await productsDao.getByUserAndProductUid(
                eventCast.userUID, eventCast.productUID);
            if (product != null) {
              yield GotMyProductState(product);
            } else {
              yield ProductsEmptyState();
            }
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case GetProductEvent:
        {
          try {
            final eventCast = event as GetProductEvent;
            yield GettingProductDataState<GetProductEvent>(eventCast);
            final product = await productsDao.getByUid(eventCast.productUID);
            if (product != null) {
              unawaited(product.getImage());
              yield GotProductState(product);
            } else {
              yield ProductsEmptyState();
            }
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case SaveProductEvent:
        {
          try {
            final eventCast = event as SaveProductEvent;
            final product = await productsDao.add(eventCast.product);
            yield SavingProductState(eventCast.product);
            yield ProductSavedState(product);
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case UpdateProductEvent:
        {
          try {
            final eventCast = event as UpdateProductEvent;
            yield UpdatingProductState(eventCast.product);
            await productsDao.update(eventCast.product);
            yield ProductUpdatedState(eventCast.product);
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case CanDeleteProductEvent:
        {
          try {
            final eventCast = event as CanDeleteProductEvent;
            if (eventCast.product.userUID != eventCast.userUID) {
              yield CanDeleteProductState(eventCast.product, false,
                  CanDeleteResult.CANT_NOT_THE_OWNER, const <String>[]);
            } else if (await productsDao.getByUid(eventCast.product.uid!) == null) {
              yield CanDeleteProductState(eventCast.product, false,
                  CanDeleteResult.CANT_DOES_NOT_EXISTS, const <String>[]);
            } else {
              final references =
                  await productsDao.findReferences(eventCast.product.uid!);
              if (references.isNotEmpty) {
                yield CanDeleteProductState(eventCast.product, false,
                    CanDeleteResult.CANT_HAS_REFERENCES, references);
              } else {
                yield CanDeleteProductState(eventCast.product, true,
                    CanDeleteResult.CAN, const <String>[]);
              }
            }
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case DeleteProductEvent:
        {
          try {
            final eventCast = event as DeleteProductEvent;
            unawaited(productsDao.delete(eventCast.product));
            yield ProductDeletedState(eventCast.product);
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case SearchProductsEvent:
        {
          try {
            final eventCast = event as SearchProductsEvent;
            yield GettingProductsDataState<SearchProductsEvent>(eventCast);
            final products = await productsDao.getAllPublished();
            final queryResults = <Product>[];
            if (eventCast.query.trim().isNotEmpty) {
              for (final product in products) {
                if ((product.published == true) &&
                    (product.civilName
                            .toLowerCase()
                            .contains(eventCast.query.trim().toLowerCase()) ||
                        product.codename
                            .toLowerCase()
                            .contains(eventCast.query.trim().toLowerCase()))) {
                  queryResults.add(product);
                }
              }
            }
            yield SearchProductsResultsState(products);
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      case ValidateProductCodeNameEvent:
        {
          try {
            final eventCast = event as ValidateProductCodeNameEvent;
            final codename = eventCast.codename
                .replaceAll(Constants.DEFAULT_HEROESBOOK_URL, '');
            yield GettingProductDataState<ValidateProductCodeNameEvent>(eventCast);
            final products =
                await productsDao.getAllByUniverse(eventCast.universeUID);
            if (codename.trim().isNotEmpty) {
              var found = false;
              for (final product in products) {
                if (product.codename.toLowerCase() ==
                    codename.trim().toLowerCase()) {
                  found = true;
                }
              }
              if (!found) {
                if (!eventCast.codename.isUrl()) {
                  yield ValidatedProductCodeNameState(
                      false,
                      eventCast.codename.getInvalidURLCharacters(),
                      NameValidationResult.INVALID_CHARACTERS);
                } else {
                  yield ValidatedProductCodeNameState(
                      true, const <String>[], NameValidationResult.VALID);
                }
              } else {
                yield ValidatedProductCodeNameState(false, const <String>[],
                    NameValidationResult.INVALID_ALREADY_EXISTS);
              }
            } else {
              yield ValidatedProductCodeNameState(
                  false, const <String>[], NameValidationResult.INVALID_EMPTY);
            }
          } on Exception catch (ex) {
            if (!kIsWeb) {
              unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          } on Error catch (ex) {
            if (!kIsWeb) {
              unawaited(
                  FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
            }
            MyLogger().logger.e(ex);
            yield GotProductErrorState(ex);
          }
        }
        break;

      default:
        {
          final e = Exception('Event not supported ${event.runtimeType}');
          yield ProductErrorState(e);
        }
    }
  }

  Future<int> _getIndexOfProductByUserUID(Product? product, String userUID) async {
    var idx = 0;
    if (product != null) {
      final allProducts = await productsDao.getAllByUserUID(userUID);
      for (final productItem in allProducts) {
        if (productItem.uid == product.uid) {
          break;
        }
        idx++;
      }
    }
    return idx;
  }

  Future<int> _getIndexOfPublishedProduct(Product? product) async {
    var idx = 0;
    if (product != null) {
      final allProducts = await productsDao.getAllPublished();
      for (final productItem in allProducts) {
        if (productItem.uid == product.uid) {
          break;
        }
        idx++;
      }
    }
    return idx;
  }

  @override
  Future<void> close() {
    _productsStateController.close();
    _productsEventController.close();
    return super.close();
  }
}
