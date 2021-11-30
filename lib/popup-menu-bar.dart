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
  SharedPreferences? prefs;


  @override
  void initState() {
    super.initState();
    initSharedPreferences().whenComplete(() => setState(() {
      showCM = prefs!.getBool('showCM') ?? true;
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
              onTap: () =>  eventBus.fire(RecallGetEvent()),
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
        const Divider(height: 1,thickness: 1),
      InkWell(
          child: CheckboxListTile(
            title: const Text("Afficher les CM", style: TextStyle(color: ORANGE, fontSize: 14)),
            dense: true,
            value: showCM,
            onChanged: (value) {
              setState(() {
                showCM = value ?? true;
                prefs!.setBool('showCM', showCM);
                eventBus.fire(ReloadViewEvent());
              });
            },
          )
      )
      ],
    );
  }
}
