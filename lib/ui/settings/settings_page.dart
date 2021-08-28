import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_svg/flutter_svg.dart';

import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/settings.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/ui/my_scaffold.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_text_style.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
        builder: (context) => const SettingsPage());
  }

  static const String routeName = '/settings';

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final _scrollController = ScrollController(initialScrollOffset: 5);

  @override
  void initState() {
    super.initState();
    Settings.initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(
              Size(640, MediaQuery
                  .of(context)
                  .size
                  .height)),
          child: Material(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
              child: Scrollbar(
                controller: _scrollController,
                isAlwaysShown: kIsWeb,
                child: ListView(
                  controller: _scrollController,
                  children: <Widget>[
                    ..._getBasicWidgets(),
                    const SizedBox(
                        height: Constants.DEFAULT_AD_BOTTOM_SPACE, width: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getBasicWidgets() {
    final widgets = <Widget>[];
    widgets.add(const SizedBox(
      width: 20,
      height: 20,
    ));
    widgets.add(Center(
        child: Text(AppLocalizations
            .of(context)
            .settings,
            style: const MyTextStyle.title())));
    widgets.add(const SizedBox(
      width: 20,
      height: 20,
    ));
    widgets.add(
      SvgPicture.asset('assets/images/font_awesome/solid/wrench.svg',
          placeholderBuilder: (context) =>
          const SizedBox(
              width: 100,
              height: 100,
              child: FittedBox(
                  fit: BoxFit.scaleDown, child: CircularProgressIndicator())),
          width: 100,
          height: 100),
    );

    widgets.add(const SizedBox(height: 10));

    return widgets;
  }
}
