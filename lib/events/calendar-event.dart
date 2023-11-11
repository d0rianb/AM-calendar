import 'dart:convert';
import 'dart:core';
import 'dart:ui';

import 'package:am_calendar/helpers/requests.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/datetime-helpers.dart';
import '../sfcalendar/calendar.dart';

import 'calendar-event-popup.dart';
import '../helpers/blur-transition.dart';
import '../calendar-item.dart';
import '../calendar.dart';
import '../helpers/color-helpers.dart';

typedef JSON = Map<String, dynamic>;

final Map<String, Color> classColor = {
  'CM': ORANGE,
  'ED TD': HexColor.fromHex('#9b3471'),
  'MISSION': HexColor.fromHex('#9b3471'),
  'TPS': HexColor.fromHex('#1976d2'),
  'TPF': HexColor.fromHex('#1976d2'),
  'OTHER': HexColor.fromHex('#607d8b'),
  'EXAM': HexColor.fromHex('#e53935'),
  'REUNION': HexColor.fromHex('#7986cb'),
  'TEAMS': HexColor.fromHex('#4caf50'),
};

final class EnsamCampusRegex {
  static final RegExp all = new RegExp(r'(.*)');
  static final RegExp endChar = new RegExp(r'\\n');
  static final RegExp classeType = new RegExp(r'TYPE_ACTIVITE\s:\s([\w_]+)\n', caseSensitive: false, multiLine: true);
  static final RegExp teacherName = new RegExp(r'INTERVENANTS\s:\s(.+)\n-\sDESCRIPTION');
  static final RegExp description = new RegExp(r'DESCRIPTION\s:\s(.+)\n-\sGROUPES');
  static final RegExp group = new RegExp(r'GROUPES\s:\s(.*)\n');
}

final class ICalRegex {
  static final RegExp all = new RegExp(r'(.*)');
  static final RegExp endChar = new RegExp(r'\\n');
  static final RegExp classeType = new RegExp(r'TYPE_ACTIVITE\s:\s([\w_]+)\\n', caseSensitive: false, multiLine: true);
  static final RegExp teacherName = new RegExp(r'INTERVENANTS\s:\s(.+)\\n-\sDESCRIPTION');
  static final RegExp description = new RegExp(r'DESCRIPTION\s:\s(.+)\\n-\sGROUPES');
  static final RegExp group = new RegExp(r'GROUPES\s:\s(.*)\\n');
}

class CalendarEvent extends Appointment {
  String title = '';
  String course = '';
  String classType = '';
  String? location = '';
  String? description = '';
  String teacherName = '';
  String duration = '';
  String group = '';
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  bool isAllDay = false;
  DataSource source = defaultSource;

  CalendarEvent({
    required this.title,
    required this.course,
    required this.classType,
    this.location,
    this.description,
    required this.teacherName,
    required this.group,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.source = defaultSource,
  }) : super(startTime: startTime, endTime: endTime);

  // For ENSAM Campus parsing
  static final DateFormat Iso8601DateParser = new DateFormat("yyyy-MM-dd'T'HH:mm:ssZ");

  String get subject => List.from([classType, description, teacherName].where((element) => element != '' && element != ' ')).join(' - ');

  String get formattedLocation => location ?? '';

  Color get color {
    String type = classType.replaceAll('_TEAMS', '');
    return classColor.containsKey(type)
        ? classColor[type]!
        : isExam
            ? classColor['EXAM']!
            : classColor['OTHER']!;
  }

  bool get shouldDisplay => classType != 'INDISP';

  bool get isExam => title.toUpperCase().contains('EXAMEN') || title.toUpperCase().contains('TEST') || title.toUpperCase().contains('SOUTENANCE');

  bool get isVisio => title.contains('TEAMS') || (location != null && location!.contains('TEAMS')) || title.contains('autonom'); // match "ED en autonomie" | "ED autonome"

  Color get borderColor => isVisio ? classColor['TEAMS']! : darken(color, 15);

  String get id => (location ?? '') + teacherName + group + startTime.millisecondsSinceEpoch.toString() + source.toString();

  /// Get the first group and format the result of the regex by taking of the \n and the _
  /// The XXXRegexp.all permit just the formatting
  static String getFormattedRegexResult(RegExp re, String input, { bool formatUnderscore = true, formatEndLine = true }) {
    String result = re.firstMatch(input)?.group(1) ?? '';
    if (formatUnderscore) result = result .replaceAll('_', ' ');
    if (formatEndLine) result = result.replaceAll(EnsamCampusRegex.endChar, '');
    return result;
  }

