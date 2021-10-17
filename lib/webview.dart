import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String initialUrl = 'https://ensam.campusm.exlibrisgroup.com/campusm/cmauth/login/5313';
// const String initialUrl = 'lise.ensam.eu';
const Map<String, String> JSPath = {'username': '#username', 'password': '#password', 'submit': '#fm1 > section.row.btn-row > input.btn.btn-submit.btn-block', 'etudiant-personnel': '#mOdAl_1_body > div > div.listview > ul > li:nth-child(1) > a'};

class WebView extends StatefulWidget {
  @override
  WebViewState createState() => WebViewState();
}

class WebViewState extends State<WebView> {
  InAppWebViewController? webViewController;
  final InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(useShouldOverrideUrlLoading: true, mediaPlaybackRequiresUserGesture: false),
    android: AndroidInAppWebViewOptions(useHybridComposition: true),
    ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
  );

  static Future click(InAppWebViewController controller, String JSpathIndex) async {
    return controller.evaluateJavascript(source: '''
      document.querySelector('${JSPath[JSpathIndex]}').click()
      console.log(document.querySelector('${JSPath[JSpathIndex]}'))
      ''');
  }

  static Future fillField(InAppWebViewController controller, String JSpathIndex, String value) async {
    return controller.evaluateJavascript(source: '''document.querySelector('${JSPath[JSpathIndex]}')).value = $value''');
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(initialUrl), headers: {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36'}),
      initialOptions: options,
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
      onLoadStart: (controller, url) {
        print('Load start : $url');
      },
      androidOnPermissionRequest: (controller, origin, resources) async {
        return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var uri = navigationAction.request.url!;
        print('uri: $uri');
        return NavigationActionPolicy.ALLOW;
      },
      onLoadStop: (controller, url) async {
        print('Load end : $url');
        var r = await click(controller, 'etudiant-personnel');
        // await fillField(controller, 'username', 'username');
        // await fillField(controller, 'password', 'password');
        // await click(controller, 'submit');
      },
      onLoadHttpError: (controller, url, code, message) => print('HTTP error $code : $message'),
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        print('onUpdateVisitedHistory');
      },
      onConsoleMessage: (controller, consoleMessage) {
        print(consoleMessage);
      },
    );
  }
}
