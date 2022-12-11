import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app-events.dart';
import '../main.dart' show eventBus;

const String initialUrl = 'https://ensam.campusm.exlibrisgroup.com/campusm/cmauth/login/5313';
const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);
const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);

const Map<String, String> JSPath = {
  'username': '#username',
  'password': '#password',
  'submit': '#fm1 > section.row.btn-row > input.btn.btn-submit.btn-block',
  'login-form': '#fm1',
  'etudiant-personnel': '#mOdAl_1_body > div > div.listview > ul > li:nth-child(1) > a',
};

class HeadlessLogin {
  static final CookieManager cookieManager = CookieManager.instance();
  late HeadlessInAppWebView headlessWebView;
  late InAppWebViewController webViewController;
  late SharedPreferences prefs;
  int urlCount = 0;

  static Future click(InAppWebViewController controller, String JSpathIndex) async {
    return controller.evaluateJavascript(source: '''
      document.querySelector('${JSPath[JSpathIndex]}')?.click()
      ''');
  }

  static Future fillField(InAppWebViewController controller, String JSpathIndex, String value) async {
    return controller.evaluateJavascript(source: '''
      document.querySelector('${JSPath[JSpathIndex]}').value = String.raw`$value`
      ''');
  }

  static Future submit(InAppWebViewController controller, String JSpathIndex) async {
    return controller.evaluateJavascript(source: '''
      let form = document.querySelector('${JSPath[JSpathIndex]}')
      let button = document.querySelector('${JSPath['submit']}')
      if (form && button) {
        if (form.requestSubmit) form.requestSubmit(button)
        else {
          button.disabled = false
          button.click()
        }
      }
      ''');
  }

  static Future getInputValue(InAppWebViewController controller, String JSpathIndex) async {
    return controller.evaluateJavascript(source: '''document.querySelector('${JSPath[JSpathIndex]}').value''');
  }

  void login() async {
    eventBus.fire(LoginEvent('Initialisation de la connection'));
    HeadlessInAppWebView headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          incognito: true,
        ),
        android: AndroidInAppWebViewOptions(useHybridComposition: true),
        ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
      ),
      onWebViewCreated: (controller) async {
        prefs = await SharedPreferences.getInstance();
        webViewController = controller;
        eventBus.fire(LoginEvent('Création de la vue Web'));
      },
      onLoadStart: (controller, url) => eventBus.fire(LoginEvent('Chargement de l\'interface CAS')),
      androidOnPermissionRequest: (controller, origin, resources) async => PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT),
      shouldOverrideUrlLoading: (controller, navigationAction) async => NavigationActionPolicy.ALLOW,
      onLoadStop: (controller, url) async {
        eventBus.fire(LoginEvent('Connexion au serveur'));
        if (url.toString().startsWith('https://auth.ensam.eu/cas/login?')) {
          if (++urlCount > 4) return; // To prevent DDOS & account blocking
          controller.evaluateJavascript(source: '''document.querySelector('input[name="continue"]').click()'''); // To solve the change password popup issue
          if (prefs.getString('id') == null || prefs.getString('id')!.isEmpty) return error('Identifiant incorrect');
          if (prefs.getString('password') == null || prefs.getString('password')!.isEmpty) return error('Mot de passe incorrect');
          fillField(controller, 'username', prefs.getString('id')!);
          fillField(controller, 'password', prefs.getString('password')!);
          submit(controller, 'login-form');
          eventBus.fire(LoginEvent('Envoi des données au server'));
        }
        if (url.toString() == 'https://ensam.campusm.exlibrisgroup.com/cmauth/saml/sso') {
          final List<Cookie> cookies = await cookieManager.getCookies(url: Uri.parse('https://ensam.campusm.exlibrisgroup.com'));
          final int cmAuthTokenIndex = cookies.indexWhere((cookie) => cookie.name == 'cmAuthToken');
          eventBus.fire(LoginEvent('Réception des informations de connections'));
          if (cmAuthTokenIndex > -1) {
            prefs.setString('cmAuthToken', cookies[cmAuthTokenIndex].value);
            eventBus.fire(LoginEvent('Connexion réussie', finished: true));
          } else {
            error('Pas de cookie détecté.');
          }
        }
      },
      onLoadHttpError: (controller, url, code, message) {
        if (code == 401) error('Identifiant ou mot de passe incorrect');
        print('HTTP error $code : $message');
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {},
      onConsoleMessage: (controller, consoleMessage) => print('[Embedded console] : $consoleMessage'),
    );
    await headlessWebView.run();
  }

  void error([String? reason]) {
    eventBus.fire(LoginEvent('Erreur de connection : $reason', error: true));
    throw 'Error : $reason';
  }
}
