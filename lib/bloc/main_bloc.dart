import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/products_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/products_listener_bloc.dart';


class MainBloc {
  static List<BlocProvider> allBlocs() {
    return [
      BlocProvider<ProductsBloc>(
        lazy: true,
        create: (context) => ProductsBloc(),
      ),
      BlocProvider<ProductsListenerBloc>(
        lazy: false,
        create: (context) => ProductsListenerBloc(),
      ),
    ];
  }
}
