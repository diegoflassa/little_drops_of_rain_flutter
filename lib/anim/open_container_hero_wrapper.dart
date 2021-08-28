import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/anim/open_container_wrapper.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart';
import 'package:little_drops_of_rain_flutter/enums/page_mode.dart';
import 'package:little_drops_of_rain_flutter/extensions/string_extensions.dart';
import 'package:little_drops_of_rain_flutter/interfaces/card_actions_callbacks.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:little_drops_of_rain_flutter/routing/routing_data.dart';
import 'package:little_drops_of_rain_flutter/ui/products/view_product.dart';
import 'package:little_drops_of_rain_flutter/ui/products/view_products.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_color_scheme.dart';
import 'package:little_drops_of_rain_flutter/ui/widgets/hero_card.dart';

class OpenContainerProductWrapper extends StatelessWidget {
  OpenContainerProductWrapper({
    required this.product,
    required this.pageMode,
    this.compact = false,
    this.cardActionsCallbacks,
    Key? key,
  }) : super(key: key);

  final Product product;
  final PageMode pageMode;
  final bool compact;
  final CardActionsCallbacks<Product>? cardActionsCallbacks;
  final CloseContainerActionCallback<ViewProductsPage> dummyCallback =
      ({returnValue}) {};

  Widget _openContainer(
    BuildContext context,
    CloseContainerActionCallback<ViewProductPage>? action,
  ) {
    cardActionsCallbacks?.onView(product);
    return ViewProductPage(_getRoutingData());
  }

  String _getPath() {
    return Routes.getParameterizedRouteForViewProduct(product);
  }

  RoutingData _getRoutingData() {
    var path = _getPath();
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return path.getRoutingData;
  }

  Widget _closeContainer(BuildContext context, VoidCallback callback) {
    return InkWell(
        child: ProductCard(product,
            key: UniqueKey(),
            cardActionsCallbacks: cardActionsCallbacks,
            compact: compact));
  }

  void _onClosed(dynamic value) {
    cardActionsCallbacks?.onViewed(product);
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainerWrapper<ViewProductPage>(
      openBuilder: _openContainer,
      openColor: MyColorScheme().primary,
      closedBuilder: _closeContainer,
      closedColor: product.getColorObject(),
      onClosed: _onClosed,
      routeSettings: RouteSettings(name: _getPath()),
    );
  }
}
