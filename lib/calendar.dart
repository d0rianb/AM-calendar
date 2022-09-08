import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart' as GoogleCalendar;
import 'package:url_launcher/url_launcher.dart';

import 'events/no-info-event.dart';
import 'events/pals-event.dart';
import 'main.dart' show eventBus;
import 'sfcalendar/lib/calendar.dart';
import 'events/calendar-event.dart';
import 'helpers/requests.dart';
import 'helpers/snackbar.dart';
import 'week.dart';
import 'cache.dart';
import 'events/custom-event.dart';
import 'helpers/datetime-helpers.dart';
import 'helpers/app-events.dart';
import 'credentials.dart';

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
  bool displayNoInfos = false;
  SharedPreferences? prefs;
  bool? _showPals;
  bool? _showCM;
  bool? _showTEAMS;
  bool? _showReunion;

  bool get isLoading => loading || events.length == 0;

  bool get showPals => _showPals ?? prefs?.getBool('showPals') ?? false;

  bool get showCM => _showCM ?? prefs?.getBool('showCM') ?? true;

  bool get showTEAMS => _showTEAMS ?? prefs?.getBool('showTEAMS') ?? true;

  bool get showReunion => _showReunion ?? prefs?.getBool('showReunion') ?? true;

  @override
  void initState() {
    super.initState();
    initSharedPreferences().then((_) => getEvents());
    eventBus.on<ReloadViewEvent>().listen((event) => setState(() {
          _showPals = prefs?.getBool('showPals') ?? false;
          _showCM = prefs?.getBool('showCM') ?? true;
          _showTEAMS = prefs?.getBool('showTEAMS') ?? true;
          _showReunion = prefs?.getBool('showReunion') ?? true;
        }));
    eventBus.on<RecallGetEvent>().listen((event) => getEvents());
    eventBus.on<ExportCalendarEvent>().listen((event) => exportToGoogleCalendar());
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> getEvents() async {
    if (mounted) setState(() => loading = true);
    if (showPals) {
      addEvents(getPals());
      setState(() {});
    } else {
      events = events.where((e) => !(e is CustomEvent && e.type == 'pals')).toList();
    }
    addNoInfoEvents();
    final List<CalendarEvent> cachedEvents = getCachedEvents();
    int addedEventsFromCache = addEvents(cachedEvents);
    if (addedEventsFromCache > 0 && mounted) setState(() => loading = false);
    final List<CalendarEvent> networksEvents = await getEventsFromNetworks(week);
    int addedEventsFromNetwork = addEvents(networksEvents);
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
      pals.add(PalsEvent(subject: 'Pal\'s', startTime: morning, endTime: morning.add(Duration(hours: 1)), prefs: prefs));
      if (i != 2 && i != 4 && i != 9 && i != 11) {
        DateTime evening = morning.copyWith(hour: 19, minute: 15);
        pals.add(PalsEvent(subject: 'Pal\'s', startTime: evening, endTime: evening.add(Duration(hours: 3)), prefs: prefs));
      }
    }
    return pals;
  }

  void addNoInfoEvents() {
    Week secondWeek = week.getNextWeek().getNextWeek();
    Week thirdWeek = secondWeek.getNextWeek();
    List<NoInfoEvent> noInfoEvents = [
      NoInfoEvent(startTime: secondWeek.firstDay, endTime: secondWeek.lastDay),
      NoInfoEvent(startTime: thirdWeek.firstDay, endTime: thirdWeek.lastDay),
    ];
    addEvents(noInfoEvents);
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
    newEvents.forEach((event) => events.where((e) => e.id == event.id).isEmpty ? events.add(event) : null);
    return events.length - oldEventsLength;
  }

  void exportToGoogleCalendar() async {
    const scopes = const [GoogleCalendar.CalendarApi.calendarScope];
    ClientId clientId = new ClientId((Platform.isAndroid) ? OAuthAndroid : OAuthiOS);
    List<GoogleCalendar.Event> gCalendarEvents = events.where((e) => e is CalendarEvent).map((e) => (e as CalendarEvent).exportToGoogleCalendar()).toList();
    AuthClient client = await clientViaUserConsent(clientId, scopes, launch);
    GoogleCalendar.CalendarApi calendarApi = GoogleCalendar.CalendarApi(client);
    String calendarId = 'primary';
    gCalendarEvents.forEach((event) => calendarApi.events.insert(event, calendarId));
  }

  @override
  Widget build(BuildContext context) {
    eventBus.on<RequestErrorEvent>().listen((event) => showSnackBar(context, event.text));
    displayNoInfos = events.where((e) => week.isDayInside(e.startTime)).isEmpty;
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
                const Widget dumbWidget = const Center();
                if (event is CalendarEvent) {
                  if (event.classType.contains('CM') && !showCM) return dumbWidget;
                  if (event.classType.contains('REUNION') && !showReunion) return dumbWidget;
                  if (event.isVisio && !showTEAMS) return dumbWidget;
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
