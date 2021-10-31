import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Week {
  late DateTime firstDay;
  late DateTime lastDay;

  Week(this.firstDay, this.lastDay);

  int get id => this.firstDay.millisecondsSinceEpoch;

  String get stringId => 'week:$id';

  Week.fromDateTime(DateTime day) {
    firstDay = DateTime(day.year, day.month, day.day, 0, 0, 0).subtract(Duration(days: day.weekday - 1));
    lastDay = DateTime(day.year, day.month, day.day, 23, 59, 59).add(Duration(days: 7 - day.weekday));
  }

  Week.fromId(String id) {
    if (!id.startsWith('week:')) throw ErrorHint('Wrong Week id');
    Week.fromDateTime(
        DateTime.fromMicrosecondsSinceEpoch(int.parse(id.replaceAll('week:', '')))
    );
  }

  Week getWorkWeek() {
    DateTime newLastDay = lastDay.subtract(Duration(days: 2));
    return Week(firstDay, newLastDay);
  }

  String format() {
    DateFormat dateTimeFormatter = DateFormat.MMMMEEEEd();
    return 'Week : ${dateTimeFormatter.format(firstDay)} - ${dateTimeFormatter.format(lastDay)}';
  }

  Week getNextWeek() => Week(firstDay.add(Duration(days: 7)), lastDay.add(Duration(days: 7)));
}
