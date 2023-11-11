extension DateTimeHelper<T extends DateTime> on T {
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}

class ICalDateParser {
  static DateTime parse(String datetime) {
    // iCal ex: 20231106T091000
    DateTime parsedDate = DateTime(
      int.parse(datetime.substring(0, 4)),
      int.parse(datetime.substring(4, 6)),
      int.parse(datetime.substring(6, 8)),
      int.parse(datetime.substring(9, 11)),
      int.parse(datetime.substring(11, 13)),
      int.parse(datetime.substring(13, 15)),
    );
    return parsedDate;
  }
}