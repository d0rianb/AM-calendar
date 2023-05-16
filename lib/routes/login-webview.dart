import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/refresh-indicator.dart';
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

class LoginWebView extends StatefulWidget {
  const LoginWebView({Key? key}) : super(key: key);

  @override
  LoginWebViewState createState() => LoginWebViewState();
}

class LoginWebViewState extends State<LoginWebView> {
  static final CookieManager cookieManager = CookieManager.instance();
  late InAppWebViewController webViewController;
  late SharedPreferences prefs;
  String? filledUsername;
  bool isLoading = true;
  bool hasLoadLoginPage = false;
  String? filledPassword;
  int urlLoadingRestart = 0;

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    print('Entering inAppWebView');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identification'),
        leading: BackButton(color: theme.appBarTheme.foregroundColor),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(initialUrl)),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                incognito: false,
                useHybridComposition: true,
                sharedCookiesEnabled: true,
                loadsImagesAutomatically: false,
              ),
              onWebViewCreated: (controller) async {
                prefs = await SharedPreferences.getInstance();
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                print('Load start : ' + url.toString());
                if (url.toString().startsWith('https://auth.ensam.eu/cas/login')) {
                  controller.evaluateJavascript(source: '''
                      window.onload = () => {
                        document.querySelector('header').hidden = true
                        document.querySelector('footer').hidden = true
                      }''');
                }
              },
              onPermissionRequest: (controller, request) async => PermissionResponse(action: PermissionResponseAction.GRANT),
              shouldOverrideUrlLoading: (controller, navigationAction) async => NavigationActionPolicy.ALLOW,
              onLoadStop: (controller, url) async {
                if (url.toString().startsWith('https://auth.ensam.eu/cas/login?')) {
                  controller.evaluateJavascript(source: '''document.querySelector("#fm1").onsubmit = () => console.log('internalSubmitForm')''');
                  controller.evaluateJavascript(source: '''document.querySelector('button[name="continue"]').click()'''); // To solve the change password popup issue
                }
                if (url.toString().startsWith('https://ensam.campusm.exlibrisgroup.com/cmauth')) {
                  setState(() => isLoading = false);
                  final List<Cookie> cookies = await cookieManager.getCookies(url: WebUri('https://ensam.campusm.exlibrisgroup.com'));
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
              onUpdateVisitedHistory: (controller, url, androidIsReload) {},
              onConsoleMessage: (controller, consoleMessage) => consoleMessage.message == 'internalSubmitForm' ? setState(() => hasLoadLoginPage = true) : print('[Embedded console] : $consoleMessage'),
            ),
            Visibility(
              visible: isLoading || hasLoadLoginPage,
              child: Positioned(
                top: 50,
                left: MediaQuery.of(context).size.width / 2 - 25,
                width: 50,
                height: 50,
                child: ShadowedRefreshIndicator(color: theme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
