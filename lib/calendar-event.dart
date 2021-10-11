import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'blur-transition.dart';
import 'calendar-event-popup.dart';
import 'calendar-item.dart';
import 'color-helpers.dart';

typedef JSON = Map<String, dynamic>;

Map<String, Color> classColor = {};
List<MaterialColor> primariesColors = <MaterialColor>[
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.orange,
  Colors.deepOrange,
];

class CalendarEvent extends Appointment {
  String title = '';
  String course = '';
  String classType = '';
  String? location = '';
  String teacherName = '';
  String duration = '';
  String group = '';
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  bool isAllDay = false;

  CalendarEvent({required this.title, required this.course, required this.classType, this.location, required this.teacherName, required this.group, required this.duration, required this.startTime, required this.endTime, this.isAllDay = false}) : super(startTime: startTime, endTime: endTime);

  static final DateFormat dateParser = new DateFormat("yyyy-MM-dd'T'HH:mm:ssZ");
  static final RegExp endCharRegex = new RegExp(r'\\n');
  static final RegExp classeTypeRegex = new RegExp(r'TYPE_ACTIVITE\s:\s([\w_]+)\n', caseSensitive: false, multiLine: true);
  static final RegExp teacherNameRegex = new RegExp(r'INTERVENANTS\s:\s(.+)\n-\sDESCRIPTION');
  static final RegExp groupRegex = new RegExp(r'GROUPES\s:\s(.*)\\n');

  String get subject => '$classType - $teacherName - $duration' + (isExam ? ' - EXAMEN' : '');
  Color get color {
    if (!classColor.containsKey(subject)) {
      Color color = primariesColors[Random().nextInt(primariesColors.length)][300]!;
      classColor[subject] = color;
    }
    return classColor[subject] ?? Colors.blue;
  }
  bool get shouldDisplay => classType != 'INDISP';
  bool get isExam => title.contains('EXAMEN');
  bool get isVisio => title.contains('VIA TEAMS');
  Color get borderColor => isExam ? Colors.red : isVisio ? Colors.green : darken(color, 10);

  static CalendarEvent fromLiseObject(JSON event) {
    List<String> list = event['title'].split(' - ');
    String subject = list[3];

    CalendarEvent calendarEvent = new CalendarEvent(
      title: event['title'],
      course: subject,
      classType: list[4],
      location: list[0],
      teacherName: list[5],
      duration: list[6],
      group: list[8],
      startTime: dateParser.parse(event['start']),
      endTime: dateParser.parse(event['end']),
      isAllDay: event['allDay'] as bool,
    );
    return calendarEvent;
  }

  static CalendarEvent fromENSAMCampus(JSON event) {
    DateTime startTime = dateParser.parse(event['start']);
    DateTime endTime = dateParser.parse(event['end']);
    return new CalendarEvent(
      title: (event['desc1'] + event['desc2']).replaceAll(endCharRegex, ''),
      course: event['desc1'].replaceAll(endCharRegex, ''),
      classType: classeTypeRegex.firstMatch(event['desc2'])?.group(1) ?? '',
      location: event['locAdd1'].replaceAll(endCharRegex, ''),
      teacherName: teacherNameRegex.firstMatch(event['desc2'])?.group(1) ?? '',
      group: groupRegex.firstMatch(event['desc2'])?.group(1) ?? '',
      duration: '${endTime.difference(startTime).inHours}h',
      startTime: startTime,
      endTime: endTime,
      isAllDay: event['meeting'] == 'true',
    );
  }

  static CalendarEvent fromJSON(JSON event) {
    DateTime startTime = dateParser.parse(event['startTime']);
    DateTime endTime = dateParser.parse(event['endTime']);
    return new CalendarEvent(
      title: event['title'],
      course: event['course'],
      classType: event['classType'],
      location: event['location'],
      teacherName: event['teacherName'],
      group: event['group'],
      duration: event['duration'],
      startTime: startTime,
      endTime: endTime,
      isAllDay: event['isAllDay'],
    );
  }

  String getTimePeriod() {
    DateFormat dateTimeFormatter = DateFormat('kk:mm');
    String start = dateTimeFormatter.format(startTime);
    String end = dateTimeFormatter.format(endTime);
    return '$start - $end';
  }

  String toJSON() {
    return jsonEncode({
      'title': title,
      'course': course,
      'classType': classType,
      'location': location,
      'teacherName': teacherName,
      'duration': duration,
      'group': group,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay,
    });
  }

  Widget build(BuildContext context, Size size) {
    return Listener(
      onPointerDown: (pointerDownEvent) => Navigator.push(
        context,
        new PageRouteBuilder(
          pageBuilder: (context, animation, _) => CalendarEventPopup(this),
          opaque: false,
          transitionsBuilder: (context, animation, _, child) {
            final tween = Tween<double>(begin: 0, end: 2.0);
            animation.drive(tween);
            return BlurTransition(
              animation: tween.animate(animation),
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: animation.value, sigmaY: animation.value),
                    child: Scrollable(
                      physics: NeverScrollableScrollPhysics(),
                      viewportBuilder: (BuildContext context, _) => Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                  child,
                ],
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          barrierDismissible: true,
        ),
      ),
      onPointerUp: (_) => Navigator.pop(context),
      child: CalendarItem(this, size, false),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }
}
