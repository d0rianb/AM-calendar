import 'package:flutter/material.dart';

import 'calendar-event.dart';
import '../calendar-item.dart';

class CalendarEventPopup extends Dialog {
  final CalendarEvent event;

  CalendarEventPopup(this.event);

  @override
  Widget build(BuildContext context) {
    final Size contextSize = MediaQuery.of(context).size;
    final double width = contextSize.width * 3 / 4;
    final double height = contextSize.height / 2.3; // min height
    return Center(
      child: event.isAllDay ?  AllDayCalendarItem(event, Size(width, height), true) : CalendarItem(event, Size(width, height), true),
    );
  }
}
