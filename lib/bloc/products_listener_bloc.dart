import 'dart:async';
import 'dart:math';

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/products_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/states/products_states.dart';
import 'package:little_drops_of_rain_flutter/data/dao/products_dao.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart';
import 'package:little_drops_of_rain_flutter/enums/can_delete_result.dart';
import 'package:little_drops_of_rain_flutter/enums/name_validation_result.dart';
import 'package:little_drops_of_rain_flutter/enums/order_by.dart';
import 'package:little_drops_of_rain_flutter/extensions/string_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/listeners/firebase_listener.dart';
import 'package:pedantic/pedantic.dart';

class ProductsListenerBloc extends Bloc<ProductsEvents, ProductsStates>
    implements NotifyDataSetChanged {
  ProductsListenerBloc() : super(ProductsInitialState()) {
    _productsEventController.stream.listen(mapEventToState);
    productsListener = FirebaseListener(query: query)..startListening();
  }

  late FirebaseListener productsListener;
  bool notifyDataChanged = true;
  Query<Map<String, dynamic>> query =
      FirebaseFirestore.instance.collection(ProductsDao.COLLECTION_PATH);

  // init StreamController
  final _productsStateController = StreamController<ProductsStates>();

  StreamSink<ProductsStates> get stateSink => _productsStateController.sink;

  // expose data from stream
  Stream<ProductsStates> get streamStates => _productsStateController.stream;

  final _productsEventController = StreamController<ProductsEvents>();

  Sink<ProductsEvents> get productsEventSink => _productsEventController.sink;

  @override
  Stream<ProductsStates> mapEventToState(ProductsEvents event) async* {
    MyLogger()
        .logger
        .i('[ProductsListenerBloc]Received state:${event.runtimeType}');
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
            final products =
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
            final publishedProducts = <Product>[];
            for (final product in products) {
              if (product.published == true) {
                unawaited(product.getFaceImage());
                publishedProducts.add(product);
              }
            }
            if (publishedProducts.isNotEmpty) {
              yield GotAllProductsState(publishedProducts);
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

      case GetAllProductsPaginatedAndTranslatedEvent:
        {
          try {
            final eventCast = event as GetAllProductsPaginatedAndTranslatedEvent;
            yield GettingProductsDataState<
                GetAllProductsPaginatedAndTranslatedEvent>(eventCast);
            final products =
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
            final publishedProducts = <Product>[];
            var retProducts = <Product>[];
            if (products.isNotEmpty) {
              for (final product in products) {
                if (product.published) {
                  publishedProducts.add(product);
                }
              }
              var idx = 0;
              var endOfList = true;
              var page = 0;
              if (eventCast.startAt != null) {
                for (final product in publishedProducts) {
                  idx++;
                  if (product == eventCast.startAt) {
                    endOfList = false;
                    page = (idx / eventCast.pageSize).ceil();
                    if (idx + eventCast.pageSize + 1 < publishedProducts.length) {
                      endOfList = false;
                      retProducts = publishedProducts.sublist(
                          idx, idx + eventCast.pageSize + 1);
                    } else {
                      endOfList = true;
                      retProducts =
                          publishedProducts.sublist(idx, publishedProducts.length);
                    }
                    break;
                  }
                }
              } else {
                endOfList = false;
                page = 1;
                if (eventCast.pageSize + 1 < publishedProducts.length) {
                  endOfList = false;
                  retProducts =
                      publishedProducts.sublist(0, eventCast.pageSize + 1);
                } else {
                  endOfList = true;
                  retProducts =
                      publishedProducts.sublist(0, publishedProducts.length);
                }
              }
              for (final product in retProducts) {
                unawaited(product.getFaceImage());
              }
              yield GotAllProductsPaginatedAndTranslatedState(
                  retProducts, endOfList, page,
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
            final products =
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
            final publishedProducts = <Product>[];
            var retProducts = <Product>[];
            if (products.isNotEmpty) {
              for (final product in products) {
                if (product.published) {
                  publishedProducts.add(product);
                }
              }
              if (eventCast.orderBy == OrderBy.RANDOM) {
                publishedProducts.sort(eventCast.descending
                    ? _compareProductsByRandomDesc
                    : _compareProductsByRandomAsc);
              } else {
                if (eventCast.orderBy == OrderBy.ALPHABETICALLY) {
                  publishedProducts.sort(eventCast.descending
                      ? _compareProductsByCodenameDesc
                      : _compareProductsByCodenameAsc);
                } else if (eventCast.orderBy == OrderBy.CREATION_DATE) {
                  publishedProducts.sort(eventCast.descending
                      ? _compareProductsByCreationDateDesc
                      : _compareProductsByCreationDateAsc);
                } else if (eventCast.orderBy == OrderBy.UPDATE_DATE) {
                  publishedProducts.sort(eventCast.descending
                      ? _compareProductsByUpdateDateDesc
                      : _compareProductsByUpdateDateAsc);
                }
              }
              var idx = 0;
              var endOfList = true;
              var page = 0;
              if (eventCast.startAt != null) {
                for (final product in publishedProducts) {
                  idx++;
                  if (product == eventCast.startAt!) {
                    page = (idx / eventCast.pageSize).ceil();
                    if (idx + eventCast.pageSize + 1 < publishedProducts.length) {
                      endOfList = false;
                      retProducts = publishedProducts.sublist(
                          idx, idx + eventCast.pageSize + 1);
                    } else {
                      endOfList = true;
                      retProducts =
                          publishedProducts.sublist(idx, publishedProducts.length);
                    }
                    break;
                  }
                }
              } else {
                page = 1;
                if (eventCast.pageSize + 1 < publishedProducts.length) {
                  endOfList = false;
                  retProducts =
                      publishedProducts.sublist(0, eventCast.pageSize + 1);
                } else {
                  endOfList = true;
                  retProducts =
                      publishedProducts.sublist(0, publishedProducts.length);
                }
              }
              for (final product in retProducts) {
                unawaited(product.getFaceImage());
              }
              yield GotAllProductsPaginatedTranslatedAndOrderedState(retProducts,
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
            final products =
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
            final myProducts = <Product>[];
            var retProducts = <Product>[];
            if (products.isNotEmpty) {
              for (final product in products) {
                if (product.userUID == eventCast.userUID) {
                  myProducts.add(product);
                }
              }
              var idx = 0;
              var endOfList = true;
              var page = 0;
              if (eventCast.startAt != null) {
                for (final product in myProducts) {
                  idx++;
                  if (product == eventCast.startAt) {
                    endOfList = false;
                    page = (idx / eventCast.pageSize).ceil();
                    if (idx + eventCast.pageSize + 1 <= myProducts.length - 1) {
                      endOfList = false;
                      retProducts =
                          myProducts.sublist(idx, idx + eventCast.pageSize + 1);
                    } else {
                      endOfList = true;
                      retProducts = myProducts.sublist(idx, myProducts.length);
                    }
                    break;
                  }
                }
              } else {
                page = 1;
                if (eventCast.pageSize + 1 < myProducts.length) {
                  endOfList = false;
                  retProducts = myProducts.sublist(0, eventCast.pageSize + 1);
                } else {
                  endOfList = true;
                  retProducts = myProducts.sublist(0, products.length);
                }
              }
              for (final product in retProducts) {
                unawaited(product.getFaceImage());
              }
              yield GotMyProductsPaginatedAndTranslatedState(
                  eventCast.userUID, retProducts, endOfList, page,
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
            final products =
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
            final myProducts = <Product>[];
            var retProducts = <Product>[];
            if (products.isNotEmpty) {
              for (final product in products) {
                if (product.userUID == eventCast.userUID) {
                  myProducts.add(product);
                }
              }
              if (eventCast.orderBy == OrderBy.RANDOM) {
                myProducts.sort(eventCast.descending
                    ? _compareProductsByRandomDesc
                    : _compareProductsByRandomAsc);
              } else if (eventCast.orderBy == OrderBy.ALPHABETICALLY) {
                myProducts.sort(eventCast.descending
                    ? _compareProductsByCodenameDesc
                    : _compareProductsByCodenameAsc);
              } else if (eventCast.orderBy == OrderBy.CREATION_DATE) {
                myProducts.sort(eventCast.descending
                    ? _compareProductsByCreationDateDesc
                    : _compareProductsByCreationDateAsc);
              } else if (eventCast.orderBy == OrderBy.UPDATE_DATE) {
                myProducts.sort(eventCast.descending
                    ? _compareProductsByUpdateDateDesc
                    : _compareProductsByUpdateDateAsc);
              }
              var idx = 0;
              var endOfList = true;
              var page = 0;
              if (eventCast.startAt != null) {
                for (final product in myProducts) {
                  idx++;
                  if (product == eventCast.startAt) {
                    page = (idx / eventCast.pageSize).ceil();
                    if (idx + eventCast.pageSize + 1 <= myProducts.length - 1) {
                      endOfList = false;
                      retProducts =
                          myProducts.sublist(idx, idx + eventCast.pageSize + 1);
                    } else {
                      endOfList = true;
                      retProducts = myProducts.sublist(idx, myProducts.length);
                    }
                    break;
                  }
                }
              } else {
                page = 1;
                if (eventCast.pageSize + 1 < myProducts.length) {
                  endOfList = false;
                  retProducts = myProducts.sublist(0, eventCast.pageSize + 1);
                } else {
                  endOfList = true;
                  retProducts = myProducts.sublist(0, myProducts.length);
                }
              }
              for (final product in retProducts) {
                unawaited(product.getFaceImage());
              }
              yield GotMyProductsPaginatedTranslatedAndOrderedState(
                  eventCast.userUID,
                  retProducts,
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
            final products =
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
            final publishedProductsByUniverse = <Product>[];
            for (final product in products) {
              if ((product.published == true) &&
                  (product.universeUID == eventCast.universeUID)) {
                publishedProductsByUniverse.add(product);
              }
            }
            if (publishedProductsByUniverse.isNotEmpty) {
              for (final product in publishedProductsByUniverse) {
                unawaited(product.getFaceImage());
              }
              yield GotAllProductsByUniverseState(publishedProductsByUniverse);
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
            yield GettingProductDataState<GetMyProductsEvent>(eventCast);
            final products =
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
            final myProducts = <Product>[];
            for (final product in products) {
              if (product.userUID == eventCast.userUID) {
                myProducts.add(product);
              }
            }
            if (myProducts.isNotEmpty) {
              for (final product in myProducts) {
                unawaited(product.getFaceImage());
              }
              yield GotMyProductsState(myProducts);
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
            final products =
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
            Product? myProduct;
            for (final product in products) {
              if (product.uid == eventCast.productUID &&
                  product.userUID == eventCast.userUID) {
                myProduct = product;
              }
            }
            if (myProduct != null) {
              yield GotMyProductState(myProduct);
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
            final products =
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
            Product? productFound;
            for (final product in products) {
              if (product.uid == eventCast.productUID) {
                productFound = product;
              }
            }
            if (productFound != null) {
              unawaited(productFound.getImage());
              yield GotProductState(productFound);
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

      case ProductsChangedEvent:
        {
          try {
            yield GettingProductsDataState<ProductsChangedEvent>(
                event as ProductsChangedEvent);
            final products =
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
            final publishedProducts = <Product>[];
            for (final product in products) {
              if (product.published == true) {
                publishedProducts.add(product);
              }
            }
            if (products.isNotEmpty) {
              yield ProductsChangedState(publishedProducts);
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
            final product = await ProductsDao().add(eventCast.product);
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
            await ProductsDao().update(eventCast.product);
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
            final products =
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
            if (eventCast.product.userUID != eventCast.userUID) {
              yield CanDeleteProductState(eventCast.product, false,
                  CanDeleteResult.CANT_NOT_THE_OWNER, const <String>[]);
            } else {
              var found = false;
              for (final product in products) {
                if (product.uid == eventCast.product.uid) {
                  found = true;
                  break;
                }
              }
              if (!found) {
                yield CanDeleteProductState(eventCast.product, false,
                    CanDeleteResult.CANT_DOES_NOT_EXISTS, const <String>[]);
              } else {
                final references = <String>[];
                for (final product in products) {
                  if (product.friendsUIDS.contains(product.uid)) {
                    references.add(product.codename);
                  } else if (product.enemiesUIDS.contains(product.uid)) {
                    references.add(product.codename);
                  }
                }
                if (references.isNotEmpty) {
                  yield CanDeleteProductState(eventCast.product, false,
                      CanDeleteResult.CANT_HAS_REFERENCES, references);
                } else {
                  yield CanDeleteProductState(eventCast.product, true,
                      CanDeleteResult.CAN, const <String>[]);
                }
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
            unawaited(ProductsDao().delete(eventCast.product));
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
            final products =
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
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
            yield SearchProductsResultsState(queryResults);
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
                Helper.documentSnapshotsToProducts(productsListener.mSnapshots);
            if (codename.trim().isNotEmpty) {
              var found = false;
              for (final product in products) {
                if (product.universeUID == eventCast.universeUID &&
                    product.codename.toLowerCase() ==
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

      case ClearCacheEvent:
        {
          productsListener.clearCache();
        }
        break;

      default:
        {
          final e = Exception('Event not supported ${event.runtimeType}');
          yield ProductErrorState(e);
        }
    }
  }

  int _compareProductsByCodenameAsc(Product productA, Product productB) {
    return _compareProductsByCodename(productA, productB, false);
  }

  int _compareProductsByCodenameDesc(Product productA, Product productB) {
    return _compareProductsByCodename(productA, productB, true);
  }

  int _compareProductsByCodename(Product productA, Product productB, bool isDescending) {
    return productA.codename
            .toLowerCase()
            .compareTo(productB.codename.toLowerCase()) *
        (isDescending ? -1 : 1);
  }

  int _compareProductsByRandomAsc(Product productA, Product productB) {
    return _compareProductsByRandom(false);
  }

  int _compareProductsByRandomDesc(Product productA, Product productB) {
    return _compareProductsByRandom(true);
  }

  int _compareProductsByRandom(bool isDescending) {
    final rng = Random();
    return rng.nextInt(4).isEven ? 1 : -1 * (isDescending ? -1 : 1);
  }

  int _compareProductsByCreationDateAsc(Product productA, Product productB) {
    return _compareProductsByCreationDate(productA, productB, false);
  }

  int _compareProductsByCreationDateDesc(Product productA, Product productB) {
    return _compareProductsByCreationDate(productA, productB, true);
  }

  int _compareProductsByCreationDate(Product productA, Product productB, bool isDescending) {
    return productA.creationDate!.compareTo(productB.creationDate!) *
        (isDescending ? -1 : 1);
  }

  int _compareProductsByUpdateDateAsc(Product productA, Product productB) {
    return _compareProductsByUpdateDate(productA, productB, false);
  }

  int _compareProductsByUpdateDateDesc(Product productA, Product productB) {
    return _compareProductsByUpdateDate(productA, productB, true);
  }

  int _compareProductsByUpdateDate(Product productA, Product productB, bool isDescending) {
    return productA.updateDate!.compareTo(productB.updateDate!) *
        (isDescending ? -1 : 1);
  }

  @override
  void onDataSetChanged() {
    if (notifyDataChanged) {
      add(ProductsChangedEvent());
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    productsListener.stopListening();
    await _productsStateController.close();
    await _productsEventController.close();
  }
}
