import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:little_drops_of_rain_flutter/data/entities/product.dart';
import 'package:little_drops_of_rain_flutter/enums/order_by.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';

abstract class ProductsEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductsInitialStateEvent extends ProductsEvents {
  ProductsInitialStateEvent() : super();

  @override
  List<Object?> get props => [];
}

class GetAllProductsEvent extends ProductsEvents {}

class GetAllProductsPaginatedAndTranslatedEvent extends ProductsEvents {
  GetAllProductsPaginatedAndTranslatedEvent(
      {this.startAt,
      this.pageSize = kIsWeb
          ? Constants.DEFAULT_PAGE_SIZE_WEB
          : Constants.DEFAULT_PAGE_SIZE_MOBILE,
      this.from = 'auto',
      this.to});

  final Product? startAt;
  final int pageSize;
  final String from;
  final String? to;

  @override
  List<Object?> get props => [startAt, pageSize, from, to];
}

class GetAllProductsPaginatedTranslatedAndOrderedEvent extends ProductsEvents {
  GetAllProductsPaginatedTranslatedAndOrderedEvent(
      {required this.orderBy,
      this.startAt,
      this.pageSize = kIsWeb
          ? Constants.DEFAULT_PAGE_SIZE_WEB
          : Constants.DEFAULT_PAGE_SIZE_MOBILE,
      this.from = 'auto',
      this.to,
      this.descending = false});

  final Product? startAt;
  final int pageSize;
  final String from;
  final String? to;
  final OrderBy orderBy;
  final bool descending;

  @override
  List<Object?> get props => [startAt, pageSize, from, to, orderBy, descending];
}

class GetMyProductsPaginatedAndTranslatedEvent extends ProductsEvents {
  GetMyProductsPaginatedAndTranslatedEvent(this.userUID,
      {this.startAt,
      this.pageSize = kIsWeb
          ? Constants.DEFAULT_PAGE_SIZE_WEB
          : Constants.DEFAULT_PAGE_SIZE_MOBILE,
      this.from = 'auto',
      this.to});

  final String userUID;
  final Product? startAt;
  final int pageSize;
  final String from;
  final String? to;

  @override
  List<Object?> get props => [startAt, pageSize, from, to];
}

class GetMyProductsPaginatedTranslatedAndOrderedEvent extends ProductsEvents {
  GetMyProductsPaginatedTranslatedAndOrderedEvent(this.userUID,
      {required this.orderBy,
      this.startAt,
      this.pageSize = kIsWeb
          ? Constants.DEFAULT_PAGE_SIZE_WEB
          : Constants.DEFAULT_PAGE_SIZE_MOBILE,
      this.from = 'auto',
      this.to,
      this.descending = false});

  final String userUID;
  final Product? startAt;
  final int pageSize;
  final String from;
  final String? to;
  final OrderBy orderBy;
  final bool descending;

  @override
  List<Object?> get props => [startAt, pageSize, from, to, orderBy, descending];
}

class GetAllProductsByUniverseEvent extends ProductsEvents {
  GetAllProductsByUniverseEvent(this.universeUID);

  final String universeUID;

  @override
  List<Object?> get props => [universeUID];
}

class GetMyProductsEvent extends ProductsEvents {
  GetMyProductsEvent(this.userUID);

  final String userUID;

  @override
  List<Object?> get props => [userUID];
}

class GetMyProductEvent extends ProductsEvents {
  GetMyProductEvent(this.userUID, this.productUID);

  final String userUID;
  final String productUID;

  @override
  List<Object?> get props => [userUID, productUID];
}

class GetProductEvent extends ProductsEvents {
  GetProductEvent(this.productUID);

  final String productUID;

  @override
  List<Object?> get props => [productUID];
}

class GetProductsByCivilNameEvent extends ProductsEvents {
  GetProductsByCivilNameEvent(
      this.userUID, this.productCivilName, this.productUniverse);

  final String userUID;
  final String productCivilName;
  final String productUniverse;

  @override
  List<Object?> get props => [userUID, productCivilName, productUniverse];
}

class GetProductByCodeNameEvent extends ProductsEvents {
  GetProductByCodeNameEvent(this.userUID, this.productCodeName, this.productUniverse);

  final String? userUID;
  final String productCodeName;
  final String productUniverse;

  @override
  List<Object?> get props => [userUID, productCodeName, productUniverse];
}

class GetProductsByCodeNameEvent extends ProductsEvents {
  GetProductsByCodeNameEvent(this.userUID, this.productCodeName);

  final String? userUID;
  final String productCodeName;

  @override
  List<Object?> get props => [userUID, productCodeName];
}

class GetProductsByCivilOrCodeNameEvent extends ProductsEvents {
  GetProductsByCivilOrCodeNameEvent(
      this.userUID, this.productCivilOrCodeName, this.productUniverse);

  final String? userUID;
  final String productCivilOrCodeName;
  final String productUniverse;

  @override
  List<Object?> get props => [userUID, productCivilOrCodeName, productUniverse];
}

class SaveProductEvent extends ProductsEvents {
  SaveProductEvent(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends ProductsEvents {
  UpdateProductEvent(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

class IncrementProductViewsEvent extends ProductsEvents {
  IncrementProductViewsEvent(this.productUID);

  final String productUID;

  @override
  List<Object?> get props => [productUID];
}

class DeleteProductEvent extends ProductsEvents {
  DeleteProductEvent(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

class TranslateProductEvent extends ProductsEvents {
  TranslateProductEvent(this.product, this.to, {this.from = 'auto'});

  final String from;
  final String to;
  final Product product;

  @override
  List<Object?> get props => [from, to, product];
}

class TranslateProductsEvent extends ProductsEvents {
  TranslateProductsEvent(this.products, this.to, {this.from = 'auto'});

  final String from;
  final String to;
  final List<Product> products;

  @override
  List<Object?> get props => [from, to, products];
}

class SearchProductsEvent extends ProductsEvents {
  SearchProductsEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ValidateProductCodeNameEvent extends ProductsEvents {
  ValidateProductCodeNameEvent(this.codename, this.universeUID);

  final String universeUID;
  final String codename;

  @override
  List<Object?> get props => [universeUID, codename];
}

class CanDeleteProductEvent extends ProductsEvents {
  CanDeleteProductEvent(this.product, this.userUID);

  final String userUID;
  final Product product;

  @override
  List<Object?> get props => [userUID, product];
}

class ProductsChangedEvent extends ProductsEvents {}

class ClearCacheEvent extends ProductsEvents {
  ClearCacheEvent() : super();

  @override
  List<Object?> get props => [this];

  @override
  String toString() {
    return 'ClearCacheEvent';
  }
}
