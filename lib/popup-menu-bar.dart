import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'helpers/app-events.dart';

const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);
const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);

class PopupMenuBar extends StatefulWidget {
  @override
  PopupMenuBarState createState() => PopupMenuBarState();
}

class PopupMenuBarState extends State<PopupMenuBar> {
  bool showCM = true;
  bool showTEAMS = true;
  bool showReunion = true;
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    initSharedPreferences().whenComplete(() => setState(() {
          showCM = prefs!.getBool('showCM') ?? true;
          showTEAMS = prefs!.getBool('showTEAMS') ?? true;
          showReunion = prefs!.getBool('showReunion') ?? true;
        }));
  }

  Future<void> initSharedPreferences() async => prefs = await SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    const iconColor = ORANGE;
    const double iconSize = 50;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () => eventBus.fire(RecallGetEvent()),
              child: SizedBox(width: iconSize, height: iconSize, child: Icon(Icons.refresh, color: iconColor)),
            ),
            InkWell(
              onTap: () => Navigator.of(context).pushNamed('/infos'),
              child: SizedBox(width: iconSize, height: iconSize, child: Icon(Icons.info, color: iconColor)),
            ),
            InkWell(
              onTap: () => Navigator.of(context).pushNamed('/settings'),
              child: SizedBox(width: iconSize, height: iconSize, child: Icon(Icons.settings, color: iconColor)),
            ),
          ],
        ),
        const Divider(height: 1, thickness: 1),
        InkWell(
            child: CheckboxListTile(
          title: const Text("Afficher les CM", style: TextStyle(color: ORANGE, fontSize: 14)),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          dense: true,
          value: showCM,
          onChanged: (value) {
            setState(() {
              showCM = value ?? true;
              prefs!.setBool('showCM', showCM);
              eventBus.fire(ReloadViewEvent());
            });
          },
        )),
        InkWell(
            child: CheckboxListTile(
          title: const Text("Afficher les TEAMS", style: TextStyle(color: ORANGE, fontSize: 14)),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          dense: true,
          value: showTEAMS,
          onChanged: (value) {
            setState(() {
              showTEAMS = value ?? true;
              prefs!.setBool('showTEAMS', showTEAMS);
              eventBus.fire(ReloadViewEvent());
            });
          },
        )),
        InkWell(
            child: CheckboxListTile(
          title: const Text("Afficher les r??unions", style: TextStyle(color: ORANGE, fontSize: 14)),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          dense: true,
          value: showReunion,
          onChanged: (value) {
            setState(() {
              showReunion = value ?? true;
              prefs!.setBool('showReunion', showReunion);
              eventBus.fire(ReloadViewEvent());
            });
          },
        )),
      ],
    );
  }
}
