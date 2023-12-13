import 'dart:async';

import 'package:am_calendar/helpers/refresh-indicator.dart';
import 'package:am_calendar/helpers/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../cache.dart';
import '../events/calendar-event.dart';
import '../main.dart' show eventBus;
import '../helpers/app-events.dart';
import '../week.dart';

const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);
const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);

class LoginView extends StatefulWidget {
  final SharedPreferences prefs;

  LoginView({Key? key, required this.prefs}) : super(key: key);

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController userIdFieldController = TextEditingController();
  late SharedPreferences prefs = widget.prefs;
  late PackageInfo packageInfo = PackageInfo(appName: '', packageName: '', version: '', buildNumber: '');

  StreamSubscription? loginEventStream;
  StreamSubscription? requestErrorEventStream;

  String userId = '';
  bool isLoading = false;
  bool hasError = false;
  String connectionText = '';
  JSON iCalResponse = {}; // Cache the iCal response used to check the validity of the id

  static RegExp idRegexp = RegExp(r'^\d{4}-\d{4}$');

  @override
  void initState() {
    super.initState();
    userId = prefs.getString('id') ?? '2021-';
    userIdFieldController.text = userId;
    initPackageInfo();
  }

  @override
  void dispose() {
    // Call destructors
    disposeStreams();
    super.dispose();
  }

  Future<void> initPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  /// Init the event listeners
  void initStreams() {
    if (loginEventStream == null) {
      loginEventStream = eventBus.on<LoginEvent>().listen((event) {
        if (hasError || !mounted) return;
        setState(() => connectionText = event.text + ' ...');
        if (event.finished) launchCalendar();
      });
    }

    if (requestErrorEventStream == null) {
      requestErrorEventStream = eventBus.on<RequestErrorEvent>().listen((event) {
        if (hasError || !mounted) return;
        setState(() {
          isLoading = false;
          hasError = true;
          connectionText = event.text;
        });
      });
    }
  }

  void disposeStreams() async {
    await loginEventStream?.cancel();
    loginEventStream = null;
    await requestErrorEventStream?.cancel();
    requestErrorEventStream = null;
  }

  // Cancel a request
  void cancel() async {
    disposeStreams();
    connectionText = '';
    setState(() => isLoading = false);
  }

  void connectToICal(BuildContext context) async {
    initStreams();
    prefs.setString('id', userId);
    setState(() => isLoading = true);
    iCalResponse = await ICalRequest.getCalendar();
  }

  void launchCalendar() async {
    // Set cached events and load the calendar view
    setState(() => isLoading = false);
    if (iCalResponse.isEmpty || iCalResponse['data']?.length == 0) {
      eventBus.fire(RequestErrorEvent('Identifiant incorrect, pas de données reçues'));
      return;
    }
    final List<CalendarEvent> events = List.from(iCalResponse['data'].map((e) => CalendarEvent.fromICal(e)));
    Week week = Week.fromDateTime(DateTime.now());
    final Cache cache = Cache.create(week.stringId, events);
    prefs.setString(cache.id, cache.serialized);
    Navigator.of(context).pushNamedAndRemoveUntil('/calendar', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color primaryColor = isDarkMode ? ORANGE : VIOLET;
    final Color textColor = isDarkMode ? Colors.white60 : Colors.black;

    const double imageAspectRatio = 471 / 599;

    List<Widget> formChildren = [
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Hero(
          tag: 'am_logo',
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.width / 3 / imageAspectRatio,
            child: const Image(image: AssetImage('resources/icons/am-logo.png')),
          ),
        ),
      ),
      const SizedBox(height: 30.0),  // Separator
      Transform.translate(
        offset: const Offset(-12.0, 0.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.perm_identity),
              hintText: 'Entrez votre identifiant LISE',
              labelText: 'Identifiant LISE',
              border: const OutlineInputBorder(),
            ),
            cursorColor: primaryColor,
            keyboardType: TextInputType.number,
            inputFormatters: [LengthLimitingTextInputFormatter(9)],
            validator: (value) {
              if (value == null || value.isEmpty || !idRegexp.hasMatch(value)) {
                return 'L\'identifiant doit être de la forme : 202X-XXXX';
              } else {
                return null;
              }
            },
            controller: userIdFieldController,
            textInputAction: TextInputAction.next,
            onChanged: (id) => setState(() {
              userId = id.trim();
            }),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 55.0),
        child: OutlinedButton(
          child: Text(!isLoading ? 'Se connecter' : 'Annuler'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(width: 1.5, color: primaryColor),
          ),
          onPressed: () {
            hasError = false;
            // Unfocus keyboard
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            if (isLoading) {
              cancel();
            } else if (formKey.currentState!.validate()) {
              connectToICal(context);
            }
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Text(
            connectionText,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: !hasError ? theme.textTheme.titleMedium?.color : Colors.red[800],
            ),
          ),
        ),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        automaticallyImplyLeading: false,
        backgroundColor: VIOLET,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Stack(
          children: [
            Theme(
              data: theme.copyWith(
                primaryColor: primaryColor,
                inputDecorationTheme: InputDecorationTheme(
                  floatingLabelStyle: TextStyle(color: textColor),
                  labelStyle: TextStyle(color: textColor),
                  helperStyle: TextStyle(color: textColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.white24 : Colors.grey,
                    ),
                  ),
                ),
                colorScheme: theme.colorScheme.copyWith(
                  primary: primaryColor,
                ),
              ),
              child:
                Center(
                  child: Form(
                    key: formKey,
                    child: Container(
                      width: MediaQuery.of(context).size.width * .85,
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(children: formChildren),
                    ),
                  ),
              ),
            ),
            Visibility(
              visible: isLoading,
              child: Positioned(
                top: 30,
                left: MediaQuery.of(context).size.width / 2 - 25,
                width: 50,
                height: 50,
                child: const ShadowedRefreshIndicator(color: VIOLET),
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
              '${packageInfo.appName} -  v${packageInfo.version}',
              style: TextStyle(color: Colors.grey[500], backgroundColor: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}
