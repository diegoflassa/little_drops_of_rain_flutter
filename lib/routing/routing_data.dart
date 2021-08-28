class RoutingData {
  RoutingData({
    this.route,
    Map<String, String> queryParameters = const <String, String>{},
  }) : _queryParameters = queryParameters;

  final Uri? route;
  final Map<String, String> _queryParameters;

  String? operator [](String key) => _queryParameters[key];
}
