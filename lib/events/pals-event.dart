import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './custom-event.dart';

class PalsEvent extends CustomEvent {
  String subject = '';
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  Color color = Colors.transparent;
  Color textColor = Colors.blueGrey;
  Color borderColor = Colors.blueGrey;
  SharedPreferences? prefs;

  bool get isVisible => prefs?.getBool('showPals') ?? false;

  PalsEvent({
    required this.subject,
    required this.startTime,
    required this.endTime,
    this.prefs,
  }) : super(type: 'pals', subject: subject, startTime: startTime, endTime: endTime, prefs: prefs);
}
