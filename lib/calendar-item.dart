import 'package:flutter/material.dart';
import 'events/calendar-event.dart';

class CalendarItem extends Hero {
  final CalendarEvent event;
  final Size size;
  final bool expanded;

  static const textColorDarkMode = Color(0xd9ffffff);

  static const nullPadding = EdgeInsets.all(0.0);
  static const largePadding = EdgeInsets.only(top: 16.0, bottom: 16.0);
  static const regularPadding = EdgeInsets.only(top: 4.0, bottom: 4.0);

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
                child: FittedBox(
                  child: Container(
                    padding: expanded ? const EdgeInsets.all(10.0) : const EdgeInsets.all(2.0),
                    margin: const EdgeInsets.all(0.0),
                    width: size.width,
                    height: expanded ? null : size.height,
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: expanded ? largePadding : nullPadding,
                            child: Text(
                              event.course.length > 0 ? event.course : event.subject,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: expanded ? 24 : 10),
                            ),
                          ),
                          // SizedBox(height: expanded ? 1 : 0),
                          Padding(
                            padding: (expanded && event.formattedLocation.length > 0) ? largePadding : regularPadding,
                            child: Text(
                              event.formattedLocation,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: expanded ? 22 : 9,
                              ),
                            ),
                          ),
                          // The elements that are not visible when the widget is not expanded
                          Visibility(visible: expanded, child: Column(
                            children: [
                              Padding(
                                padding: expanded ? regularPadding : nullPadding,
                                child: Text(
                                  event.getTimePeriod() + '  (${event.duration})',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontStyle: FontStyle.italic,
                                    color: textColorDarkMode,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: expanded ? regularPadding : nullPadding,
                                child: Text(
                                  event.group,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              Padding(
                                padding: expanded ? regularPadding : nullPadding,
                                child: Text(
                                  event.subject,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ],
                          ))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
}
