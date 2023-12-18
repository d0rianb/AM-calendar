import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import 'cache.dart';
import 'events/calendar-event.dart';
import 'events/custom-event.dart';
import 'events/no-info-event.dart';
import 'events/pals-event.dart';
import 'helpers/app-events.dart';
import 'helpers/datetime-helpers.dart';
import 'helpers/prefs-helper.dart';
import 'helpers/refresh-indicator.dart';
import 'helpers/requests.dart';
import 'helpers/snackbar.dart';
import 'main.dart' show eventBus;
import 'sfcalendar/calendar.dart';
import 'week.dart';

const Color ORANGE = Color.fromRGBO(230, 151, 54, 1.0);
const Color VIOLET = Color.fromRGBO(130, 44, 96, 1.0);

class Calendar extends StatefulWidget {
  final SharedPreferences prefs;

  Calendar(this.prefs) : super();

  @override
  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  final CalendarController controller = CalendarController();
  ViewNavigationMode calendarViewNavigationMode = ViewNavigationMode.snap; // To disable swipe when selecting event
  late SharedPreferences prefs = widget.prefs;
  List<Appointment> events = [];
  List<String> filters = [];
  String error = '';
  Week week = Week.fromDateTime(DateTime.now());
  bool loading = false;
  bool displayNoInfos = false;
  bool? _showPals;
  bool? _showCM;
  bool? _showTEAMS;
  bool? _applyFilters;

  bool get isLoading => loading || events.length == 0;

  bool get showPals => _showPals ?? prefs.getBool('showPals') ?? false;

  bool get showCM => _showCM ?? prefs.getBool('showCM') ?? true;

  bool get showTEAMS => _showTEAMS ?? prefs.getBool('showTEAMS') ?? true;

  bool get applyFilters => _applyFilters ?? prefs.getBool('applyFilters') ?? true;

  @override
  void initState() {
    super.initState();
    initStreams();
    loadFilters();
    getEvents();
  }

  void initStreams() {
    eventBus.on<RequestErrorEvent>().listen((event) {
      error = event.text;
      loading = false;
    });
    eventBus.on<RecallGetEvent>().listen((event) => reloadEvents());
    eventBus.on<ReloadViewEvent>().listen(
        (event) => setState(() {
          _showPals = prefs.getBool('showPals') ?? false;
          _showCM = prefs.getBool('showCM') ?? true;
          _showTEAMS = prefs.getBool('showTEAMS') ?? true;
          _applyFilters = prefs.getBool('applyFilters') ?? true;
          loadFilters();
      }),
    );
    eventBus.on<FreezeSwipeEvent>().listen((event) {
      if (event.shouldFreeze) { setState(() => calendarViewNavigationMode = ViewNavigationMode.none); }
      else { setState(() => calendarViewNavigationMode = ViewNavigationMode.snap); }
    });
  }

  void loadFilters() {
    String filtersString = prefs.getString('filters') ?? '';
    filters = filtersString.split(',').map((filter) => filter.toLowerCase()).where((filter) => filter.isNotEmpty).toList();
  }

  /// Callback for the reload button
  void reloadEvents() async {
    StreamSubscription loginEventHandler = eventBus.on<LoginEvent>().listen((event) => error = event.text);
    setState(() => error = 'Mise à jour du calendrier ...'); // use the error variable the propagate the snackbar to the build method
    await getEvents();
    setState(() => error = 'Calendrier à jour');
    // The login events should only be displayed when the reload is required, otherwise, it should happens in the background so the stream handler has to be canceled
    loginEventHandler.cancel();
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
    int oldEventsLength = events.length;
    addEvents(cachedEvents);
    bool hasAddedEventFromCache = events.length - oldEventsLength != 0;
    if (mounted && hasAddedEventFromCache) setState(() => loading = false); // Update the view
    final List<CalendarEvent> networksEvents = await getEventsFromNetworks(week);
    addEvents(networksEvents);
    if (mounted) setState(() => loading = false);
  }

