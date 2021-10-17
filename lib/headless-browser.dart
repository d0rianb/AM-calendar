import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String initialUrl = 'https://ensam.campusm.exlibrisgroup.com/campusm/home#select-profile';
const Map<String, String> JSPath = {
  'username': '#username',
  'password': '#password',
  'submit': '#fm1 > section.row.btn-row > input.btn.btn-submit.btn-block',
  'etudiant-personnel': '#mOdAl_1_body > div > div.listview > ul > li:nth-child(1) > a'
};

class HeadlessBrowser {
  static HeadlessInAppWebView? headlessWebView;
  static CookieManager cookieManager = CookieManager.instance();

  static Future click(InAppWebViewController controller, String JSpathIndex) async {
    return controller.evaluateJavascript(source: '''
      document.querySelector(${JSPath[JSpathIndex]}).click()
      console.log(document.querySelector(${JSPath[JSpathIndex]}))
      ''');
  }

  static Future fillField(InAppWebViewController controller, String JSpathIndex, String value) async {
    return controller.evaluateJavascript(source: 'document.querySelector(${JSPath[JSpathIndex]}).value = $value');
  }

  static void getSecureCookie(String username, String password) {
    headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
      onLoadHttpError: (controller, url, code, message) => print('HTTP error $code : $message'),
      onLoadStop: (controller, url) async {
        var r = await click(controller, 'etudiant-personnel');
        await fillField(controller, 'username', username);
        await fillField(controller, 'password', password);
        await click(controller, 'submit');
        List<Cookie> cookies = await cookieManager.getCookies(url: Uri.parse('ensam.campusm.exlibrisgroup.com'));
        print('cookie : $cookies');
      },
    );
    headlessWebView!.run();
  }

}