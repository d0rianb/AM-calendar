import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/cache-handler.dart';
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
  final formKey = GlobalKey<FormState>();
  final TextEditingController userIdFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();
  final TextEditingController numsFieldController = TextEditingController();
  final TextEditingController promsFieldController = TextEditingController();
  final TextEditingController filtersFieldController = TextEditingController();
  late SharedPreferences prefs;
  String userId = '';
  String password = '';
  String nums = '';
  String proms = '';
  String tbk = "Chalon's";
  String brightness = 'system';
  String filters = '';

  static const List<String> TBKList = ["Chalon's", "Siber's", "Boquette", "Birse", "Paris", "KIN", "Bordel's", "Clun's"];

  bool get showPals => prefs.getBool('showPals') ?? false;

  @override
  void initState() {
    super.initState();
    prefs = widget.prefs;
    tbk = prefs.getString('tbk') ?? 'Chalon\'s';
    brightness = prefs.getString('brightness') ?? 'system';
    userIdFieldController.text = prefs.getString('id') ?? '2021-';
    numsFieldController.text = prefs.getString('nums') ?? '';
    promsFieldController.text = prefs.getString('proms') ?? '';
    filtersFieldController.text = prefs.getString('filters') ?? '';
    eventBus.on<DeleteAllCacheEvent>().listen((event) {
      setState(() => clearAllCache(prefs));
    });
  }

  void checkNums(BuildContext context) {
    if (nums == '' || proms == '') return;
    if (proms == '220') {
      switch (int.tryParse(nums)) {
        case 16:
        case 108:
          showDialog(barrierDismissible: false, context: context, builder: (_) => AlertDialog(content: Text('C\'est clairement zocké pour toi')));
          Future.delayed(const Duration(milliseconds: 500), () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'));
          break;
      }
    }
  }

  ThemeMode getThemeModefromValue(String value) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: BackButton(color: theme.appBarTheme.foregroundColor),
      ),
      body: Theme(
        data: theme.copyWith(
          primaryColor: primaryColor,
          inputDecorationTheme: InputDecorationTheme(
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
                      inputFormatters: [LengthLimitingTextInputFormatter(9)],
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
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.password),
                        hintText: 'Entrez votre mot de passe',
                        labelText: 'Mot de passe',
                        border: OutlineInputBorder(),
                      ),
                      cursorColor: primaryColor,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: passwordFieldController,
                      textInputAction: TextInputAction.next,
                      onChanged: (pswd) => setState(() {
                        password = pswd;
                        prefs.setString('password', pswd);
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
                        prefs.setString('tbk', value);
                      }),
                      items: TBKList.map((value) => DropdownMenuItem<String>(value: value, child: InkWell(child: Text(value)))).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                    child: Visibility(
                      visible: tbk == 'Chalon\'s',
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Flexible(
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      alignLabelWithHint: true,
                                      labelText: 'Num\'s',
                                      isDense: true,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: numsFieldController,
                                    textAlign: TextAlign.right,
                                    onChanged: (value) {
                                      setState(() => nums = value);
                                      prefs.setString('nums', value);
                                      checkNums(context);
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(2.0, 2.0, 4.0, 2.0),
                                child: Text(
                                  'Ch',
                                  style: TextStyle(fontSize: 18, color: theme.textTheme.subtitle2?.color),
                                ),
                              ),
                              Flexible(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    alignLabelWithHint: true,
                                    labelText: 'Prom\'s',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                  ),
                                  controller: promsFieldController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.left,
                                  onChanged: (value) {
                                    setState(() => proms = value);
                                    prefs.setString('proms', value);
                                    checkNums(context);
                                  },
                                ),
                              )
                            ],
                          ),
                          CheckboxListTile(
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
                        ],
                      ),
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
                        eventBus.fire(ThemeChangeEvent(getThemeModefromValue(value)));
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
                      onPressed: () => eventBus.fire(DeleteAllCacheEvent()),
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