  List<CalendarEvent> getCachedEvents() {
    final Iterable<String> cachedWeeksId = prefs.getKeys().where((key) => key.startsWith('week:'));
    return cachedWeeksId
        .map((id) => {'id': id, 'value': prefs.getString(id)})
        .map((obj) => Cache.fromString(obj['id']!, obj['value']))
        .where((cache) => cache.isValid)
        .map((cache) => cache.object)
        .flattened
        .toList();
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
    List<CalendarEvent> events = [];

    final iCalResponse = await ICalRequest.getCalendar();
    if (!iCalResponse.containsKey('data')) { return []; }
    events = List.from(iCalResponse['data'].map((e) => CalendarEvent.fromICal(e)));

    final Cache cache = Cache.create(week.stringId, events);
    prefs.setString(cache.id, cache.serialized);
    return events;
  }

  /// Return the number of events added
  void addEvents(List<Appointment> newEvents) {
    // Find the time period of the update
    DateTime startTime = DateTime(3000);
    DateTime endTime = DateTime(2000);
    for (Appointment event in newEvents) {
      if (event.startTime.isBefore(startTime)) startTime = event.startTime;
      if (event.endTime.isAfter(endTime)) endTime = event.endTime;
    }
    events = events.where((event) => event.endTime.isBefore(startTime) || event.startTime.isAfter(endTime)).toList();
    events += newEvents; // add the new events
    events = LinkedHashSet<Appointment>.from(events).toList(); // Delete repetitions
  }

  bool isFiltered(CalendarEvent event) {
    bool isFiltered = false;
    String title = event.title.toLowerCase();
    for (String filter in filters) {
      if (title.contains(filter)) {
        isFiltered = true;
        break;
      }
    }
    return isFiltered;
  }

  @override
  Widget build(BuildContext context) {
    displayNoInfos = events.where((e) => week.isDayInside(e.startTime)).isEmpty;
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    if (!isDarkMode) {
      // Set the status bar (hour, wifi, etc) in dark
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
    if (error != '') {
      showSnackBar(context, error);
      error = '';
    }
    return Stack(
      children: [
        SfCalendarTheme(
          data: SfCalendarThemeData(
            brightness: getBrightness(prefs, context),
            backgroundColor: theme.colorScheme.background,
            selectionBorderColor: ORANGE,
            cellBorderColor: isDarkMode ? Colors.white12 : Colors.black12,
            headerTextStyle: TextStyle(fontSize: 20, color: ORANGE),
            todayTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.background,
            ),
            timeTextStyle: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.7), fontWeight: FontWeight.w500, fontSize: 10),
          ),
          child: SfCalendar(
            view: CalendarView.workWeek,
            viewNavigationMode: calendarViewNavigationMode,
            controller: controller,
            dataSource: AppointmentDataSource(events),
            allowedViews: [
              CalendarView.day,
              CalendarView.workWeek,
            ],
            showDatePickerButton: false,
            timeZone: 'W. Europe Standard Time',
            todayHighlightColor: ORANGE,
            timeSlotViewSettings: TimeSlotViewSettings(
              timeInterval: const Duration(minutes: 60),
              timeIntervalHeight: -1,
              timeFormat: 'Hm',
              startHour: 7,
              endHour: showPals ? 22 : 19,
            ),
            viewHeaderStyle: ViewHeaderStyle(
              dayTextStyle: TextStyle(
                fontSize: 12,
                color: theme.textTheme.titleMedium?.color,
                fontWeight: FontWeight.w500,
              ),
              dateTextStyle: const TextStyle(
                fontSize: 15,
                color: ORANGE,
                fontWeight: FontWeight.w600,
              ),
            ),
            headerStyle: const CalendarHeaderStyle(textAlign: TextAlign.center),
            headerDateFormat: 'MMMM yyy',
            showCurrentTimeIndicator: true,
            appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
              dynamic event = details.appointments.first;
              const Widget dumbWidget = const Center(); // Empty widget
              if (event is CalendarEvent) {
                if (!showCM && event.classType.contains('CM')) return dumbWidget;
                if (applyFilters && isFiltered(event)) return dumbWidget;
                if (!showTEAMS && event.isVisio) return dumbWidget;
              }
              return event.build(context, details.bounds.size);
            },
          ),
        ),
        Visibility(
          // Loader
          visible: isLoading,
          child: Positioned(
            top: 75,
            left: MediaQuery.of(context).size.width / 2 - 25,
            width: 50,
            height: 50,
            child: ShadowedRefreshIndicator(color: theme.primaryColor),
          ),
        ),
      ],
    );
  }
}
