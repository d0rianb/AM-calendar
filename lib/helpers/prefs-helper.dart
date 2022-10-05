import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeMode getThemeMode(SharedPreferences prefs) {
  // return ThemeMode.dark; // for a debug purpose
  switch (prefs.getString('brightness')) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

Brightness getBrightness(SharedPreferences prefs, BuildContext context) {
  switch (getThemeMode(prefs)) {
    case ThemeMode.light:
      return Brightness.light;
    case ThemeMode.dark:
      return Brightness.dark;
    case ThemeMode.system:
      return MediaQuery.of(context).platformBrightness;
  }
}
