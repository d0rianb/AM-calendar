import 'package:flutter/material.dart';
import 'events/calendar-event.dart';

class CalendarItem extends Hero {
  final CalendarEvent event;
  final Size size;
  final bool expanded;

  static const textColorDarkMode = Color(0xd9ffffff);

  CalendarItem(this.event, this.size, this.expanded)
      : super(
          tag: event.id,
          child: Visibility(
            visible: event.shouldDisplay,
            child: DefaultTextStyle(
              style: const TextStyle(
                decoration: TextDecoration.none,
                color: textColorDarkMode,
              ),
              child: Center(
                child: Container(
                  padding: expanded ? const EdgeInsets.all(10.0) : const EdgeInsets.all(2.0),
                  margin: const EdgeInsets.all(0.0),
                  width: size.width,
                  height: size.height,
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: event.color,
                    borderRadius: BorderRadius.all(Radius.circular(expanded ? 6.0 : 3.5)),
                    border: Border.all(color: event.borderColor, width: expanded ? 7.0 : 2.5),
                  ),
                  child: SingleChildScrollView(
                    controller: ScrollController(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          event.course.length > 0 ? event.course : event.subject,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: expanded ? 24 : 10),
                        ),
                        // SizedBox(height: expanded ? 1 : 0),
                        Text(
                          event.formattedLocation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: expanded ? 22 : 9,
                          ),
                        ),
                        // SizedBox(height: expanded ? 1 : 0),
                        Text(
                          event.getTimePeriod(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: expanded ? 22 : 0,
                            fontStyle: FontStyle.italic,
                            color: expanded ? textColorDarkMode : event.color,
                          ),
                        ),
                        // SizedBox(height: expanded ? 3 : 0),
                        Text(
                          event.subject,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: expanded ? 22 : 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
}
