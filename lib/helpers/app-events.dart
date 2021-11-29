class ReloadViewEvent {
  ReloadViewEvent();
}

class LoginEvent {
  String text;
  bool? finished = false;
  bool? error = false;

  LoginEvent(this.text, {this.finished, this.error});
}