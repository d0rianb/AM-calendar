import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'blur-transition.dart';
import 'calendar-event-popup.dart';
import 'calendar-item.dart';

Map<String, Color> classColor = {};
List<MaterialColor> primariesColors = <MaterialColor>[
  Colors.red,
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
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  bool isAllDay = false;
  Color color = Colors.blue;

  CalendarEvent(this.title, this.course, this.classType, this.location, this.teacherName, this.duration, this.startTime, this.endTime, this.isAllDay) : super(startTime: startTime, endTime: endTime);

  get subject => '$classType - $teacherName - $duration';

  static fromLiseObject(Map<String, dynamic> event) {
    DateFormat dateParser = new DateFormat("yyyy-MM-dd'T'HH:mm:ssZ");
    List<String> list = event['title'].split(' - ');
    String subject = list[3];

    CalendarEvent calendarEvent = new CalendarEvent(
      event['title'],
      subject,
      list[4],
      list[0],
      list[5],
      list[6],
      dateParser.parse(event['start']),
      dateParser.parse(event['end']),
      event['allDay'] as bool,
    );

    if (!classColor.containsKey(subject)) {
      Color color = primariesColors[Random().nextInt(primariesColors.length)][300]!;
      classColor[subject] = color;
    }
    calendarEvent.color = classColor[subject]!;
    return calendarEvent;
  }

  Widget build(BuildContext context, Size size) {
    return Listener(
      onPointerDown: (_) => Navigator.push(
        context,
        new PageRouteBuilder(
          pageBuilder: (context, animation, _) => new CalendarEventPopup(this),
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
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
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

  String getTimePeriod() {
    DateFormat dateTimeFormatter = DateFormat('kk:mm');
    String start = dateTimeFormatter.format(startTime);
    String end = dateTimeFormatter.format(endTime);
    return '$start - $end';
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
