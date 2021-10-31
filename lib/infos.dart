import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:package_info/package_info.dart';


const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);
const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);

final String proms = DateTime.now().isBefore(DateTime(2021, 12, 4)) ? '221' : '.21';

const String DISCLAIMER = '''\t\tCe calendrier n'est pas une application officielle Arts&Métiers. 
Elle a été crée par un élève voulant simplement avoir accès à son emploi du temps s'il vous plait ne me faite pas de procès.''';
const String USAGE = '''\t\tCe calendrier utilise les données de l'application Arts&Métiers Campus. Les données de l'agenda ne sont disponibles que sur 2 semaines. L'application s'actualise en arrière-plan à chaque ouverture.''';

class Infos extends StatefulWidget {
  @override
  InfosState createState() => InfosState();
}

class InfosState extends State<Infos> {
  late PackageInfo packageInfo;

  @override
  void initState() async {
    super.initState();
    packageInfo = await PackageInfo.fromPlatform();
  }

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        elevation: 2.0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infos')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Utilisation', style: Theme.of(context).textTheme.headline5!.copyWith(color: VIOLET)),
            RichText(
              text: TextSpan(
                text: USAGE,
                style: TextStyle(color: Colors.grey[800]),
              ),
            ),
            Text('Disclaimer', style: Theme.of(context).textTheme.headline5!.copyWith(color: VIOLET)),
            RichText(
              text: TextSpan(
                text: DISCLAIMER,
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[800]),
                recognizer: TapGestureRecognizer()..onTap = () => showSnackBar('Nique la Strass'),
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
                'Dorian&Co © ${packageInfo.appName} -  v${packageInfo.version}',
                style: TextStyle(color: Colors.grey[500], backgroundColor: Colors.transparent),
              ),
            ),
          ],
        )
    );
  }
}
