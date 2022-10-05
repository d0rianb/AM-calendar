import 'package:shared_preferences/shared_preferences.dart';

void clearAllCache(SharedPreferences prefs) {
  print('Clear all cache');
  prefs.clear();
}

void clearEventCache(SharedPreferences prefs) {
  print('Clear cache events');
  prefs.getKeys().where((key) => key.startsWith('week:')).forEach((eventName) => prefs.remove(eventName));
}
