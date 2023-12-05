import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/cache-handler.dart';
import '../helpers/snackbar.dart';
import '../main.dart' show eventBus;
import '../helpers/app-events.dart';

const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);
const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);

class Settings extends StatefulWidget {
  final SharedPreferences prefs;

  const Settings({Key? key, required this.prefs}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  late SharedPreferences prefs;
  final formKey = GlobalKey<FormState>();
  final TextEditingController userIdFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();
  final TextEditingController numsFieldController = TextEditingController();
  final TextEditingController promsFieldController = TextEditingController();
  final TextEditingController filtersFieldController = TextEditingController();
  String userId = '';
  String tbk = "Chalon's";
  String brightness = 'system';
  String filters = '';

  static const List<String> TBKList = ["Chalon's", "Siber's", "Boquette", "Birse", "Paris", "KIN", "Bordel's", "Clun's"];
  static RegExp idRegexp = RegExp(r'^\d{4}-\d{4}$');


  bool get showPals => prefs.getBool('showPals') ?? false;

  @override
  void initState() {
    super.initState();
    prefs = widget.prefs;
    tbk = prefs.getString('tbk') ?? "Chalon's";
    brightness = prefs.getString('brightness') ?? 'system';
    userIdFieldController.text = prefs.getString('id') ?? '2021-';
    filtersFieldController.text = prefs.getString('filters') ?? '';
    eventBus.on<DeleteAllCacheEvent>().listen((event) {
      setState(() => clearAllCache(prefs));
    });
  }

  ThemeMode getThemeModeFromValue(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color primaryColor = isDarkMode ? ORANGE : VIOLET;
    final Color textColor = isDarkMode ? Colors.white60 : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: BackButton(color: theme.appBarTheme.foregroundColor),
      ),
      body: Theme(
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
        child: Form(
          key: formKey,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * .8,
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.perm_identity),
                        hintText: 'Entrez votre identifiant LISE',
                        labelText: 'Identifiant LISE',
                        border: OutlineInputBorder(),
                      ),
                      cursorColor: primaryColor,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(9)],
                      validator: (value) {
                        if (value  == null || value.isEmpty || !idRegexp.hasMatch(value)) {
                          return 'L\'identifiant doit être de la forme : 202X-XXXX';
                        } else {
                          return null;
                        }
                      },
                      controller: userIdFieldController,
                      textInputAction: TextInputAction.next,
                      onChanged: (id) => setState(() {
                        prefs.setString('id', id);
                        userId = id;
                      }),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.location_city),
                        hintText: 'Choisissez votre TBK',
                        labelText: 'TBK',
                        border: OutlineInputBorder(),
                      ),
                      value: tbk,
                      icon: Icon(Icons.arrow_downward, color: primaryColor),
                      iconSize: 16,
                      elevation: 16,
                      style: TextStyle(color: primaryColor),
                      onChanged: (value) => setState(() {
                        tbk = value!;
                        if (tbk != "Chalon's") prefs.setBool('showPals', false);
                        prefs.setString('tbk', value);
                      }),
                      items: TBKList.map((value) => DropdownMenuItem<String>(value: value, child: InkWell(child: Text(value)))).toList(),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                    child: Visibility(
                      visible: tbk == "Chalon's",
                      child: CheckboxListTile(
                          title: const Text(
                            'Afficher les pal\'s',
                            textAlign: TextAlign.left,
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.all(0),
                          value: showPals,
                          activeColor: primaryColor,
                          onChanged: (value) {
                            setState(() {
                              prefs.setBool('showPals', value!);
                              eventBus.fire(ReloadViewEvent());
                            });
                          }),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                        hintText: 'Thème de l\'application',
                        labelText: 'Thème',
                        border: OutlineInputBorder(),
                      ),
                      value: brightness,
                      icon: Icon(Icons.arrow_downward, color: primaryColor),
                      iconSize: 16,
                      elevation: 16,
                      style: TextStyle(color: primaryColor),
                      onChanged: (value) => setState(() {
                        brightness = value!;
                        prefs.setString('brightness', value);
                        eventBus.fire(ThemeChangeEvent(getThemeModeFromValue(value)));
                      }),
                      items: const [
                        DropdownMenuItem<String>(value: 'light', child: InkWell(child: Text('Clair'))),
                        DropdownMenuItem<String>(value: 'dark', child: InkWell(child: Text('Foncé'))),
                        DropdownMenuItem<String>(value: 'system', child: InkWell(child: Text('Automatique'))),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.filter_alt),
                        hintText: 'Filtres',
                        labelText: 'Filtres',
                        suffixIcon: Tooltip(
                          message: "Les cours contenant le texte d\'un des filtres ne seront pas affichés. Les filtres sont séparés par des virgules, et ne sont pas sensibles à la casse.",
                          triggerMode: TooltipTriggerMode.tap,
                          preferBelow: false,
                          waitDuration: Duration(microseconds: 0),
                          showDuration: Duration(seconds: 2),
                          child: Icon(Icons.info_outline),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      cursorColor: primaryColor,
                      controller: filtersFieldController,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) => setState(() {
                        prefs.setString('filters', value);
                        filters = value;
                        eventBus.fire(ReloadViewEvent());
                      }),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                      child: const Text('Vider le cache'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 1.5, color: primaryColor),
                      ),
                      onPressed: () async {
                        eventBus.fire(DeleteAllCacheEvent());
                        clearAllCache(prefs);
                        Navigator.of(context).pushNamed('/login');
                        showSnackBar(context, 'Le cache à bien été vidé');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
