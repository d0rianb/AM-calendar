import 'package:am_calendar/helpers/requests.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../calendar.dart';
import '../helpers/refresh-indicator.dart';

class SplashScreen extends StatefulWidget {
  final SharedPreferences prefs;

  SplashScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() => super.initState();

  bool hasLoginInfos() {
    return widget.prefs.containsKey('id');
  }

  void toggleRoute(bool? hasLoginInfos, BuildContext context) {
    NavigatorState nav = Navigator.of(context);
    if (hasLoginInfos == null) return;
    if (!hasLoginInfos)
      Future.microtask(() => nav.pushReplacementNamed('/login'));
    else
      Future.microtask(() => nav.pushReplacementNamed('/calendar'));
  }

  @override
  Widget build(BuildContext context) {
    toggleRoute(hasLoginInfos(), context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 2 / 3,
              height: MediaQuery.of(context).size.width * 2 / 3,
              child: const Image(image: AssetImage('resources/icons/am-logo.png')),
            ),
            const SizedBox(height: 10),
            const ShadowedRefreshIndicator(color: VIOLET),
          ],
        ),
      ),
    );
  }
}
