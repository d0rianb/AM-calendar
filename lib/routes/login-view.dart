import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../reload-view-event.dart';
import '../headless-login.dart';
import '../helpers/snackbar.dart';

const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);
const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController userIdFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();
  String userId = '';
  String password = '';
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    initSharedPreferences().whenComplete(() => setState(() {
          userIdFieldController.text = prefs!.getString('id') ?? '2021-';
          passwordFieldController.text = prefs!.getString('password') ?? '';
        }));
  }

  Future<void> initSharedPreferences() async => prefs = await SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Connection'),
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
                          userId = id;
                          prefs?.setString('id', userId);
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
                      padding: const EdgeInsets.all(18.0),
                      child: ElevatedButton(
                        child: const Text('Se connecter'),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            HeadlessLogin loginInstance = HeadlessLogin()..login(context);
                            showSnackBar(context, 'Connection en cours');
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
