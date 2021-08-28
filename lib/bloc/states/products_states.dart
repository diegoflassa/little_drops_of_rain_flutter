import 'package:equatable/equatable.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/products_events.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart';
import 'package:little_drops_of_rain_flutter/enums/can_delete_result.dart';
import 'package:little_drops_of_rain_flutter/enums/name_validation_result.dart';
import 'package:little_drops_of_rain_flutter/enums/order_by.dart';

abstract class ProductsStates extends Equatable {
  @override
  List<Object?> get props => [];

  @override
  String toString() {
    return 'ProductsStates';
  }
}

class ProductsInitialState extends ProductsStates {
  ProductsInitialState() : super();

  @override
  List<Object?> get props => [];

  @override
  String toString() {
    return 'ProductsInitialState';
  }
}

class GettingProductsDataState<T extends ProductsEvents> extends ProductsStates {
  GettingProductsDataState(this.event) : super();

  @override
  List<Object?> get props => [
        event,
      ];
  final T event;

  @override
  String toString() {
    return 'GettingProductsDataState<$event>';
  }
}

class GettingProductDataState<T extends ProductsEvents> extends ProductsStates {
  GettingProductDataState(this.event) : super();

  @override
  List<Object?> get props => [event];
  final T event;

  @override
  String toString() {
    return 'GettingProductDataState<$event>';
  }
}

class GotAllProductsPaginatedAndTranslatedState extends ProductsStates {
  GotAllProductsPaginatedAndTranslatedState(
      this.products, this.endOfList, this.page,
      {this.from = 'auto', this.to})
      : super();

  final List<Product> products;
  final String from;
  final String? to;
  final bool endOfList;
  final int page;

  @override
  List<Object?> get props => [products, from, to, endOfList, page];

  @override
  String toString() {
    return 'GotAllProductsPaginatedAndTranslatedState';
  }
}

class GotAllProductsPaginatedTranslatedAndOrderedState extends ProductsStates {
  GotAllProductsPaginatedTranslatedAndOrderedState(
      this.products, this.orderBy, this.descending, this.endOfList, this.page,
      {this.from = 'auto', this.to})
      : super();

  final List<Product> products;
  final String from;
  final String? to;
  final OrderBy orderBy;
  final bool descending;
  final bool endOfList;
  final int page;

  @override
  List<Object?> get props =>
      [products, from, to, orderBy, descending, endOfList, page];

  @override
  String toString() {
    return 'GotAllProductsPaginatedTranslatedAndOrderedState';
  }
}

class GotMyProductsPaginatedAndTranslatedState extends ProductsStates {
  GotMyProductsPaginatedAndTranslatedState(
      this.userUID, this.products, this.endOfList, this.page,
      {this.from = 'auto', this.to})
      : super();

  final String userUID;
  final List<Product> products;
  final String from;
  final String? to;
  final bool endOfList;
  final int page;

  @override
  List<Object?> get props => [userUID, products, from, to, endOfList, page];

  @override
  String toString() {
    return 'GotMyProductsPaginatedAndTranslatedState';
  }
}

class GotMyProductsPaginatedTranslatedAndOrderedState extends ProductsStates {
  GotMyProductsPaginatedTranslatedAndOrderedState(this.userUID, this.products,
      this.orderBy, this.descending, this.endOfList, this.page,
      {this.from = 'auto', this.to})
      : super();

  final String userUID;
  final List<Product> products;
  final String from;
  final String? to;
  final OrderBy orderBy;
  final bool descending;
  final bool endOfList;
  final int page;

  @override
  List<Object?> get props =>
      [userUID, products, from, to, orderBy, descending, endOfList, page];

  @override
  String toString() {
    return 'GotMyProductsPaginatedTranslatedAndOrderedState';
  }
}

class GotAllProductsState extends ProductsStates {
  GotAllProductsState(this.products) : super();

  final List<Product> products;

  @override
  List<Object?> get props => [products];

  @override
  String toString() {
    return 'GotAllProductsState';
  }
}

class GotAllProductsByUniverseState extends ProductsStates {
  GotAllProductsByUniverseState(this.products);

  final List<Product> products;

  @override
  List<Object?> get props => [products];

  @override
  String toString() {
    return 'GotAllProductsByUniverseState';
  }
}

class GotMyProductsState extends ProductsStates {
  GotMyProductsState(this.products) : super();

  final List<Product> products;

  @override
  List<Object?> get props => [products];

  @override
  String toString() {
    return 'GotMyProductsState';
  }
}

class GotMyProductState extends ProductsStates {
  GotMyProductState(this.product) : super();

  final Product product;

  @override
  List<Object?> get props => [product];

  @override
  String toString() {
    return 'GotMyProductState';
  }
}

