class ReloadViewEvent {
  ReloadViewEvent();
}

class RecallGetEvent {
  RecallGetEvent();
}

class ExportCalendarEvent {
  ExportCalendarEvent();
}

class LoginEvent {
  String text;
  bool? finished = false;
  bool? error = false;

  LoginEvent(this.text, {this.finished, this.error});
}
