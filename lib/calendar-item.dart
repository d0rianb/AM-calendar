import 'package:flutter/material.dart';
import 'calendar-event.dart';

class CalendarItem extends Hero {
  final CalendarEvent event;
  final Size size;
  final bool expanded;

  CalendarItem(this.event, this.size, this.expanded)
      : super(
          tag: event.title,
          child: DefaultTextStyle(
            style: TextStyle(decoration: TextDecoration.none),
            child: Center(
              child: Container(
                padding: expanded ? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0) : const EdgeInsets.all(5.0),
                margin: const EdgeInsets.all(0.0),
                width: size.width,
                height: size.height,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: event.color,
                  borderRadius: BorderRadius.all(Radius.circular(expanded ? 6.0 : 3.5)),
                  boxShadow: expanded
                      ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: -2,
                            blurRadius: 10,
                            offset: Offset.zero,
                          )
                        ]
                      : null,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.course,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: expanded ? 24 : 11,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: expanded ? 20 : 1),
                      Text(
                        event.location ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: expanded ? 22 : 10,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: expanded ? 5 : 1),
                      Text(
                        event.getTimePeriod(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          color: expanded ? Colors.white : event.color,
                        ),
                      ),
                      // SizedBox(height: expanded ? 10 : 1),
                      // Text(
                      //   event.subject,
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //     fontSize: expanded ? 22 : 0,
                      //     color: Colors.white,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
}
