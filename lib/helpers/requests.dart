import 'dart:convert';
import 'package:am_calendar/helpers/app-events.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart' show eventBus;

// const String dorianAuthCookie =
//     'cmAuthToken=eyJhbGciOiJSUzI1NiJ9.eyJqdGkiOiI4VWp0NERlS3dvcG9tM3RiRXdNb2pnIiwiaWF0IjoxNjMyOTg1MDUwLCJpc3MiOiJFeExpYnJpcyIsInN1YiI6IkNhbXB1c01Vc2VyIiwiZXhwIjoxNjM1NTc3MDUwLCJ1c2VybmFtZSI6IjIwMjEtMDY5OCIsIm1haWwiOiJkb3JpYW4uYmVhdWNoZXNuZUBlbnNhbS5ldSIsImZpcnN0TmFtZSI6IkRvcmlhbiIsImxhc3ROYW1lIjoiQkVBVUNIRVNORSIsImNtUGVyc29uSWQiOjUxOTMxODksImNtT3JnQ29kZSI6Njc5MiwiY21Qcm9maWxlR3JvdXBJZCI6NTMxMywiY21JbnRlZ3JhdGlvblByb2ZpbGVJZCI6OTAxLCJleHRyYUF0dHJzIjp7ImNhbXB1c25hbWUiOiJDSEFMT05TIiwidXNlclByaW5jaXBhbE5hbWUiOiJkb3JpYW4uYmVhdWNoZXNuZUBlbnNhbS5ldSIsIlN0dWRlbnRJZCI6IjIwMjEtMDY5OCJ9LCJhdXRoVHlwZSI6IkNNQVVUSCIsInJvbGVzSGFzaCI6IjlRSnFUcHh6TVpyYzdlOTZqZnIrelplQlgveVNqSXpvN3FxbmZPL3VvaUE9In0.KRMTuxLQb9UX6bnMrO739LCwO8okgCfvMKfmn_-5I-tai7CRizWCdmYwvpwIyl86LfP1VmLWxroDlwLn1k98VARm4uYnoOq0TyiBEDeD7Ia5Y2fGg1dsjWg1EYZNUZSUWJHg1i06zayNTlAB79pZE3xsig_7OD-l2AUOcvAL58jsjRkfd4E5OAq07alV2QwEWYxS-qhFKB_i-aOsfh1KmtHgUFmG-KB0x1OoXi0jSrsuGmXtzgvgOiUYyhH_N438GU6AlqHsEzMiXnMtarLd79yXwtPENSbW7rv3O1P8yaLWwY34fW2QWhn3UR4BefapNh5LxSlIJ3mtoH-raBsVWQ; a=de4c81413fc40bddtRuxhiUs%2FPeuD4Q3QXb5p%2FwQVO%2FXRmDStxjBSpOoBcCHiiqD2YIsNkGpu0cbRGv%2FlEULtRbfJETAbVGILhG6Cgu3VllcBKOaMk%2B%2FQHv9wxiNgW84tgmPzlthS2D80MaDUpTT5Y1kujuxse1FTxBrmZgURL8gd4pkfHuKpeyjfO%2FJ61VexSUUSfC1y8%2FP55URk0jwo1gPBRdQC1J4339RvQlrj2bLINN3EmIt0F%2F0K7EE3I%2B4axCMslNbnG6yZaKD8L2ZJDRMtzad5%2Fkc9MxaBkym36Jz3EgLJg1YDCSavAVjBefXrvfzkd8VKhosHabkNkRlYl8rlJlFbDxNg%2F%2BN%2BgxRTLYWuduiMD%2FPnTy8KEL3BbAeaRBh5QsgcPCn2FeYwnD%2Ft0IGoKBKJ0IqJeIAyYXvkAHaCBY%2BwWRH0UEmZr0jm6L3VrYNb7RDRYFUYgvmZY%2FHzwSXBRuCuKG8EZ0yKcCZxi56n70AX4M%2FhtKIBmIK5KzqIHJLWxj0oRoscAZe8TkaJ7qnfOTw7hdMj221b38J%2BQy%2B5LXduanwz%2FQhOVtWA%2FSmdRRUN5aL1imU1hJN7NV8DNHtZo3DskP2oQ6lE515hM%2Fi59SkQmUkR4JDRRcP1pjxXGkXn2se9rzydCDpLThYOkNDDLpitJvnY7DGzo%2Fim68%2B%2BFK9qrGK0rssrAg%3D; __a=fc348637bf477e2aa4646b21789b7c50';

const Map<String, String> liseAuthenticationHeaders = {
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
const Map<String, String> ENSAMCampusHeaders = {
  'Connection': 'keep-alive',
  'sec-ch-ua': '"Chromium";v="94", "Google Chrome";v="94", ";Not A Brand";v="99"',
  'DNT': '1',
  'sec-ch-ua-mobile': '?0',
  'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.61 Safari/537.36',
  'X-Requested-With': 'XMLHttpRequest',
  'sec-ch-ua-platform': "macOS",
  'Accept': '*/*',
  'Sec-Fetch-Site': 'same-origin',
  'Sec-Fetch-Mode': 'cors',
  'Sec-Fetch-Dest': 'empty',
  'Referer': 'https://ensam.campusm.exlibrisgroup.com/campusm/home',
  'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
};

typedef JSON = Map<String, dynamic>;

class LiseRequest {
  static Future<Response> authenticate() async {
    return post(
      Uri.parse('https://lise.ensam.eu/login'),
      headers: liseAuthenticationHeaders,
      body: {
        'username': '2021 - 0698',
        'password': 'None',
        'j_idt28': '',
      },
    );
  }

  static Future<String?> getJSESSIONID() async {
    // TODO: improve
    Response response = await authenticate();
    print(response.statusCode);
    // String cookie = response.headers['set-cookie'] ?? '';
    return ''; //cookie.substring(11, 43);
  }
}

class ENSAMRequest {
  static Future<JSON> getCalendar(DateTime start, DateTime end) async {
    if (end.isBefore(start)) throw new Exception('Invalid week');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String startParam = DateTime(start.year, start.month, start.day, 0, 0, 0).toIso8601String();
    final String endParam = DateTime(end.year, end.month, end.day, 23, 59, 59).toIso8601String();
    final Uri uri = Uri.https('ensam.campusm.exlibrisgroup.com', 'campusm/sso/cal2/course_timetable', {'start': startParam, 'end': endParam});
    final String? authCookie = prefs.getString('cmAuthToken');
    if (authCookie == null) return Future.error(ErrorHint('Unable to retrieve the auth cookie'));
    final Response response = await get(uri, headers: {...ENSAMCampusHeaders, 'Cookie': 'cmAuthToken=$authCookie'});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String errorMsg = 'Erreur de connexion  : ${response.statusCode} - ${response.reasonPhrase}';
      if (response.statusCode == 403) {
        errorMsg += ' : Essayez de vous déconnecter puis de vous reconnecter';
      }
      eventBus.fire(RequestErrorEvent(errorMsg));
      throw new Exception('Error while fetching calendar : ${response.statusCode} - ${response.reasonPhrase}');
    }
  }
}
