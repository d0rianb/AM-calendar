import 'package:am_calendar/helpers/snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      document.querySelector('${JSPath[JSpathIndex]}').requestSubmit()
      ''');
  }

  static Future getInputValue(InAppWebViewController controller, String JSpathIndex) async {
    return controller.evaluateJavascript(source: '''
        document.querySelector('${JSPath[JSpathIndex]}').value
    ''');
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Identification')),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
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
                onLoadStart: (controller, url) {
                  if (url.toString().startsWith('https://auth.ensam.eu/cas/login')) {
                    controller.evaluateJavascript(source: '''
                  window.onload = () => {
                    document.querySelector('header').hidden = true
                    document.querySelector('footer').hidden = true
                  }
                  ''');
                  }
                },
                androidOnPermissionRequest: (controller, origin, resources) async => PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT),
                shouldOverrideUrlLoading: (controller, navigationAction) async => NavigationActionPolicy.ALLOW,
                onLoadStop: (controller, url) async {
                  if (url.toString().startsWith('https://auth.ensam.eu/cas/login?')) {
                    controller.evaluateJavascript(source: '''document.querySelector("#fm1").onsubmit = () => console.log('internalSubmitForm')''');
                    if (prefs.getString('id') != null && prefs.getString('id')!.isNotEmpty)
                      fillField(controller, 'username', prefs.getString('id')!);
                    else
                      click(controller, 'username');
                    if (prefs.getString('password') != null && prefs.getString('password')!.isNotEmpty) fillField(controller, 'password', prefs.getString('password')!);
                    setState(() => isLoading = false);
                  }
                  filledUsername = await getInputValue(controller, 'username') ?? filledUsername;
                  filledPassword = await getInputValue(controller, 'password') ?? filledPassword;
                  if (url.toString() == 'https://ensam.campusm.exlibrisgroup.com/cmauth/saml/sso') {
                    setState(() => isLoading = true);
                    showSnackBar(context, 'Connection en cours ...');
                    final List<Cookie> cookies = await cookieManager.getCookies(url: Uri.parse('https://ensam.campusm.exlibrisgroup.com'));
                    final int cmAuthTokenIndex = cookies.indexWhere((cookie) => cookie.name == 'cmAuthToken');
                    if (cmAuthTokenIndex > -1) {
                      prefs.setString('cmAuthToken', cookies[cmAuthTokenIndex].value);
                      if (filledUsername != null) prefs.setString('id', filledUsername!);
                      if (filledPassword != null) prefs.setString('password', filledPassword!);
                      Navigator.of(context).pushNamed('/calendar');
                    } else {
                      print('No auth cookie detected');
                      showSnackBar(context, 'No auth cookie detected');
                    }
                  }
                },
                onLoadHttpError: (controller, url, code, message) => print('HTTP error $code : $message'),
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
                  child: const RefreshProgressIndicator(color: VIOLET, strokeWidth: 2.5),
                ),
              ),
            ],
          ),
        ),
      );
}
