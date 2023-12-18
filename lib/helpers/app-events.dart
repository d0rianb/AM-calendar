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
  bool finished = false;

  LoginEvent(this.text, { this.finished = false });
}

class RequestErrorEvent {
  String text;

  RequestErrorEvent(this.text);
}

class ThemeChangeEvent {
  ThemeMode theme;

  ThemeChangeEvent(this.theme);
}

// Freeze the calendar swipe when hovering an event
class FreezeSwipeEvent {
  bool shouldFreeze = false;

  FreezeSwipeEvent(this.shouldFreeze);
}
