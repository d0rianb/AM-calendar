import 'package:intl/intl.dart';

class Week {
  late DateTime firstDay;
  late DateTime lastDay;

  Week(this.firstDay, this.lastDay);

  int get id => this.firstDay.millisecondsSinceEpoch;

  String get stringId => this.id.toString();

  static Week fromDateTime(DateTime day) {
    DateTime firstDay = day.subtract(Duration(days: day.weekday - 1));
    DateTime lastDay = day.add(Duration(days: 7 - day.weekday));
    return Week(firstDay, lastDay);
  }

  Week getWorkWeek() {
    DateTime newLastDay = lastDay.subtract(Duration(days: 2));
    return Week(firstDay, newLastDay);
  }

  String format() {
    DateFormat dateTimeFormatter = DateFormat.MMMMEEEEd();
    return 'Week : ${dateTimeFormatter.format(firstDay)} - ${dateTimeFormatter.format(lastDay)}';
  }
}
