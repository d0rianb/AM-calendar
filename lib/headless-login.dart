import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/snackbar.dart';

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
      document.querySelector('${JSPath[JSpathIndex]}').value = '$value'
      ''');
  }

  static Future submit(InAppWebViewController controller, String JSpathIndex) async {
    return controller.evaluateJavascript(source: '''
      let form = document.querySelector('${JSPath[JSpathIndex]}')
      let button = document.querySelector('${JSPath['submit']}')
      form.requestSubmit(button)
      ''');
  }

  static Future getInputValue(InAppWebViewController controller, String JSpathIndex) async {
    return controller.evaluateJavascript(source: '''
        document.querySelector('${JSPath[JSpathIndex]}').value
    ''');
  }


  void login(BuildContext context) async {
    var headlessWebView = HeadlessInAppWebView(
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
      },
      onLoadStart: (controller, url) {},
      androidOnPermissionRequest: (controller, origin, resources) async => PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT),
      shouldOverrideUrlLoading: (controller, navigationAction) async => NavigationActionPolicy.ALLOW,
      onLoadStop: (controller, url) async {
        if (url.toString().startsWith('https://auth.ensam.eu/cas/login?')) {
          if (++urlCount < 2) return;
          controller.evaluateJavascript(source: '''document.querySelector("#fm1").onsubmit = () => console.log('internalSubmitForm')''');
          if (prefs.getString('id') == null || prefs.getString('id')!.isEmpty) return error('id');
          if (prefs.getString('password') == null || prefs.getString('password')!.isEmpty) return error('password');
          fillField(controller, 'username', prefs.getString('id')!);
          fillField(controller, 'password', prefs.getString('password')!);
          submit(controller, 'login-form');
        }
        if (url.toString() == 'https://ensam.campusm.exlibrisgroup.com/cmauth/saml/sso') {
          final List<Cookie> cookies = await cookieManager.getCookies(url: Uri.parse('https://ensam.campusm.exlibrisgroup.com'));
          final int cmAuthTokenIndex = cookies.indexWhere((cookie) => cookie.name == 'cmAuthToken');
          if (cmAuthTokenIndex > -1) {
            prefs.setString('cmAuthToken', cookies[cmAuthTokenIndex].value);
            Navigator.of(context).pushNamed('/calendar');
          } else {
            print('No auth cookie detected');
            showSnackBar(context, 'No auth cookie detected');
          }
        }
      },
      onLoadHttpError: (controller, url, code, message) => print('HTTP error $code : $message'),
      onUpdateVisitedHistory: (controller, url, androidIsReload) {},
      onConsoleMessage: (controller, consoleMessage) => print('[Embedded console] : $consoleMessage'),
    );
    await headlessWebView.run();
  }

  void error([String? reason]) {
    print('Error : $reason');
    return;
  }
}
