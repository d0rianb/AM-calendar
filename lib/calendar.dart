import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart' show eventBus;
import 'sfcalendar/lib/calendar.dart';
import 'calendar-event.dart';
import 'helpers/requests.dart';
import 'week.dart';
import 'cache.dart';
import 'custom-event.dart';
import 'helpers/datetime-helpers.dart';
import 'helpers/app-events.dart';

const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);
const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);

class Calendar extends StatefulWidget {
  Calendar() : super();

  @override
  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  final CalendarController controller = CalendarController();
  List<Appointment> events = [];
  Week week = Week.fromDateTime(DateTime.now());
  bool loading = false;
  SharedPreferences? prefs;
  bool? _showPals;
  bool? _showCM;

  bool get isLoading => loading || events.length == 0;

  bool get showPals => _showPals ?? prefs?.getBool('showPals') ?? false;

  bool get showCM => _showCM ?? prefs?.getBool('showCM') ?? true;

  @override
  void initState() {
    super.initState();
    initSharedPreferences().then((_) => getEvents());
    eventBus.on<ReloadViewEvent>().listen((event) => setState(() {
      _showPals = prefs?.getBool('showPals') ?? false;
      _showCM = prefs?.getBool('showCM') ?? true;
    }));
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> getEvents() async {
    if (mounted) setState(() => loading = true);
    if (showPals) {
      addEvents(getPals());
      setState(() {});
    } else events = events.where((e) => !(e is CustomEvent && e.type == 'pals')).toList();
    final List<CalendarEvent> cachedEvents = getCachedEvents();
    int addedEventsFromCache = addEvents(cachedEvents);
    if (addedEventsFromCache > 0 && mounted) setState(() => loading = false);
    final List<CalendarEvent> networksEvents = await getEventsFromNetworks(week);
    int addedEventsFromNetwork = addEvents(networksEvents);
    if (addedEventsFromNetwork > 0) print('$addedEventsFromNetwork new events');
    if (mounted) setState(() => loading = false);
  }

  List<CalendarEvent> getCachedEvents() {
    // TODO: filter too old events
    if (prefs == null) return [];
    final Iterable<String> cachedWeeksId = prefs!.getKeys().where((key) => key.startsWith('week:'));
    return cachedWeeksId.map((id) => {'id': id, 'value': prefs!.getString(id)}).map((obj) => Cache.fromString(obj['id']!, obj['value'])).where((cache) => cache.isValid).map((cache) => cache.object).flattened.toList();
  }

  List<CustomEvent> getPals() {
    List<CustomEvent> pals = [];
    for (int i = 0; i < 12; i++) {
      DateTime morning = week.firstDay.add(Duration(days: i)).copyWith(hour: 7, minute: 0);
      pals.add(CustomEvent(type: 'pals', subject: 'Pal\'s', startTime: morning, endTime: morning.add(Duration(hours: 1)), prefs: prefs));
      if (i != 2 && i != 4 && i != 9 && i != 11) {
        DateTime evening = morning.copyWith(hour: 19, minute: 15);
        pals.add(CustomEvent(type: 'pals', subject: 'Pal\'s', startTime: evening, endTime: evening.add(Duration(hours: 3)), prefs: prefs));
      }
    }
    return pals;
  }

  Future<List<CalendarEvent>> getEventsFromNetworks(Week week) async {
    final response = await ENSAMRequest.getCalendar(week.firstDay, week.getNextWeek().lastDay);
    final List<CalendarEvent> events = List.from(response['events'].map((e) => CalendarEvent.fromENSAMCampus(e)));
    final Cache cache = Cache.create(week.stringId, events);
    prefs!.setString(cache.id, cache.serialized);
    return events;
  }

  /// Return the number of events added
  int addEvents(List<Appointment> newEvents) {
    if (IterableEquality().equals(events, newEvents)) return 0;
    int oldEventsLength = events.length;
    newEvents.forEach((event) => !events.contains(event) ? events.add(event) : null);
    return events.length - oldEventsLength;
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
              timeSlotViewSettings: TimeSlotViewSettings(
                timeInterval: const Duration(minutes: 60),
                timeIntervalHeight: 45,
                timeFormat: 'Hm',
                startHour: 7,
                endHour: showPals ? 22 : 19,
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
                dynamic event = details.appointments.first;
                if (event is CalendarEvent && event.classType == 'CM') {
                  if (!showCM) return Container();
                }
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
