import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './calendar-event.dart';
import './requests.dart';
import './week.dart';
import 'cache.dart';

const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);
const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);

class Calendar extends StatefulWidget {
  Calendar() : super();

  @override
  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  CalendarController controller = CalendarController();
  List<CalendarEvent> events = [];
  Week week = Week.fromDateTime(DateTime.now());
  bool loading = false;
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    initSharedPreferences().then((_) => getEvents());
  }

  bool isLoading() => loading || events.length == 0;

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> getEvents() async {
    setState(() => loading = true);
    if (prefs != null && prefs!.containsKey(week.stringId)) {
      print('get value from storage');
      String storedValue = prefs!.getString(week.stringId)!;
      Cache cache = Cache.fromString(week.stringId, storedValue);
      if (cache.isValid) {
        return addEvents(cache.object);
      }
    }
    return getEventsFromNetworks();
  }

  void getEventsFromNetworks() async {
    setState(() => loading = true);
    var response = await ENSAMRequest.getCalendar(week.firstDay, week.lastDay);
    List<CalendarEvent> events = List.from(response['events'].map((e) => CalendarEvent.fromENSAMCampus(e)));
    Cache cache = Cache.create(week.stringId, events);
    if (prefs != null) prefs!.setString(cache.id, cache.serialized);
    addEvents(events);
  }

  void addEvents(List<CalendarEvent> newEvents) {
    newEvents.forEach((event) => !events.contains(event) ? events.add(event) : null);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Stack(
            children: [
              SfCalendar(
                view: CalendarView.workWeek,
                controller: controller,
                dataSource: AppointmentDataSource(events),
                allowedViews: [
                  CalendarView.day,
                  CalendarView.workWeek,
                  CalendarView.month,
                ],
                showDatePickerButton: true,
                timeZone: 'W. Europe Standard Time',
                timeSlotViewSettings: const TimeSlotViewSettings(
                  timeInterval: const Duration(minutes: 60),
                  timeIntervalHeight: 45,
                  timeFormat: 'Hm',
                  startHour: 7,
                  endHour: 19,
                ),
                viewHeaderStyle: const ViewHeaderStyle(
                  dayTextStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  dateTextStyle: const TextStyle(
                    fontSize: 15,
                    color: ORANGE,
                    fontWeight: FontWeight.w600,
                  ),
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
                onViewChanged: (viewChangedDetails) async {
                  if (viewChangedDetails.visibleDates.first.day != week.firstDay.day) {
                    week = Week(viewChangedDetails.visibleDates.first, viewChangedDetails.visibleDates.last);
                    if (events.where((e) => e.startTime.isAfter(week.firstDay)).length == 0) {
                      getEvents();
                    }
                  }
                },
              ),
              Visibility(
                visible: isLoading(),
                child: Positioned(
                  top: 75,
                  left: MediaQuery.of(context).size.width / 2 - 25,
                  width: 50,
                  height: 50,
                  child: const RefreshProgressIndicator(color: VIOLET, strokeWidth: 2.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
