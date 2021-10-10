import 'dart:convert';

import 'package:intl/intl.dart';

import 'calendar-event.dart';

typedef JSON = Map<String, dynamic>;
const cacheInvalidationDuration = const Duration(days: 2);
final DateFormat dateParser = new DateFormat("yyyy-MM-dd'T'HH:mm:ssZ");

class Cache {
  String id;
  DateTime age;
  List<CalendarEvent> object;

  Cache(this.id, this.object, this.age);

  static Cache create(String id, List<CalendarEvent> object) => Cache(id, object, DateTime.now());

  String get serialized => jsonEncode({
        'age': age.toIso8601String(),
        'content': List.from(object.map((e) => e.toJSON()), growable: false),
      });

  bool get isValid => Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - age.millisecondsSinceEpoch) <= cacheInvalidationDuration;

  void update(List<CalendarEvent> object) {
    this.object = object;
    this.age = DateTime.now();
  }

  static Cache fromString(String key, String str) {
    var decodedString = jsonDecode(str);
    Iterable parsedContent = decodedString['content'].map((e) => CalendarEvent.fromJSON(jsonDecode(e)));
    return Cache(key, List.from(parsedContent), dateParser.parse(decodedString['age']));
  }
}
