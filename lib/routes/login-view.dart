import 'package:am_calendar/helpers/refresh-indicator.dart';
import 'package:am_calendar/helpers/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart' show eventBus;
import '../helpers/app-events.dart';
import '../headless-login.dart';
import '../helpers/snackbar.dart';

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
  final TextEditingController passwordFieldController = TextEditingController();
  late SharedPreferences prefs = widget.prefs;
  late PackageInfo packageInfo = PackageInfo(appName: '', packageName: '', version: '', buildNumber: '');
  String userId = '';
  String password = '';
  DataSource source = defaultSource;
  bool isLoading = false;
  bool hasError = false;
  String connectionText = '';

  @override
  void initState() {
    super.initState();
    userIdFieldController.text = prefs.getString('id') ?? '2021-';
    passwordFieldController.text = prefs.getString('password') ?? '';
    userId = prefs.getString('id') ?? '2021-';
    password = prefs.getString('password') ?? '';
    source = getDataSourcefromPrefs(prefs);
    initPackageInfo();
  }

  Future<void> initPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  void webLoginCallback() => Navigator.of(context).pushNamed('/web-login');

  void debugCallback() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Login Debug'),
        contentPadding: const EdgeInsets.all(12.0),
        children: [
          Text('ID : ' + (prefs.getString('id') ?? '')),
          Text('Password : ' + (prefs.getString('password') ?? '')),
        ],
      ),
    );
  }

  void connectToEnsamCampus(BuildContext context) {
    if (userId == 'web-login') return webLoginCallback();
    else if (userId == 'debug') return debugCallback();
    prefs.setString('id', userId);
    prefs.setString('password', password);
    if (formKey.currentState!.validate()) {
      if (isLoading) {
        setState(() {
          isLoading = false;
          connectionText = '';
        });
        return;
      }
      setState(() {
        hasError = false;
        isLoading = true;
      });
      HeadlessLogin()..login();
      showSnackBar(context, 'Connexion en cours');
      eventBus.on<LoginEvent>().listen((event) {
        if (hasError) return;
        if (event.finished ?? false) Navigator.of(context).pushNamed('/calendar');
        if (event.error ?? false)
          setState(() {
            isLoading = false;
            hasError = true;
          });
        setState(() => connectionText = event.text + '...');
      });
    }
  }

  void connectToIcal(BuildContext context) {
    // TODO: regex check
    prefs.setString('id', userId);
    Navigator.of(context).pushNamed('/calendar');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color primaryColor = isDarkMode ? ORANGE : VIOLET;
    final Color textColor = isDarkMode ? Colors.white60 : Colors.black;

    List<Widget> formChildren = [
      Transform.translate(
        offset: const Offset(-12.0, 0.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<DataSource>(
            decoration: const InputDecoration(
              icon: Icon(Icons.source),
              hintText: 'Source des données',
              labelText: 'Source',
              border: OutlineInputBorder(),
            ),
            value: source,
            icon: Icon(Icons.arrow_downward, color: primaryColor),
            iconSize: 16,
            elevation: 16,
            style: TextStyle(color: primaryColor),
            onChanged: (value) => setState(() {
              prefs.setString('source', value!.name);
              setState(() => source = value);
            }),
            items: DataSource.values
                .map((value) => DropdownMenuItem<DataSource>(value: value, child: InkWell(child: Text(value.name))))
                .toList(),
          ),
        ),
      ),
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
            inputFormatters: [LengthLimitingTextInputFormatter(9)],
            controller: userIdFieldController,
            textInputAction: TextInputAction.next,
            onChanged: (id) => setState(() {
              userId = id.trim();
              if (userId == 'web-login')
                webLoginCallback();
              else if (userId == 'debug') debugCallback();
            }),
          ),
        ),
      ),
      if (source == DataSource.EnsamCampus || source == DataSource.All) Transform.translate(
        offset: const Offset(-12.0, 0.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.password),
              hintText: 'Entrez votre mot de passe',
              labelText: 'Mot de passe',
              border: const OutlineInputBorder(),
            ),
            cursorColor: primaryColor,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            controller: passwordFieldController,
            textInputAction: TextInputAction.next,
            onChanged: (pswd) => setState(() {
              password = pswd;
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
            if (source == DataSource.EnsamCampus || source == DataSource.All) connectToEnsamCampus(context);
            else if (source == DataSource.ICal) connectToIcal(context);
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Text(
            connectionText,
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
                // inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderSide: BorderSide(color: VIOLET))),
              ),
              child: Form(
                key: formKey,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * .85,
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: formChildren,
                    ),
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
