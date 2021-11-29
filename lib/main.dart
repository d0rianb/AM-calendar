import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:event_bus/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/infos.dart';
import 'helpers/localization_extendibility.dart';
import 'calendar.dart';
import 'routes/login-view.dart';
import 'routes/splash-screen.dart';
import 'routes/settings.dart';

EventBus eventBus = EventBus();

const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);
const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((value) => value.clear());
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AM Calendar',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        SfLocalizationsFrDelegate(),
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      locale: const Locale('fr'),
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: VIOLET,
        colorScheme: ColorScheme.fromSwatch(
          primaryColorDark: VIOLET,
          accentColor: ORANGE,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/calendar': (context) => const CalendarPage(title: 'AM calendar'),
        '/login': (context) => const LoginView(),
        '/infos': (context) => const Infos(),
        '/settings': (context) => const Settings(),
      }
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key, required this.title}) : super(key: key);

  // final liseEvents = [
  //   {"id": "64852304", "title": "CH_Amphi_2 - 08:00 - 10:00 - EEA_CEE - CM - GILLOT Cyrille - 2h00 -  - 5GIE CM", "start": "2021-09-20T08:00:00+0200", "end": "2021-09-20T10:00:00+0200", "allDay": false, "editable": true, "className": "CM"},
  //   {"id": "64852219", "title": "CH_Amphi_2 - 11:00 - 12:00 - Mécanique des Fluides Energétique  - CM - DEMIRCI Ibrahim - 1h00 -  - 5GIE CM", "start": "2021-09-20T11:00:00+0200", "end": "2021-09-20T12:00:00+0200", "allDay": false, "editable": true, "className": "CM"},
  //   {"id": "64851348", "title": "CH_Grand_Amphi_Alfred_CHABAUD - 14:30 - 15:30 - Avant Projet - CM - PERINET Jean-Marc - 1h00 -  - 5GIE CM", "start": "2021-09-20T14:30:00+0200", "end": "2021-09-20T15:30:00+0200", "allDay": false, "editable": true, "className": "CM"},
  //   {"id": "64852333", "title": "CH_Amphi_1 - 15:30 - 17:30 - EEA_CEE - CM - BLANKS Jeremy - 2h00 -  - 5GIE CM", "start": "2021-09-20T15:30:00+0200", "end": "2021-09-20T17:30:00+0200", "allDay": false, "editable": true, "className": "CM"},
  //   {"id": "67956163", "title": "CH_Grand_Amphi_Alfred_CHABAUD - 17:30 - 18:30 - Mise à niveau Construction - REUNION - PERINET Jean-Marc - 1h00 -  - 5GIE CM \/ 5GIM CM \/ S5 MISE A NIVEAU PSI", "start": "2021-09-20T17:30:00+0200", "end": "2021-09-20T18:30:00+0200", "allDay": false, "editable": true, "className": "REUNION"},
  //   {"id": "62913745", "title": "CH_Grand_Amphi_Alfred_CHABAUD - 08:00 - 10:00 - Mise à niveau Construction - MISSION - PERINET Jean-Marc - 2h00 -  - 5GIE CM \/ 5GIM CM \/ S5 MISE A NIVEAU PSI", "start": "2021-09-21T08:00:00+0200", "end": "2021-09-21T10:00:00+0200", "allDay": false, "editable": true, "className": "MISSION"},
  //   {"id": "64141813", "title": "CH_Amphi_1 - 10:00 - 12:00 - Informatique - CM - DEMIRCI Ibrahim - 2h00 -  - 5GIE CM", "start": "2021-09-21T10:00:00+0200", "end": "2021-09-21T12:00:00+0200", "allDay": false, "editable": true, "className": "CM"},
  //   {"id": "64852529", "title": "CH_02 - 13:30 - 15:30 - Mécanique des Fluides Energétique  - ED_TD - ISSELIN Jérôme - 2h00 -  - 5GIE ED3", "start": "2021-09-21T13:30:00+0200", "end": "2021-09-21T15:30:00+0200", "allDay": false, "editable": true, "className": "ED_TD"},
  //   {"id": "64852389", "title": "CH_25 - 15:30 - 17:30 - Transferts Thermiques Energétique  - ED_TD - DEMIRCI Ibrahim - 2h00 -  - 5GIE ED3", "start": "2021-09-21T15:30:00+0200", "end": "2021-09-21T17:30:00+0200", "allDay": false, "editable": true, "className": "ED_TD"},
  //   {"id": "65704626", "title": "CH_BE3 - 08:00 - 10:00 - Conception Concevoir Système - ED_TD - PERINET Jean-Marc - 2h00 -  - 5GIE ED3", "start": "2021-09-22T08:00:00+0200", "end": "2021-09-22T10:00:00+0200", "allDay": false, "editable": true, "className": "ED_TD"},
  //   {"id": "64852361", "title": "CH_Amphi_2 - 10:00 - 12:00 - EEA_CEE - CM - CHERIFI Abdelmadjid - 2h00 -  - 5GIE CM", "start": "2021-09-22T10:00:00+0200", "end": "2021-09-22T12:00:00+0200", "allDay": false, "editable": true, "className": "CM"},
  //   {"id": "61724524", "title": "CH_A2 - 13:30 - 15:30 - 1A LV2 All A1 A2 WASKOWIAK Jean-Pierre - ED_TD - WASKOWIAK Jean-Pierre - 2h00 -  - 5GIE CM \/ 5GIM CM \/ S5 LV2 All A1A2 WASKOWIAK", "start": "2021-09-22T13:30:00+0200", "end": "2021-09-22T15:30:00+0200", "allDay": false, "editable": true, "className": "ED_TD"},
  //   {"id": "64852557", "title": "CH_Amphi_2 - 15:30 - 17:30 - Usinage Réaliser Système - CM - CHEGDANI Faissal - 2h00 -  - 5GIE CM", "start": "2021-09-22T15:30:00+0200", "end": "2021-09-22T17:30:00+0200", "allDay": false, "editable": true, "className": "CM"},
  //   {"id": "61148492", "title": "CH_Grand_Amphi_Alfred_CHABAUD - 08:00 - 17:30 -  - REUNION - BLANKS Jeremy - 9h30 - JOURNEE ENTREPREUNARIAT - 5GIE CM \/ 5GIM CM", "start": "2021-09-23T08:00:00+0200", "end": "2021-09-23T17:30:00+0200", "allDay": false, "editable": true, "className": "REUNION"},
  //   {"id": "64852890", "title": "CH_MOTEURS - 10:00 - 12:00 - EEA_CEE - ED_TD - BLANKS Jeremy - 2h00 -  - 5GIE ED3", "start": "2021-09-24T10:00:00+0200", "end": "2021-09-24T12:00:00+0200", "allDay": false, "editable": true, "className": "ED_TD"},
  //   {"id": "64852698", "title": "CH_Labo_Automatisme \/ CH_Labo_Electrotechnique - 13:30 - 17:30 - EEA_CEE - TPS - CAUSSY Mohunparsad \/ GILLOT Cyrille \/ LAURENT Eric - 4h00 -  - 5GIE TP31 ", "start": "2021-09-24T13:30:00+0200", "end": "2021-09-24T17:30:00+0200", "allDay": false, "editable": true, "className": "TPS"}
  // ];
  final String title;

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  final Calendar calendar = Calendar();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: calendar),
    );
  }
}