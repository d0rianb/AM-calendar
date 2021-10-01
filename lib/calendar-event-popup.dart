import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'calendar-event.dart';
import 'calendar-item.dart';

class CalendarEventPopup extends Dialog {
  final CalendarEvent event;

  CalendarEventPopup(this.event);

  @override
  Widget build(BuildContext context) => CalendarItem(event, Size(MediaQuery.of(context).size.width * 3 / 4, MediaQuery.of(context).size.height / 3), true);
}
