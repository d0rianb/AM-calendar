import 'package:flutter/material.dart';
import './custom-event.dart';

class NoInfoEvent extends CustomEvent {
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  Color color = Colors.blueGrey;
  Color textColor = Colors.white;
  Color borderColor = Colors.blueGrey;

  bool get isVisible => true;

  NoInfoEvent({
    required this.startTime,
    required this.endTime,
  }) : super(type: 'no-info', subject: 'Pas d\'information disponible', startTime: startTime, endTime: endTime);
}
