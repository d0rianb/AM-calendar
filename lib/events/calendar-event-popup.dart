import 'package:flutter/material.dart';

import 'calendar-event.dart';
import '../calendar-item.dart';

class CalendarEventPopup extends Dialog {
  final CalendarEvent event;

  CalendarEventPopup(this.event);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * 3 / 4;
    final double height = MediaQuery.of(context).size.height / 2.3; // min height
    return CalendarItem(
        event,
        Size(width, height),
        true,
      );
  }
}
