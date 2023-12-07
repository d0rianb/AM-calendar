import 'dart:io';

import 'package:am_calendar/helpers/app-events.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icalendar_parser/icalendar_parser.dart';


import '../main.dart' show eventBus;

typedef JSON = Map<String, dynamic>;

class ICalRequest {
  static const Map<String, String> ICalHeaders = { 'cache-control': 'no-cache' };

  static Future<String> getICalFile() async {
    eventBus.fire(LoginEvent('Initialisation de la connexion'));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String id = prefs.getString('id') ?? '';
    if (id == '') {
      eventBus.fire(RequestErrorEvent('Identifiant "$id" incorrect. Il doit être de la forme (202X-XXX)'));
      return '';
    }
    final Uri uri = Uri.https('lise.ensam.eu', 'ical_apprenant/$id');
    eventBus.fire(LoginEvent('Envoi de la requête iCal'));
    await Future.delayed(Duration(seconds: 5));
    try {
      final Response response = await get(uri, headers: ICalHeaders);
      eventBus.fire(LoginEvent('Réception de la réponse'));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        eventBus.fire(RequestErrorEvent('Erreur de connexion: $response'));
      }
    } on SocketException catch (e) {
      print(e);
      eventBus.fire(RequestErrorEvent('Erreur de connexion: pas de réseau détecté'));
    }
    return '';
  }

  static Future<JSON> getCalendar() async {
    eventBus.fire(LoginEvent('Analyse de la réponse'));
    String responseBody = '';
    responseBody = await ICalRequest.getICalFile();
    if (responseBody == '') {
      eventBus.fire(RequestErrorEvent('Erreur : Réponse invalide'));
      return {};
    }
    ICalendar iCal = ICalendar.fromString(responseBody);
    JSON json = iCal.toJson();
    if (json.containsKey('data')) {
      eventBus.fire(LoginEvent('Connexion réussie', finished: true));
      return json;
    }
    eventBus.fire(RequestErrorEvent('Erreur : Fichier ICal invalide'));
    return {};
  }
}
