import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);
const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);

class PopupMenuBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const iconColor = ORANGE;
    const double iconSize = 44;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () =>  Navigator.of(context).pushNamed('/calendar'),
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
    );
  }
}
