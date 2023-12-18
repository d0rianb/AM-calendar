import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;


import 'package:package_info/package_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mailto/mailto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/color-helpers.dart';
import '../helpers/snackbar.dart';

const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);
const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);

final String proms = DateTime.now().isAfter(DateTime(2021, 12, 4)) ? '221' : '.21';

const String tabIndent = '        ';
const String DISCLAIMER = '''${tabIndent}Ce calendrier n'est pas une application officielle Arts & Métiers''';
const String USAGE = "${tabIndent}Ce calendrier utilise désormais les données du webcal de Lise et ceux de façon parfaitement légale. "
"Alors si demain votre directeur de campus vient chouiner que l'application n'est pas officielle et que les données ne sont pas les bonnes, "
"vous pourrez lui dire de charser en expliquant que le flux webcal de Lise est fourni par les Arts et qu'ils n'avaient qu'à "
"mieux branler leur système informatique. Les données de l'agenda ne sont d'ailleurs disponibles que sur 2 semaines à cause de la strass.";

Future<List<List<String>>> getDebugData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  List<List<String>> infos = [
    [packageInfo.appName, 'v${packageInfo.version}+${packageInfo.buildNumber}'],
    ['ID', prefs.getString('id') ?? ''],
    ['Filters', prefs.getString('filters') ?? ''],
  ];
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    infos.add(['Model', androidInfo.model]);
    infos.add(['Product', androidInfo.product]);
    infos.add(['Android Version', androidInfo.version.release]);
    infos.add(['SDK Version', androidInfo.version.sdkInt.toString()]);
    infos.add(['Last security patch', androidInfo.version.securityPatch.toString()]);
    infos.add(['Screen', '${androidInfo.displayMetrics.widthPx.toInt()}x${androidInfo.displayMetrics.heightPx.toInt()}']);
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
    infos.add(['Model', iosInfo.utsname.machine]);
    infos.add(['Name', iosInfo.name]);
    infos.add(['Version', iosInfo.systemName + ' ' + iosInfo.systemVersion]);
  }
  return infos;
}

Future<Widget> generateDebugRapport(BuildContext context) async {
  final dateFormatter = DateFormat('dd/MM/yyyy - HH:mm');
  return SingleChildScrollView(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Table(
              border: TableBorder.all(color: Colors.blueGrey[200]!, width: 1),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: (await getDebugData())
                  .map((row) => TableRow(children: [
                        Padding(padding: const EdgeInsets.all(8.0), child: Text(row[0], style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(row[1]),
                        ),
                      ]))
                  .toList(),
            ),
          ),
          Text(
            dateFormatter.format(DateTime.now()),
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey[500]!),
          ),
        ],
      ),
    ),
  );
}

class Infos extends StatefulWidget {
  const Infos({Key? key}) : super(key: key);

  @override
  InfosState createState() => InfosState();
}

class InfosState extends State<Infos> {
  late PackageInfo packageInfo = PackageInfo(appName: '', packageName: '', version: '', buildNumber: '');

  static const Widget Separator = SizedBox(height: 15);

  @override
  void initState() {
    super.initState();
    initPackageInfo();
  }

  Future<void> initPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  TextStyle titleStyle(BuildContext context) => Theme.of(context).textTheme.headlineSmall!.copyWith(
        color: lighten(VIOLET, 22),
        fontFamily: 'Cloister',
      );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final TextStyle textStyle = TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[800]!, fontSize: 16);
    final TextStyle linkTextStyle = TextStyle(color: isDarkMode ? Colors.blue[600]! : Colors.blue[900]!, fontSize: 16);
    final Color primaryColor = VIOLET;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Infos'),
          leading: BackButton(color: theme.appBarTheme.foregroundColor),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Disclaimer', style: titleStyle(context)),
              GestureDetector(
                onTap: () => showSnackBar(context, 'Nique la Strass'),
                child: RichText(
                  text: TextSpan(
                    text: DISCLAIMER,
                    style: textStyle,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              Separator,
              Text('Utilisation', style: titleStyle(context)),
              RichText(
                text: TextSpan(
                  text: USAGE,
                  style: textStyle,
                ),
                textAlign: TextAlign.justify,
              ),
              Separator,
              Text('Contact', style: titleStyle(context)),
              RichText(
                text: TextSpan(style: textStyle, children: [
                  TextSpan(text: '${tabIndent}Pour toute réclamation, bug, demande quelconque, veuillez envoyer un mail à '),
                  TextSpan(text: 'cette adresse', recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(Mailto(to: ['dorian.beauchesne@gmail.com'], subject: 'AM Calendar - Feedback').toString())), style: linkTextStyle),
                  TextSpan(text: '. Pour un soutien financier, somme toute très apprécié, voici mon '),
                  TextSpan(text: 'PayPal', recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse('https://paypal.me/d0rianb?country.x=FR&locale.x=fr_FR' '')), style: linkTextStyle),
                  TextSpan(text: '.'),
                ]),
                textAlign: TextAlign.justify,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    child: const Text('Génerer un rapport de debug'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(primaryColor),
                      foregroundColor: MaterialStateProperty.all(isDarkMode ? Colors.white70 : Colors.white),
                    ),
                    onPressed: () async {
                      final Widget debugContent = await generateDebugRapport(context);
                      return showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: const Text('Rapport de debug', textAlign: TextAlign.center),
                          ),
                          backgroundColor: Colors.white,
                          contentPadding: const EdgeInsets.all(2.0),
                          content: debugContent,
                          actions: [
                            TextButton(
                              child: Text('Cancel', style: TextStyle(color: primaryColor)),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: Text('Copy', style: TextStyle(color: primaryColor)),
                              onPressed: () async {
                                Clipboard.setData(ClipboardData(text: (await getDebugData()).map((row) => row.join(': ')).toList().join('\n')));
                                Navigator.of(context).pop();
                                showSnackBar(context, 'Le rapport de débug à bien été copié');
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '58ch$proms © ${packageInfo.appName} -  v${packageInfo.version}',
                style: TextStyle(color: Colors.grey[500], backgroundColor: Colors.transparent),
              ),
            ),
          ],
        ));
  }
}
