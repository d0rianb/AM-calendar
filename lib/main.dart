import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:event_bus/event_bus.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_10y.dart' as tz;

import 'calendar.dart';
import 'helpers/app-events.dart';
import 'helpers/cache-handler.dart';
import 'helpers/localization_extendibility.dart';
import 'helpers/prefs-helper.dart';
import 'routes/infos.dart';
import 'routes/login-view.dart';
import 'routes/login-webview.dart';
import 'routes/splash-screen.dart';
import 'routes/settings.dart';

EventBus eventBus = EventBus();

const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);
const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  final prefs = await SharedPreferences.getInstance();
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final String versionNumber = packageInfo.version;
  final bool shouldResetCache = prefs.getString('versionNumber') != versionNumber;
  if (shouldResetCache) {
    clearEventCache(prefs);
    prefs.setString('versionNumber', versionNumber);
  }
  runApp(App(prefs));
}

class App extends StatefulWidget {
  final SharedPreferences prefs;

  App(this.prefs);

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  late ThemeMode theme = getThemeMode(widget.prefs);

  @override
  void initState() {
    super.initState();
    eventBus.on<ThemeChangeEvent>().listen(
          (event) => setState(() {
            theme = event.theme;
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'AM Calendar',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          SfLocalizationsFrDelegate(),
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
        ],
        locale: const Locale('fr'),
        themeMode: theme,
        theme: ThemeData(
          primarySwatch: Colors.amber,
          primaryColor: VIOLET,
          colorScheme: ColorScheme.fromSwatch(
            primaryColorDark: VIOLET,
            accentColor: ORANGE,
          ),
          backgroundColor: const Color(0xfafafaff),
          textTheme: const TextTheme(
            subtitle1: TextStyle(color: Colors.black54),
            subtitle2: TextStyle(color: Colors.black45),
            headline5: TextStyle(color: Colors.black), // for the `infos` page
            bodyText1: TextStyle(color: Colors.black),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: VIOLET,
            foregroundColor: Colors.white,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          brightness: Brightness.dark,
          applyElevationOverlayColor: true,
          primaryColor: ORANGE,
          colorScheme: ColorScheme.fromSwatch(
            primaryColorDark: ORANGE,
            accentColor: ORANGE,
          ),
          backgroundColor: const Color.fromRGBO(31, 26, 36, 1.0),
          primaryColorDark: VIOLET,
          highlightColor: ORANGE,
          toggleableActiveColor: ORANGE,
          outlinedButtonTheme: OutlinedButtonThemeData(
              style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(VIOLET),
          )),
          textTheme: const TextTheme(
            labelMedium: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.87)),
            subtitle1: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.6)),
            subtitle2: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5)),
            headline5: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.87)), // for the `infos` page
            bodyText1: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.87)),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: VIOLET,
            foregroundColor: Colors.white70,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(prefs: widget.prefs),
          '/calendar': (context) => CalendarPage(title: 'AM calendar', prefs: widget.prefs),
          '/login': (context) => LoginView(prefs: widget.prefs),
          '/web-login': (context) => const LoginWebView(),
          '/infos': (context) => const Infos(),
          '/settings': (context) => Settings(prefs: widget.prefs),
        });
  }
}

class CalendarPage extends StatefulWidget {
  final String title;
  final SharedPreferences prefs;

  const CalendarPage({Key? key, required this.title, required this.prefs}) : super(key: key);

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Calendar(widget.prefs)),
    );
  }
}
