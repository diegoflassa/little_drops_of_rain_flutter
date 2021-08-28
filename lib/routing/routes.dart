import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart';
import 'package:little_drops_of_rain_flutter/enums/element_type.dart';
import 'package:little_drops_of_rain_flutter/extensions/string_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:little_drops_of_rain_flutter/ui/about/about_page.dart';
import 'package:little_drops_of_rain_flutter/ui/cropper/image_crop_widget.dart';
import 'package:little_drops_of_rain_flutter/ui/products/view_products.dart';
import 'package:little_drops_of_rain_flutter/ui/login/email_password_signin_page.dart';
import 'package:little_drops_of_rain_flutter/ui/login/login_page.dart';
import 'package:little_drops_of_rain_flutter/ui/search/search_page.dart';
import 'package:little_drops_of_rain_flutter/ui/settings/settings_page.dart';
import 'package:little_drops_of_rain_flutter/ui/users/my_profile.dart';

class Routes {
  static const String login = LoginPage.routeName;
  static const String home = ViewProductsPage.routeName;
  static const String viewProducts = ViewProductsPage.routeName;
  static const String myProfile = MyProfilePage.routeName;
  static const String emailPasswordSignIn = EmailPasswordSignInPage.routeName;
  static const String about = AboutPage.routeName;
  static const String imageCropWidget = ImageCropWidget.routeName;
  static const String settings = SettingsPage.routeName;
  static const String search = SearchPage.routeName;
  static const String console = MyLogger.routeName;

  static MaterialPageRoute<dynamic> generateRoute(RouteSettings settings) {
    final routingData = settings.name!.getRoutingData;
    MyLogger().logger.d(routingData);
    var route = MaterialPageRoute<dynamic>(
      builder: (context) => ViewProductsPage(routingData: routingData),
      settings: settings,
    );
    if (routingData.route != null) {
      MyLogger().logger.d(
          'routingData.route.pathSegments: ${routingData.route!.pathSegments}');
      if (containsRouteViewProduct(routingData.route!.path)) {
        switch (routingData.route!.path) {
          case viewProducts:
            {
              route = MaterialPageRoute<dynamic>(
                builder: (context) =>
                    ViewProductsPage(routingData: routingData),
                settings: settings,
              );
            }
            break;
          // View Universe
          default:
            route = MaterialPageRoute<dynamic>(
              builder: (context) => ViewProductsPage(routingData: routingData),
              settings: settings,
            );
        }
      } else if (routingData.route!.pathSegments.length == 1) {
      } else if (routingData.route!.pathSegments.length == 2) {
      } else {}
    } else {}
    return route;
  }

  static bool containsRouteViewProduct(String route) {
    return route.contains(viewProducts.replaceFirst('/', ''));
  }

  static String getParameterizedRouteForViewProduct(Product product){
    return 'viewProducts?${ViewProductsPage.ROUTING_PARAM_PRODUCT_ID}=${product.uid}';
  }

  static String getParameterizedRouteByViewElements(ElementType type,
      {bool myElements = false}) {
    var ret = '';
    switch (type) {
      case ElementType.PRODUCT:
        {
          if (myElements) {
            ret =
                '$viewProducts?${ViewProductsPage.ROUTING_PARAM_PRODUCT_ID}=$myElements';
          } else {
            ret = viewProducts;
          }
        }
        break;
      case ElementType.UNKNOWN:
        {
          ret =
              '$viewProducts?${ViewProductsPage.ROUTING_PARAM_PRODUCT_ID}=${false}';
        }
        break;
    }
    return ret;
  }
}
