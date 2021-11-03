import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:am_calendar/helpers/snackbar.dart';

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
  String userId = '';
  String password = '';
  String nums = '';
  String proms = '';
  String tbk = "Chalon's";
  bool showPals = false;
  SharedPreferences? prefs;

  static const List<String> TBKList = ["Chalon's", "Siber's", "Boquette", "Birse", "Paris", "KIN", "Bordel's", "Clun's"];

  @override
  void initState() {
    super.initState();
    initSharedPreferences().whenComplete(() => setState(() {
          tbk = prefs!.getString('tbk') ?? 'Chalon\'s';
          userIdFieldController.text = prefs?.getString('id') ?? '2021-';
          passwordFieldController.text = prefs?.getString('password') ?? '';
        }));
  }

  Future<void> initSharedPreferences() async => prefs = await SharedPreferences.getInstance();

  void checkNums(BuildContext context) {
    if (nums == '' || proms == '') return;
    if (proms == '220') {
      switch (int.tryParse(nums)) {
        case 53:
          return showSnackBar(context, 'OuinOuin');
        case 58:
          return showSnackBar(context, 'Il s\'agirait d\'avoir le matos');
        case 74:
          return showSnackBar(context, 'Il s\'agirait de courir plus vite le matin dans le pal\'s');
        case 16:
        case 108:
          showDialog(barrierDismissible: false, context: context, builder: (_) => AlertDialog(content: Text('C\'est clairement zocké pour toi')));
          Future.delayed(const Duration(milliseconds: 500), () => throw ErrorHint('Num\'s de shaymen'));
          break;
        case 139:
          return showSnackBar(context, 'Ca va t\'es cool avec le seau ?');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
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
                        validator: (id) => (id ?? '').isEmpty ? 'Il faut remplir votre identifiant' : null,
                        textInputAction: TextInputAction.next,
                        onChanged: (id) => setState(() => userId = id),
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
                        validator: (pswd) => (pswd ?? '').isEmpty ? 'Il faut remplir votre mot de passe' : null,
                        textInputAction: TextInputAction.next,
                        onChanged: (pswd) => setState(() => password = pswd),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.location_city),
                          hintText: 'Choisissez votre TBK',
                          labelText: 'TBK',
                          border: const UnderlineInputBorder(borderSide: BorderSide(color: VIOLET)),
                        ),
                        value: tbk,
                        icon: const Icon(Icons.arrow_downward, color: VIOLET),
                        iconSize: 16,
                        elevation: 16,
                        style: const TextStyle(color: VIOLET),
                        onChanged: (value) => setState(() {
                          tbk = value!;
                          prefs?.setString(tbk, value);
                        }),
                        items: TBKList.map((value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
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
                                    textAlign: TextAlign.right,
                                    onChanged: (value) {
                                      setState(() => nums = value);
                                      checkNums(context);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
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
                                    initialValue: proms,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.left,
                                    onChanged: (value) {
                                      setState(() => proms = value);
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
                                    showPals = value!;
                                    prefs?.setBool('showPals', value);
                                  });
                                }),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: ElevatedButton(
                        child: const Text('Sauvegarder'),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            prefs?.setString('id', userId);
                            prefs?.setString('password', password);
                            showSnackBar(context, 'Les paramètres ont bien été enregistrés');
                          }
                        },
                      ),
                    )
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
