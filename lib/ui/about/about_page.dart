import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/data/dao/config_dao.dart';
import 'package:little_drops_of_rain_flutter/data/entities/config.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/ui/my_scaffold.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key, this.title}) : super(key: key);

  final String? title;

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(builder: (context) => const AboutPage());
  }

  static const String routeName = '/about';

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _processing = true;
  String _aboutText = '';
  final _scrollController = ScrollController(initialScrollOffset: 5);
  Config? _config;
  String htmlOpeningString = '<!DOCTYPE html><html><body>';
  String htmlClosingString = '</body></html>';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = MyScaffold(
      title: (widget.title != null) ? widget.title : '',
      body: _buildBody(context),
    );
    return scaffold;
  }

  Widget _buildBody(BuildContext context) {
    if (_aboutText.isEmpty) {
      ConfigDao().getConfig().then((config) {
        _config = config;
        _aboutText = htmlOpeningString +
            ((_config!.aboutText != null) ? _config!.aboutText! : '') +
            htmlClosingString;
        setState(() {
          _processing = false;
        });
      });
    }
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(
              Size(640, MediaQuery.of(context).size.height)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
            child: _processing
                ? const CircularProgressIndicator()
                : Scrollbar(
                    controller: _scrollController,
                    isAlwaysShown: kIsWeb,
                    child: ListView(
                      shrinkWrap: true,
                      controller: _scrollController,
                      children: <Widget>[
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
