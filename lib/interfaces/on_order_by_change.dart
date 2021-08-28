
import 'package:little_drops_of_rain_flutter/enums/order_by.dart';

abstract class OnOrderByChange {
  void onOrderByChange(OrderBy? orderBy);
  void onOrderDirectionChange(bool descending);
}
