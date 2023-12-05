import 'package:flutter/material.dart';
import 'events/calendar-event.dart';

class CalendarItem extends Hero {
  final CalendarEvent event;
  final Size size;
  final Size contextSize;
  final bool expanded;

  static const textColorDarkMode = Color(0xd9ffffff);

  static const nullPadding = EdgeInsets.all(0.0);
  static const largePadding = EdgeInsets.only(top: 16.0, bottom: 16.0);
  static const regularPadding = EdgeInsets.only(top: 4.0, bottom: 4.0);

  CalendarItem(this.event, this.size, this.contextSize, this.expanded)
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
                child: ConstrainedBox(
                constraints: new BoxConstraints(maxHeight: contextSize.height * 0.9),
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
                                maxLines: expanded ? null : 4, // The text is truncated after 4 lines when not expanded
                                overflow: expanded ? null : TextOverflow.ellipsis,
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white70),
                                      borderRadius: const BorderRadius.all(Radius.circular(100.0)), // radius of 50%
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                                      child: Text(
                                        event.group,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70
                                        ),
                                      ),
                                    ),
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
          ),
        );
}
