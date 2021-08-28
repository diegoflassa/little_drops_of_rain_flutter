import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_drops_of_rain_flutter/anim/open_container_hero_wrapper.dart';
import 'package:little_drops_of_rain_flutter/bloc/events/products_events.dart';
import 'package:little_drops_of_rain_flutter/bloc/products_listener_bloc.dart';
import 'package:little_drops_of_rain_flutter/bloc/states/products_states.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart';
import 'package:little_drops_of_rain_flutter/enums/page_mode.dart';
import 'package:little_drops_of_rain_flutter/extensions/build_context_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/ui/my_scaffold.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/empty_items_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, this.title = Constants.APP_NAME})
      : super(key: key);

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(builder: (context) => const SearchPage());
  }

  static const String routeName = '/search';
  final String? title;

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Timer? _timerSearchQueryDebouncer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _timerSearchQueryDebouncer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = MyScaffold(
      onNewQuery: updateSearchQuery,
      isSearchMode: true,
      title: (widget.title != null) ? widget.title : '',
      body: Builder(
        builder: _buildBody,
      ),
    );
    return scaffold;
  }

  void updateSearchQuery(String newQuery) {
    if (context.isCurrent(this)) {
      setState(() {
        if (_timerSearchQueryDebouncer != null) {
          _timerSearchQueryDebouncer!.cancel();
        }
        _timerSearchQueryDebouncer = Timer(
            const Duration(milliseconds: Constants.DEFAULT_DELAY_TO_SEARCH),
            () {
          _isSearching = true;
          BlocProvider.of<ProductsListenerBloc>(context)
              .add(SearchProductsEvent(newQuery));
        });
      });
    }
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<ProductsListenerBloc, ProductsStates>(
      builder: (context, state) {
        Widget? ret = const EmptyItemsPage();
        if (_isSearching) {
          ret = const Center(child: CircularProgressIndicator());
        }
        if (state is SearchProductsResultsState) {
          _isSearching = false;
          if (state.products.isNotEmpty) {
            ret = GridView.count(
                childAspectRatio: Constants.DEFAULT_HERO_CARD_ASPECT_RATIO,
                shrinkWrap: true,
                crossAxisCount:
                    (MediaQuery.of(context).size.width / 350).round(),
                padding:
                    const EdgeInsets.all(Constants.DEFAULT_EDGE_INSETS_ALL),
                // Generate the card widgets to display
                children: (state is SearchProductsResultsState)
                    ? _getListOfFoundProductsAsCards(state.products)
                    : <Card>[]);
          } else {
            ret = const EmptyItemsPage();
          }
        }
        return ret;
      },
      listener: (context, state) {},
    );
  }

  List<Widget> _getListOfFoundProductsAsCards(List<Product> products) {
    final foundProducts = <Widget>[];
    for (final product in products) {
      foundProducts
          .add(OpenContainerProductWrapper(pageMode: PageMode.VIEW, product: product));
    }
    return foundProducts;
  }
}
