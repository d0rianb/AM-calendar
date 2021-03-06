import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../calendar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  SharedPreferences? prefs;

  @override
  void initState() => super.initState();

  Future<void> initSharedPreferences() async => prefs = await SharedPreferences.getInstance();

  Future<bool> hasLoginInfos() async {
    if (prefs == null) await initSharedPreferences();
    return prefs!.containsKey('cmAuthToken');
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
    return FutureBuilder<bool?>(
      future: hasLoginInfos(),
      builder: (context, snapshot) {
        toggleRoute(snapshot.data, context);
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
                const RefreshProgressIndicator(color: VIOLET, strokeWidth: 2.5),
              ],
            ),
          ),
        );
      },
    );
  }
}
