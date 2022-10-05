import 'package:flutter/material.dart';

class ReloadViewEvent {
  ReloadViewEvent();
}

class RecallGetEvent {
  RecallGetEvent();
}

class ExportCalendarEvent {
  ExportCalendarEvent();
}

class DeleteCachedEvents {
  DeleteCachedEvents();
}

class DeleteAllCacheEvent {
  DeleteAllCacheEvent();
}

class LoginEvent {
  String text;
  bool? finished = false;
  bool? error = false;

  LoginEvent(this.text, {this.finished, this.error});
}

class RequestErrorEvent {
  String text;

  RequestErrorEvent(this.text);
}

class ThemeChangeEvent {
  ThemeMode theme;

  ThemeChangeEvent(this.theme);
}
