import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart' show eventBus;
import '../helpers/app-events.dart';

const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);
const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController userIdFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();
  final TextEditingController numsFieldController = TextEditingController();
  final TextEditingController promsFieldController = TextEditingController();
  String userId = '';
  String password = '';
  String nums = '';
  String proms = '';
  String tbk = "Chalon's";
  SharedPreferences? prefs;

  static const List<String> TBKList = ["Chalon's", "Siber's", "Boquette", "Birse", "Paris", "KIN", "Bordel's", "Clun's"];

  bool get showPals => prefs?.getBool('showPals') ?? false;

  @override
  void initState() {
    super.initState();
    initSharedPreferences().whenComplete(() => setState(() {
          tbk = prefs!.getString('tbk') ?? 'Chalon\'s';
          userIdFieldController.text = prefs!.getString('id') ?? '2021-';
          numsFieldController.text = prefs!.getString('nums') ?? '';
          promsFieldController.text = prefs!.getString('proms') ?? '';
        }));
  }

  Future<void> initSharedPreferences() async => prefs = await SharedPreferences.getInstance();

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
    } else if (proms == '221') {
      switch (int.tryParse(nums)) {
        case 41:
        case 69:
        case 88:
        case 106:
        case 133:
          prefs?.setString('startupSound', 'true');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: VIOLET,
        title: const Text('Paramètres'),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(primaryColor: VIOLET),
        child: Form(
          key: formKey,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * .8,
              padding: const EdgeInsets.all(16.0),
              child: Theme(
                data: ThemeData(
                  colorScheme: ThemeData().colorScheme.copyWith(
                        primary: VIOLET,
                        secondary: VIOLET,
                      ),
                ),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.perm_identity),
                          hintText: 'Entrez votre identifiant LISE',
                          labelText: 'Identifiant LISE',
                          border: const OutlineInputBorder(borderSide: BorderSide(color: VIOLET)),
                        ),
                        cursorColor: VIOLET,
                        inputFormatters: [LengthLimitingTextInputFormatter(9)],
                        controller: userIdFieldController,
                        textInputAction: TextInputAction.next,
                        onChanged: (id) => setState(() {
                          prefs?.setString('id', userId);
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
                          border: const OutlineInputBorder(borderSide: BorderSide(color: VIOLET)),
                        ),
                        cursorColor: VIOLET,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: passwordFieldController,
                        textInputAction: TextInputAction.next,
                        onChanged: (pswd) => setState(() {
                          password = pswd;
                          prefs?.setString('password', pswd);
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
                          border: const OutlineInputBorder(borderSide: BorderSide(color: VIOLET)),
                        ),
                        value: tbk,
                        icon: const Icon(Icons.arrow_downward, color: VIOLET),
                        iconSize: 16,
                        elevation: 16,
                        style: const TextStyle(color: VIOLET),
                        onChanged: (value) => setState(() {
                          tbk = value!;
                          prefs?.setString('tbk', value);
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
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.looks_one_outlined),
                                      alignLabelWithHint: true,
                                      labelText: 'Num\'s',
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: numsFieldController,
                                    textAlign: TextAlign.right,
                                    onChanged: (value) {
                                      setState(() => nums = value);
                                      prefs?.setString('nums', value);
                                      checkNums(context);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(2.0, 2.0, 4.0, 2.0),
                                  child: Text(
                                    'Ch',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Flexible(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      alignLabelWithHint: true,
                                      labelText: 'Prom\'s',
                                      border: InputBorder.none,
                                    ),
                                    controller: promsFieldController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.left,
                                    onChanged: (value) {
                                      setState(() => proms = value);
                                      prefs?.setString('proms', value);
                                      checkNums(context);
                                    },
                                  ),
                                )
                              ],
                            ),
                            CheckboxListTile(
                                title: Text(
                                  'Afficher les pal\'s',
                                  textAlign: TextAlign.left,
                                ),
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.all(0),
                                value: showPals,
                                activeColor: VIOLET,
                                onChanged: (value) {
                                  setState(() {
                                    prefs?.setBool('showPals', value!);
                                    eventBus.fire(ReloadViewEvent());
                                  });
                                }),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          child: Text('Exporter vers Google Calendar'),
                          onPressed: () => eventBus.fire(ExportCalendarEvent()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
