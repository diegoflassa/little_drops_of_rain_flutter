import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/anim/open_container_product_wrapper.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart' as my_app;
import 'package:little_drops_of_rain_flutter/enums/page_mode.dart';
import 'package:little_drops_of_rain_flutter/extensions/list_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/ui/pages/empty_items_page.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_text_style.dart';

class ListProductsWidget extends StatelessWidget {
  ListProductsWidget(
      {required this.products,
      this.compact = true,
      this.scroll = true,
      Key? key,
      this.title})
      : super(key: key) {
    _getListOfProductsAsCards(products);
  }

  static Route<dynamic> route(List<my_app.Product> products) {
    return MaterialPageRoute<dynamic>(
        builder: (context) => ListProductsWidget(products: products));
  }

  final bool compact;
  final bool scroll;
  final String? title;
  final List<my_app.Product> products;
  final List<Widget> _productsAsCards = <Widget>[];
  final _scrollController = ScrollController(initialScrollOffset: 5);

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      isAlwaysShown: kIsWeb,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title != null) Text(title!, style: const MyTextStyle.bold()),
          if (title != null)
            const SizedBox(height: Constants.DEFAULT_EDGE_INSETS_VERTICAL_HALF),
          if (scroll)
            ConstrainedBox(
              constraints: BoxConstraints.loose(const Size(
                  double.infinity, Constants.DEFAULT_LIST_HEROES_HEIGHT)),
              child: _productsAsCards.isNotEmpty
                  ? CustomScrollView(
                      shrinkWrap: true,
                      controller: _scrollController,
                      slivers: <Widget>[
                        // Build the items lazily
                        SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                Constants.DEFAULT_CARD_CROSS_AXIS_COUNT,
                            mainAxisSpacing:
                                Constants.DEFAULT_CARD_MAIN_AXIS_SPACING,
                            crossAxisSpacing:
                                Constants.DEFAULT_CARD_CROSS_AXIS_SPACING,
                            childAspectRatio:
                                Constants.DEFAULT_LIST_HERO_CARD_ASPECT_RATIO,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _productsAsCards[index];
                            },
                            addAutomaticKeepAlives: false,
                            childCount: _productsAsCards.length,
                          ),
                        ),
                      ],
                    )
                  : const EmptyItemsPage(),
            ),
          if (!scroll) ..._productsAsCards,
        ],
      ),
    );
  }

  List<Widget> _getListOfProductsAsCards(List<my_app.Product> products) {
    _productsAsCards.clear();
    final myProducts = <Widget>[];
    for (final product in products) {
      myProducts.add(OpenContainerProductWrapper(
        pageMode: PageMode.VIEW,
        product: product,
        compact: compact,
      ));
    }
    _productsAsCards.addAllUnique(myProducts);
    _productsAsCards.add(
        const SizedBox(height: Constants.DEFAULT_AD_BOTTOM_SPACE, width: 1));
    return _productsAsCards;
  }
}
