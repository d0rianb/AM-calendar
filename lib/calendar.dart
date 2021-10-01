import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import './calendar-event.dart';

const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);
const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);

class Calendar {
  List<CalendarEvent> events = [];

  Calendar(this.events);

  Widget build(BuildContext context) {
    return SafeArea(
      child: SfCalendar(
        view: CalendarView.workWeek,
        dataSource: AppointmentDataSource(events),
        allowedViews: <CalendarView>[
          CalendarView.day,
          CalendarView.workWeek,
          CalendarView.month,
        ],
        showDatePickerButton: true,
        timeZone: 'W. Europe Standard Time',
        timeSlotViewSettings: const TimeSlotViewSettings(
          timeInterval: const Duration(minutes: 60),
          timeIntervalHeight: 50,
          timeFormat: 'Hm',
          startHour: 8,
          endHour: 19,
        ),
        headerStyle: const CalendarHeaderStyle(
          textAlign: TextAlign.center,
          textStyle: const TextStyle(
            fontSize: 20,
            color: ORANGE,
          ),
        ),
        headerDateFormat: 'MMMM yyy',
        todayTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
          CalendarEvent event = details.appointments.first;
          return event.build(context, details.bounds.size);
        },
      ),
    );
  }
}
