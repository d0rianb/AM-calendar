import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

const Map<String, String> authenticationHeaders = {
  'authority': 'lise.ensam.eu',
  'cache-control': 'max-age=0',
  'sec-ch-ua': '"Google Chrome";v="93", " Not;A Brand";v="99", "Chromium";v="93"',
  'sec-ch-ua-mobile': '?0',
  'sec-ch-ua-platform': "macOS",
  'origin': 'https://lise.ensam.eu',
  'upgrade-insecure-requests': '1',
  'dnt': '1',
  'content-type': 'application/x-www-form-urlencoded',
  'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36',
  'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
  'sec-fetch-site': 'same-origin',
  'sec-fetch-mode': 'navigate',
  'sec-fetch-user': '?1',
  'sec-fetch-dest': 'document',
  'referer': 'https://lise.ensam.eu/faces/Login.xhtml',
  'accept-language': 'fr-FR,fr;q=0.9',
  'cookie': 'JSESSIONID=48E04405ACB7F7F4C4A8FABF4A0381BF',
};

class LiseRequest {
  static Future<Response> authenticate() async {
    return post(
      Uri.parse('https://lise.ensam.eu/login'),
      headers: authenticationHeaders,
      body: {
        'username': '2021 - 0698',
        'password': 'Lololeproem2.0',
        'j_idt28': '',
      },
    );
  }

  static Future<String?> getJSESSIONID() async {
    // TODO: improve
    Response response = await authenticate();
    print(response.statusCode);
    debugPrint(response.body);
    String cookie = response.headers['set-cookie'] ?? '';
    return ''; //cookie.substring(11, 43);
  }
}
