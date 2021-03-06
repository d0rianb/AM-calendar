import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:package_info/package_info.dart';
import 'package:mailto/mailto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/snackbar.dart';

const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);
const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);

final String proms = DateTime.now().isAfter(DateTime(2021, 12, 4)) ? '221' : '.21';

const String tabIndent = '        ';
const String DISCLAIMER = '''${tabIndent}Ce calendrier n'est pas une application officielle Arts&Métiers. 
Elle a été crée par un élève voulant simplement avoir accès à son emploi du temps s'il vous plait ne me faite pas de procès.''';
const String USAGE = '''${tabIndent}Ce calendrier utilise les données de l'application Arts&Métiers Campus. Les données de l'agenda ne sont disponibles que sur 2 semaines. L'application s'actualise en arrière-plan à chaque ouverture.''';
final Widget CONTACT = RichText(
  text: TextSpan(children: [
    TextSpan(text: '${tabIndent}Pour toute réclamation, bug, demande quelconque, veuillez envoyer un mail à ', style: TextStyle(color: Colors.grey[800])),
    TextSpan(text: 'cette adresse', recognizer: TapGestureRecognizer()..onTap = () => launch(Mailto(to: ['dorian.beauchesne@gmail.com'], subject: 'AM Calendar - Feedback').toString()), style: TextStyle(color: Colors.blue[900])),
    TextSpan(text: '. Pour un soutien financier, somme toute très apprécié, voici mon ', style: TextStyle(color: Colors.grey[800])),
    TextSpan(text: 'PayPal', recognizer: TapGestureRecognizer()..onTap = () => launch('https://paypal.me/d0rianb?country.x=FR&locale.x=fr_FR' ''), style: TextStyle(color: Colors.blue[900])),
    TextSpan(text: '.', style: TextStyle(color: Colors.grey[800])),
  ]),
  textAlign: TextAlign.justify,
);

String crypt(String? str) {
  if (str == null) return '';
  final List<String> encodedBuffer = str.split('').map((letter) => letter.codeUnitAt(0) + str.length).map((charCode) => String.fromCharCode(charCode)).toList();
  encodedBuffer.insert(0, String.fromCharCode(str.length));
  return encodedBuffer.join('').trim();
}

String decrypt(String? str) {
  if (str == null) return '';
  List<String> list = str.substring(1).split('');
  final strLength = str[0].codeUnitAt(0);
  return list.map((letter) => letter.codeUnitAt(0) - strLength).map((charCode) => String.fromCharCode(charCode)).join('');
}

Future<List<List<String>>> getDebugData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return [
    [packageInfo.appName, 'v${packageInfo.version}+${packageInfo.buildNumber}'],
    ['ID', prefs.getString('id') ?? ''],
    ['Password', crypt(prefs.getString('password')).trim()],
    ['CmAuthToken', (prefs.getString('cmAuthToken')?.substring(0, 10) ?? '') + '...']
  ];
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

  TextStyle titleStyle(BuildContext context) => Theme.of(context).textTheme.headline5!.copyWith(color: VIOLET, fontFamily: 'Cloister');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Infos'), backgroundColor: VIOLET),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Utilisation', style: titleStyle(context)),
              RichText(
                text: TextSpan(
                  text: USAGE,
                  style: TextStyle(color: Colors.grey[800]),
                ),
                textAlign: TextAlign.justify,
              ),
              Separator,
              Text('Disclaimer', style: titleStyle(context)),
              GestureDetector(
                onTap: () => showSnackBar(context, 'Nique la Strass'),
                child: RichText(
                  text: TextSpan(
                    text: DISCLAIMER,
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(fontStyle: FontStyle.italic),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              Separator,
              Text('Contact', style: titleStyle(context)),
              CONTACT,
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: ElevatedButton(
                    child: const Text('Génerer un rapport de debug'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(VIOLET),
                    ),
                    onPressed: () async {
                      final debugContent = await generateDebugRapport(context);
                      return showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: const Text('Rapport de debug', textAlign: TextAlign.center),
                          ),
                          contentPadding: const EdgeInsets.all(2.0),
                          content: debugContent,
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel', style: TextStyle(color: VIOLET)),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: const Text('Copy', style: TextStyle(color: VIOLET)),
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
