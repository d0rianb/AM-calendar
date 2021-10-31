import 'package:am_calendar/helplers/snackbar.dart';
import 'package:flutter/material.dart';

import 'package:package_info/package_info.dart';


const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);
const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);

final String proms = DateTime.now().isAfter(DateTime(2021, 12, 4)) ? '221' : '.21';

const String DISCLAIMER = '''\t\tCe calendrier n'est pas une application officielle Arts&Métiers. 
Elle a été crée par un élève voulant simplement avoir accès à son emploi du temps s'il vous plait ne me faite pas de procès.''';
const String USAGE = '''\t\tCe calendrier utilise les données de l'application Arts&Métiers Campus. Les données de l'agenda ne sont disponibles que sur 2 semaines. L'application s'actualise en arrière-plan à chaque ouverture.''';

class Infos extends StatefulWidget {
  @override
  InfosState createState() => InfosState();
}

class InfosState extends State<Infos> {
  late PackageInfo packageInfo = PackageInfo(appName: '', packageName: '', version: '', buildNumber: '');

  @override
  void initState() {
    super.initState();
    initPackageInfo();
  }

  Future<void> initPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  TextStyle titleStyle(BuildContext context) => Theme.of(context)
        .textTheme
        .headline5!
        .copyWith(color: VIOLET, fontFamily: 'Cloister');

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
            Text('Utilisation', style: titleStyle(context)),
            RichText(
              text: TextSpan(
                text: USAGE,
                style: TextStyle(color: Colors.grey[800]),
              ),
            ),
            SizedBox(height: 15),
            Text('Disclaimer', style: titleStyle(context)),
            GestureDetector(
              onTap: () => showSnackBar(context, 'Nique la Strass'),
              child: RichText(
                text: TextSpan(
                  text: DISCLAIMER,
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[800]),
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
        )
    );
  }
}