class GotProductState extends ProductsStates {
  GotProductState(this.product) : super();

  final Product product;

  @override
  List<Object?> get props => [product];

  @override
  String toString() {
    return 'GotProductState';
  }
}

class GotProductsByCivilNameState extends ProductsStates {
  GotProductsByCivilNameState(this.products) : super();

  final List<Product> products;

  @override
  List<Object?> get props => [products];

  @override
  String toString() {
    return 'GotProductsByCivilNameState';
  }
}

class GotProductByCodeNameState extends ProductsStates {
  GotProductByCodeNameState(this.product) : super();

  final Product product;

  @override
  List<Object?> get props => [product];

  @override
  String toString() {
    return 'GotProductByCodeNameState';
  }
}

class GotProductsByCodeNameState extends ProductsStates {
  GotProductsByCodeNameState(this.products) : super();

  final List<Product> products;

  @override
  List<Object?> get props => [products];

  @override
  String toString() {
    return 'GotProductsByCodeNameState';
  }
}

class GotProductsByCivilOrCodeNameState extends ProductsStates {
  GotProductsByCivilOrCodeNameState(this.products) : super();

  final List<Product> products;

  @override
  List<Object?> get props => [products];

  @override
  String toString() {
    return 'GotProductsByCivilOrCodeNameState';
  }
}

class ProductsChangedState extends ProductsStates {
  ProductsChangedState(this.products) : super();

  final List<Product> products;

  @override
  List<Object?> get props => [products];

  @override
  String toString() {
    return 'ProductsChangedState';
  }
}

class SavingProductState extends ProductsStates {
  SavingProductState(this.product) : super();

  final Product product;

  @override
  List<Object?> get props => [product];

  @override
  String toString() {
    return 'SavingProductState';
  }
}

class ProductSavedState extends ProductsStates {
  ProductSavedState(this.product) : super();

  final Product product;

  @override
  List<Object?> get props => [product];

  @override
  String toString() {
    return 'ProductSavedState';
  }
}

class UpdatingProductState extends ProductsStates {
  UpdatingProductState(this.product) : super();

  final Product product;

  @override
  List<Object?> get props => [product];

  @override
  String toString() {
    return 'UpdatingProductState';
  }
}

class ProductUpdatedState extends ProductsStates {
  ProductUpdatedState(this.product) : super();

  final Product product;

  @override
  List<Object?> get props => [product];

  @override
  String toString() {
    return 'ProductUpdatedState';
  }
}

class CanDeleteProductState extends ProductsStates {
  CanDeleteProductState(this.product, this.can, this.result, this.references)
      : super();

  final bool can;
  final Product product;
  final CanDeleteResult result;
  final List<String> references;

  @override
  List<Object?> get props => [product, can, result, references];

  @override
  String toString() {
    return 'CanDeleteProductState';
  }
}

class ProductDeletedState extends ProductsStates {
  ProductDeletedState(this.product) : super();

  final Product product;

  @override
  List<Object?> get props => [product];

  @override
  String toString() {
    return 'ProductDeletedState';
  }
}

class ProductsEmptyState extends ProductsStates {
  ProductsEmptyState() : super();

  @override
  List<Object?> get props => [this];

  @override
  String toString() {
    return 'ProductsEmptyState';
  }
}

class SearchProductsResultsState extends ProductsStates {
  SearchProductsResultsState(this.products) : super();

  final List<Product> products;

  @override
  List<Object?> get props => [products];

  @override
  String toString() {
    return 'SearchProductsResultsState';
  }
}

class ValidatedProductCodeNameState extends ProductsStates {
  ValidatedProductCodeNameState(
      this.isValid, this.characters, this.validationResult)
      : super();

  final NameValidationResult validationResult;
  final List<String> characters;
  final bool isValid;

  @override
  List<Object?> get props => [validationResult, characters, isValid];

  @override
  String toString() {
    return 'ValidatedProductCodeNameState';
  }
}

class ProductErrorState extends ProductsStates {
  ProductErrorState(this.e) : super();

  final dynamic e;

  @override
  List<Object?> get props => [e];

  @override
  String toString() {
    return 'ProductErrorState';
  }
}

class GotProductErrorState extends ProductsStates {
  GotProductErrorState(this.e) : super();

  final dynamic e;

  @override
  List<Object?> get props => [e];

  @override
  String toString() {
    return 'GotProductErrorState';
  }
}

class ProductTranslationErrorState extends ProductsStates {
  ProductTranslationErrorState(this.e, this.from, this.to) : super();

  final String from;
  final String to;
  final dynamic e;

  @override
  List<Object?> get props => [from, to, e];

  @override
  String toString() {
    return 'ProductTranslationErrorState';
  }
}
