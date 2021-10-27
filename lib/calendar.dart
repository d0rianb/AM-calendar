import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './calendar-event.dart';
import './requests.dart';
import './week.dart';
import './cache.dart';

const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);
const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);

class Calendar extends StatefulWidget {
  Calendar() : super();

  @override
  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  final CalendarController controller = CalendarController();
  List<CalendarEvent> events = [];
  Week week = Week.fromDateTime(DateTime.now());
  bool loading = false;
  SharedPreferences? prefs;

  bool get isLoading => loading || events.length == 0;

  @override
  void initState() {
    super.initState();
    initSharedPreferences().then((_) => getEvents());
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> getEvents() async {
    print('getEvents');
    setState(() => loading = true);
    loadWeekFromStorage(week);
    loadWeekFromStorage(week.getNewtWeek());
    if (events.isNotEmpty) setState(() => loading = false);
    getEventsFromNetworks(week);
    getEventsFromNetworks(week.getNewtWeek());
    setState(() => loading = false);
  }

  bool loadWeekFromStorage(Week week) {
    if (prefs == null) return false;
    if (!prefs!.containsKey(week.stringId)) return false;
    final String storedValue = prefs!.getString(week.stringId)!;
    Cache cache = Cache.fromString(week.stringId, storedValue);
    if (cache.isValid) addEvents(cache.object);
    return cache.isValid;
  }

  void getEventsFromNetworks(Week week) async {
    final response = await ENSAMRequest.getCalendar(week.firstDay, week.lastDay);
    final List<CalendarEvent> events = List.from(response['events'].map((e) => CalendarEvent.fromENSAMCampus(e)));
    final Cache cache = Cache.create(week.stringId, events);
    prefs!.setString(cache.id, cache.serialized);
    addEvents(events);
  }

  void addEvents(List<CalendarEvent> newEvents) {
    if (IterableEquality().equals(events, newEvents)) return;
    if (events != []) print('new courses');
    newEvents.forEach((event) => !events.contains(event) ? events.add(event) : null);
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              ],
              showDatePickerButton: false,
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
            ),
            Visibility(
              visible: isLoading,
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
    );
  }
}
