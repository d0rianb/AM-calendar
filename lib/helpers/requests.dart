import 'dart:convert';

import 'package:am_calendar/helpers/app-events.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icalendar_parser/icalendar_parser.dart';


import '../main.dart' show eventBus;

typedef JSON = Map<String, dynamic>;

enum DataSource {
  EnsamCampus,
  ICal, // LISE webcal
  All, // All sources - for debug purpose only
}

// For the v2 beta, the default source is ENSAM Campus as in v1
const DataSource defaultSource = DataSource.EnsamCampus;

class ENSAMRequest {
  static const Map<String, String> ENSAMCampusHeaders = {
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
      // TODO: handle deconnection
    }
  }
}

class ICalRequest {
  static const Map<String, String> ICalHeaders = {};

  static Future<String> getICalFile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String id = prefs.getString('id') ?? '';
    if (id == '') return Future.error(ErrorHint('Empty id (2021-XXX), please provide one in the settings'));
    final Uri uri = Uri.https('lise.ensam.eu', 'ical_apprenant/$id');
    final Response response = await get(uri, headers: ICalHeaders);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      // TODO: manage error
      print('[Error] getICalFile:');
      print(response);
    }
    return '';
  }

  static Future<JSON> getCalendar() async {
    final String responseBody = await ICalRequest.getICalFile();
    ICalendar iCal = ICalendar.fromString(responseBody);
    JSON json = iCal.toJson();
    if (json.containsKey('data')) {
      return json;
    }
    return {};
  }
}
