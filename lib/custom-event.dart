import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sfcalendar/lib/calendar.dart';

class CustomEvent extends Appointment {
  String type = '';
  String subject = '';
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  Color color = Colors.transparent;
  SharedPreferences? prefs;

  bool get isVisible => prefs?.getBool('showPals') ?? false;

  CustomEvent({
    required this.type,
    required this.subject,
    required this.startTime,
    required this.endTime,
    this.prefs
  }) : super(startTime: startTime, endTime: endTime);

  Widget build(BuildContext context, Size size) {
    return Visibility(
      visible: isVisible,
      child: DefaultTextStyle(
        style: const TextStyle(decoration: TextDecoration.none),
        child: Center(
          child: Container(
            padding:  const EdgeInsets.all(2.0),
            margin: const EdgeInsets.all(0.0),
            width: size.width,
            height: size.height,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(3.5)),
              border: Border.all(color: Colors.blueGrey, width: 2),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    subject,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
