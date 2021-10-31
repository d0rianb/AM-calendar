import 'package:am_calendar/routes/login-webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);
const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);

class LoginForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();
  String userId = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Se connecter'),
        automaticallyImplyLeading: false,
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
                          hintText: 'Entrez votre identifiant',
                          labelText: 'Identifiant',
                          border: const OutlineInputBorder(borderSide: BorderSide(color: VIOLET)),
                        ),
                        cursorColor: VIOLET,
                        inputFormatters: [LengthLimitingTextInputFormatter(9)],
                        initialValue: '2021-',
                        validator: (id) => (id ?? '').isEmpty ? 'Il faut remplir votre identifiant': null,
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                        onSaved: (id) => setState(() => userId = id!),
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
                        initialValue: '',
                        validator: (pswd) => (pswd ?? '').isEmpty ? 'Il faut remplir votre mot de passe': null,
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                        onSaved: (pswd) => setState(() => password = pswd!),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.all(18.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          // TODO: get cookie and save infos
                          // HeadlessBrowser.getSecureCookie('2021-0698', 'test');
                          SharedPreferences
                              .getInstance()
                              .then((prefs) {
                                  prefs.setString('id', userId);
                                  prefs.setString('password', password);
                          });
                          Navigator.of(context).push(new MaterialPageRoute(builder: (context) => LoginWebView()));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Connection en cours ...'),
                                  elevation: 2.0,
                                  behavior: SnackBarBehavior.floating,
                              )
                          );
                        }
                      },
                      child: const Text('Connection'),
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