import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_text_style.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:url_launcher/url_launcher.dart';

class GoBackWidget extends StatelessWidget {
  const GoBackWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? FittedBox(
            child: Column(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        style: const MyTextStyle.link(),
                        text: AppLocalizations.of(context).clickHereToGoBack,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final url = Uri.base.toString();
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              //throw 'Could not launch $url';
                            }
                          },
                      ),
                    ],
                  ),
                ),
                Text(
                    '${AppLocalizations.of(context).or} ${AppLocalizations.of(context).clickBackButton}'),
              ],
            ),
          )
        : Text(AppLocalizations.of(context).clickBackButton);
  }
}