  static CalendarEvent fromENSAMCampus(JSON event) {
    DateTime startTime = Iso8601DateParser.parse(event['start']);
    DateTime endTime = Iso8601DateParser.parse(event['end']);
    Duration rawDuration = endTime.difference(startTime);
    String duration = (rawDuration.inMinutes % 60 == 0) ? '${rawDuration.inHours}h' : '${rawDuration.inHours}h${rawDuration.inMinutes - rawDuration.inHours * 60}';

    String desc1 = event['desc1'];
    String desc2 = event['desc2'];

    return new CalendarEvent(
      title: desc1 + desc2,
      course: getFormattedRegexResult(EnsamCampusRegex.all, desc1),
      classType: getFormattedRegexResult(EnsamCampusRegex.classeType, desc2),
      location: getFormattedRegexResult(EnsamCampusRegex.all, event['locAdd1']),
      teacherName: getFormattedRegexResult(EnsamCampusRegex.teacherName, desc2),
      description: getFormattedRegexResult(EnsamCampusRegex.description, desc2),
      group: getFormattedRegexResult(EnsamCampusRegex.group, desc2),
      duration: duration,
      startTime: startTime,
      endTime: endTime,
      isAllDay: event['meeting'] == 'true',
      source: DataSource.EnsamCampus,
    );
  }

  static CalendarEvent fromICal(JSON event) {
    if (event['type'] != 'VEVENT') {
      print('from ICal [Error]');
      print(event);
    }

    DateTime startTime = ICalDateParser.parse(event['dtstart']['dt']);
    DateTime endTime = ICalDateParser.parse(event['dtend']['dt']);
    Duration rawDuration = endTime.difference(startTime);
    String duration = (rawDuration.inMinutes % 60 == 0) ? '${rawDuration.inHours}h' : '${rawDuration.inHours}h${rawDuration.inMinutes - rawDuration.inHours * 60}';

    String description = event['description'];
    String summary = event['summary'];
    String location = event.containsKey('location') ? event['location'] : '';

    return new CalendarEvent(
        title: summary + description,
        course: getFormattedRegexResult(ICalRegex.all, summary),
        classType: getFormattedRegexResult(ICalRegex.classeType, description),
        location: getFormattedRegexResult(ICalRegex.all, location),
        teacherName: getFormattedRegexResult(ICalRegex.teacherName, description),
        description: getFormattedRegexResult(ICalRegex.description, description),
        group: getFormattedRegexResult(ICalRegex.group, description),
        duration: duration,
        startTime: startTime,
        endTime: endTime,
        isAllDay: rawDuration.inHours >= 7 ,
        source: DataSource.ICal,
    );
  }

  // From cache
  static CalendarEvent fromJSON(JSON event) {
    DateTime startTime = Iso8601DateParser.parse(event['startTime']);
    DateTime endTime = Iso8601DateParser.parse(event['endTime']);
    return new CalendarEvent(
      title: event['title'],
      course: event['course'],
      classType: event['classType'],
      location: event['location'],
      teacherName: event['teacherName'],
      description: event['description'],
      group: event['group'],
      duration: event['duration'],
      startTime: startTime,
      endTime: endTime,
      isAllDay: event['isAllDay'],
      source: DataSource.values.byName(event['source']),
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
      'description': description,
      'duration': duration,
      'group': group,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay,
      'source': source.name,
    });
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return toJSON();
  }

  Widget build(BuildContext context, Size size) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (pointerDownEvent) => shouldDisplay
          ? Navigator.push(
              context,
              new PageRouteBuilder(
                pageBuilder: (context, animation, _) => CalendarEventPopup(this),
                opaque: false,
                barrierDismissible: true,
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
              ),
            )
          : null,
      onPointerUp: (_) => shouldDisplay ? Navigator.pop(context) : null,
      onPointerCancel: (_) => shouldDisplay ? Navigator.pop(context) : null,
      child: CalendarItem(this, size, false),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].from;

  @override
  DateTime getEndTime(int index) => appointments![index].to;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;

  @override
  String getSubject(int index) => appointments![index].eventName;

  @override
  Color getColor(int index) => appointments![index].color;
}
