// ignore: import_of_legacy_library_into_null_safe

import 'package:logger/logger.dart';

class MyLogger {
  factory MyLogger() {
    return _instance;
  }

  MyLogger._internal();

  static const String routeName = '/console';
  Logger logger = Logger(
    filter: MyLogFilter(),
    printer: PrefixPrinter(PrettyPrinter()),
  );

  static final MyLogger _instance = MyLogger._internal();
}

class MyLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}
