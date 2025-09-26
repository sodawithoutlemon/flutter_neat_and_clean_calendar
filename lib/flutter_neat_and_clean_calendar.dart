// ignore_for_file: deprecated_member_use_from_same_package, deprecated_member_use

library flutter_neat_and_clean_calendar;

import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/date_picker_config.dart';
import 'package:flutter_neat_and_clean_calendar/provider_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import './date_utils.dart';
import './simple_gesture_detector.dart';
import './calendar_tile.dart';
import './neat_and_clean_calendar_event.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Export NeatCleanCalendarEvent for using it in the application
export './neat_and_clean_calendar_event.dart';

typedef DayBuilder(BuildContext context, DateTime day);
typedef EventListBuilder(
    BuildContext context, List<NeatCleanCalendarEvent> events);
typedef EventCellBuilder(BuildContext context, NeatCleanCalendarEvent event,
    String start, String end);

enum DatePickerType { hidden, year, date }

class Range {
  final DateTime from;
  final DateTime to;
  Range(this.from, this.to);
}

/// Clean Calndar's main class [Calendar]
///
/// This calls is responisble for controlling the look of the calnedar display as well
/// as the action taken, when changing the month or tapping a date. It's higly configurable
/// with its numerous properties.
///
/// [onDateSelected] is of type [ValueChanged<DateTime>] and it containes the callback function
///     extecuted when tapping a date
/// [onMonthChanged] is of type [ValueChanged<DateTime>] and it containes the callback function
///     extecuted when changing to another month
/// [onExpandStateChanged] is of type [ValueChanged<bool>] and it contains a callback function
///     executed when the view changes to expanded or to condensed
/// [onRangeSelected] contains a callback function of type [ValueChanged], that gets called on changes
///     of the range (switch to next or previous week or month)
/// [onEventSelected] is of type [ValueChanged<NeatCleanCalendarEvent>] and it contains a callback function
///     executed when an event of the event list is selected
/// [onEventLongPressed] is of type [ValueChanged<NeatCleanCalendarEvent>] and it contains a callback function
///     executed when an event of the event list is long pressed
/// [onListViewStateChanged] is of type [ValueChanged] and it contains a callback function
///    executed when the list view state changes
/// [onEventsUpdated] is of type [ValueChanged<Map<DateTime, List<NeatCleanCalendarEvent>>] and it contains a callback function
///    executed when the events are updated
/// [datePickerType] defines, if the date picker should get displayed and selects its type
///    Choose between datePickerType.hidden, datePickerType.year, datePickerType.date
/// [isExpandable] is a [bool]. With this parameter you can control, if the view can expand from week view
///     to month view. Default is [false].
/// [dayBuilder] can contain a [Widget]. If this property is not null (!= null), this widget will get used to
///     render the calenar tiles (so you can customize the view)
/// [eventListBuilder] can optionally contain a [Widget] that gets used to render the event list
/// [eventCellBuilder] can optionally contain a [Widget] that gets used to render the event cells
/// [hideArrows] is a bool. When set to [true] the arrows to navigate to the next or previous week/month in the
///     top bar well get suppressed. Default is [false].
/// [hideTodayIcon] is a bool. When set to [true] the dispaly of the Today-Icon (button to navigate to today) in the
///     top bar well get suppressed. Default is [false].
/// [events] are of type [Map<DateTime, List<NeatCleanCalendarEvent>>]. This data structure contains the events to display
/// [defaultDayColor] is the color applied to days in the current month, that are not selected.
/// [defaultOutOfMonthDayColor] is the color applied to days outside the current month.
/// [selectedColor] this is the color, applied to the circle on the selected day
/// [selectedTodayColor] is the color, applied to the circle on the selected day, if it is today
/// [todayColor] this is the color of the date of today
/// [topRowIconColor] is the color of the icons in the top bar
/// [datePickerLightTheme] is a [ThemeData] object, that defines the light theme of the date picker.
/// [datePickerDarkTheme] is a [ThemeData] object, that defines the dark theme of the date picker
/// [todayButtonText] is a [String]. With this property you can set the caption of the today icon (button to navigate to today).
///     If left empty, the calendar will use the string "Today".
/// [allDayEventText] is a [String]. With this property you can set the caption of the all day event. If left empty, the
///     calendar will use the string "All day".
/// [multiDayEndText] is a [String]. With this property you can set the caption of the end of a multi day event. If left empty, the
///    calendar will use the string "End".
/// [eventColor] lets you optionally specify the color of the event (dot). If the [CleanCaendarEvents] property color is not set, the
///     calendar will use this parameter.
/// [eventDoneColor] with this property you can define the color of "done" events, that is events in the past.
/// [initialDate] is of type [DateTime]. It can contain an optional start date. This is the day, that gets initially selected
///     by the calendar. The default is to not set this parameter. Then the calendar uses [DateTime.now()]
/// [isExpanded] is a bool. If is us set to [true], the calendar gets rendered in month view.
/// [weekDays] contains a [List<String>] defining the names of the week days, so that it is possible to name them according
///     to your current locale.
/// [locale] is a [String]. This setting gets used to format dates according to the current locale.
/// [startOnMonday] is a [bool]. This parameter allows the calendar to determine the first day of the week.
/// [dayOfWeekStyle] is a [TextStyle] for styling the text of the weekday names in the top bar.
/// [bottomBarTextStyle] is a [TextStyle], that sets the style of the text in the bottom bar.
/// [bottomBarArrowColor] can set the [Color] of the arrow to expand/compress the calendar in the bottom bar.
/// [bottomBarColor] sets the [Color] of the bottom bar
/// [expandableDateFormat] defines the formatting of the date in the bottom bar
/// [displayMonthTextStyle] is a [TextStyle] for styling the month name in the top bar.
/// [datePickerConfig] is a [DatePickerConfig] object. It contains the configuration of the date picker, if enabled.
/// [showEvents] is a [bool]. This parameter allows the calender to show listed events. Default value is set to [true], but the user can hide the events entirely by setting it to [false]

// The library internnaly will use a Map<DateTime, List<NeatCleanCalendarEvent>> for the events.

class Calendar extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onMonthChanged;
  final ValueChanged<bool>? onExpandStateChanged;
  final ValueChanged? onRangeSelected;
  final ValueChanged<NeatCleanCalendarEvent>? onEventSelected;
  final ValueChanged<NeatCleanCalendarEvent>? onEventLongPressed;
  final ValueChanged? onListViewStateChanged;
  final ValueChanged<Map<DateTime, List<NeatCleanCalendarEvent>>>?
      onEventsUpdated;
  final ValueChanged<String>? onPrintLog;
  final ValueChanged<DateTime>? onTodayButtonPressed;
  final bool isExpandable;
  final DayBuilder? dayBuilder;
  final EventListBuilder? eventListBuilder;
  final EventCellBuilder? eventCellBuilder;
  final DatePickerType? datePickerType;
  final bool hideArrows;
  final bool hideTodayIcon;
  final List<NeatCleanCalendarEvent>? eventsList;
  final Color? defaultDayColor;
  final Color? defaultOutOfMonthDayColor;
  final Color? selectedColor;
  final Color? selectedTodayColor;
  final Color? todayColor;
  final Color? topRowIconColor;
  final ThemeData? datePickerLightTheme;
  final ThemeData? datePickerDarkTheme;
  final String todayButtonText;
  final String allDayEventText;
  final String multiDayEndText;
  final Color? eventColor;
  final Color? eventDoneColor;
  final DateTime? initialDate;
  final bool isExpanded;
  final List<String> weekDays;
  final String? locale;
  final bool startOnMonday;
  final TextStyle? dayOfWeekStyle;
  final TextStyle? bottomBarTextStyle;
  final Color? bottomBarArrowColor;
  final Color? bottomBarColor;
  final String? expandableDateFormat;
  final TextStyle? displayMonthTextStyle;
  final DatePickerConfig? datePickerConfig;
  final double? eventTileHeight;
  final bool showEvents;
  final bool forceEventListView;
  final bool showEventListViewIcon;

  /// Configures the date picker if enabled

  Calendar(
      {this.onMonthChanged,
      this.onDateSelected,
      this.onRangeSelected,
      this.onExpandStateChanged,
      this.onEventSelected,
      this.onEventLongPressed,
      this.onListViewStateChanged,
      this.onEventsUpdated,
      this.onPrintLog,
      this.onTodayButtonPressed,
      this.isExpandable = false,
      this.eventsList,
      this.dayBuilder,
      this.eventListBuilder,
      this.eventCellBuilder,
      this.datePickerType = DatePickerType.hidden,
      this.hideTodayIcon = false,
      this.hideArrows = false,
      this.defaultDayColor = Colors.black87,
      this.defaultOutOfMonthDayColor,
      this.selectedColor = Colors.pink,
      this.selectedTodayColor,
      this.todayColor = Colors.blue,
      this.topRowIconColor = Colors.blue,
      this.datePickerLightTheme,
      this.datePickerDarkTheme,
      this.todayButtonText = 'Today',
      this.allDayEventText = 'All Day',
      this.multiDayEndText = 'End',
      this.eventColor,
      this.eventDoneColor,
      this.initialDate,
      this.isExpanded = false,
      this.weekDays = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      this.locale = 'us_US',
      this.startOnMonday = false,
      this.dayOfWeekStyle,
      this.bottomBarTextStyle,
      this.bottomBarArrowColor,
      this.bottomBarColor,
      this.expandableDateFormat = 'EEEE MMMM dd, yyyy',
      this.displayMonthTextStyle,
      this.datePickerConfig,
      this.eventTileHeight,
      this.forceEventListView = false,
      this.showEventListViewIcon = true,
      this.showEvents = true});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final calendarUtils = Utils();
  late List<DateTime> selectedMonthsDays;
  late Iterable<DateTime> selectedWeekDays;
  late Map<DateTime, List<NeatCleanCalendarEvent>>? eventsMap;
  // selectedDate is the date, that is currently selected. It is highlighted with a circle.
  DateTime _selectedDate = DateTime.now();
  String? currentMonth;
  late bool isExpanded;
  late bool forceEventListView;
  bool _didScroll = false;
  String displayMonth = '';
  DateTime get selectedDate => _selectedDate;
  List<NeatCleanCalendarEvent>? _selectedEvents;
  bool isDarkMode = false;
  late ScrollController _scrollController;
  late List<dynamic> itemList = [];

  @override
  void initState() {
    super.initState();

    isExpanded = widget.isExpanded;

    forceEventListView = widget.forceEventListView;

    _selectedDate = widget.initialDate ?? DateTime.now();
    if (widget.locale != null) {
      initializeDateFormatting(widget.locale, null).then((_) {
        if (mounted) {
          setState(() {
            var monthFormat =
                DateFormat('MMMM yyyy', widget.locale).format(_selectedDate);
            displayMonth =
                '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
          });
        }
      }).catchError((error) {
        widget.onPrintLog != null
            ? widget.onPrintLog!('Error initializing date formatting: $error')
            : print('Error initializing date formatting: $error');
      });
    } else {
      widget.onPrintLog != null
          ? widget.onPrintLog!('widget.locale is null')
          : print('widget.locale is null');
    }
    // When setting the initial date, the eventsmap must be updated. The eventsmap is used to
    // store the events for each day. The eventsmap is used to display the events in the calendar.
    // It is basically the internal store of the events. Because the events are passed as a list
    // to the calendar, the eventsmap must be created from the list. This is done in the
    // _updateEventsMap method.
    _updateEventsMap();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Überprüfen, ob die neuen Events sich von den alten unterscheiden
    _updateEventsMap();
  }

  /// Scrolls the list view to the top if the event list view is shown.
  ///
  /// This method animates the scroll position to 0.0 (the top) using the [_scrollController].
  /// The animation has a duration of 300 milliseconds and uses the [Curves.easeInOut] animation effect.
  void scrollToTop() {
    // Only scroll to top if the event list view is shown
    if (forceEventListView == false) return;
    _scrollController.animateTo(
      0.0, // Die Scroll-Position (0.0 ist ganz oben)
      duration: Duration(milliseconds: 300), // Dauer der Animation
      curve: Curves.easeInOut, // Animationseffekt
    );
    _didScroll = true;
  }

  /// Scrolls the list view to the specified [index].
  ///
  /// This method is used to scroll the calendar to a specific index in the event list view.
  /// It only scrolls to the top if the event list view is currently shown.
  /// The [index] parameter represents the position in the list, and it is multiplied by 60.0
  /// to calculate the scroll position in pixels.
  /// The scroll animation has a duration of 300 milliseconds and uses the ease-in-out curve.
  void scrollToIndex(int index) {
    // Only scroll to top if the event list view is shown
    if (forceEventListView == false) return;
    double position =
        index * 60.0; // Annahme: Höhe eines Listenelements = 60.0 Pixel

    _scrollController.animateTo(
      position,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _didScroll = true;
  }

  int findClosestIndex(DateTime currentDate) {
    int closestIndex = -1;
    int minDifference = double.maxFinite.toInt(); // Eine sehr große Zahl

    for (int i = 0; i < itemList.length; i++) {
      if (itemList[i] is DateTime) {
        DateTime eventDate = itemList[i] as DateTime;

        // Berechne die Differenz in Tagen zwischen dem Event-Datum und dem aktuellen Datum
        int difference = (eventDate.difference(currentDate).inDays).abs();

        if (difference < minDifference) {
          minDifference = difference;
          closestIndex = i;
        }

        // Wenn das Event genau am aktuellen Datum stattfindet, direkt zurückgeben
        if (eventDate.year == currentDate.year &&
            eventDate.month == currentDate.month &&
            eventDate.day == currentDate.day) {
          return i;
        }
      }
    }

    return closestIndex;
  }

  /// The method [_updateEventsMap] has the purpose to update the eventsMap, when the calendar widget
  /// is initiated. When this method executes, it fills the eventsMap with the contents of the
  /// given eventsList. This can be used to update the events shown by the calendar.
  /// This is done in the initState method.
  void _updateEventsMap() {
    eventsMap = {};
    // If the user provided a list of events, then convert it to a map, but only if there
    // was no map of events provided. To provide the events in form of a map is the way,
    // the library worked before the v0.3.x release. In v0.3.x the possibility to provide
    // the eventsList property was introduced. This simplifies the handaling. In v0.4.0 the
    // property events (the map) will get removed.
    // Here the library checks, if a map was provided. You can not provide a list and a map
    // at the same time. In that case the map will be used, while the list is omitted.
    if (widget.eventsList != null &&
        widget.eventsList!.isNotEmpty &&
        eventsMap != null &&
        eventsMap!.isEmpty) {
      widget.eventsList!.forEach((event) {
        int range = event.endTime.difference(event.startTime).inDays;

        // Check if the end time is before the start time and adjust the calculation.
        if (event.endTime.hour < event.startTime.hour ||
            (event.endTime.hour == event.startTime.hour &&
                event.endTime.minute < event.startTime.minute)) {
          range += 1; // Add one day because the end time is earlier.
        }
        // Event starts and ends on the same day.
        if (range == 0) {
          List<NeatCleanCalendarEvent> dateList = eventsMap![DateTime(
                  event.startTime.year,
                  event.startTime.month,
                  event.startTime.day)] ??
              [];
          // Just add the event to the list.
          eventsMap![DateTime(event.startTime.year, event.startTime.month,
              event.startTime.day)] = dateList..add(event);
        } else {
          for (var i = 0; i <= range; i++) {
            List<NeatCleanCalendarEvent> dateList = eventsMap![DateTime(
                    event.startTime.year,
                    event.startTime.month,
                    event.startTime.day + i)] ??
                [];
            // Iteration over the range (difference between start and end time in days).
            NeatCleanCalendarEvent newEvent = NeatCleanCalendarEvent(
                event.summary,
                description: event.description,
                location: event.location,
                color: event.color,
                isAllDay: event.isAllDay,
                isDone: event.isDone,
                icon: event.icon,
                // Multi-day events span over several days. They have a start time on the first day
                // and an end time on the last day.  All-day events don't have a start time and end time
                // So if an event ist an all-day event, the multi-day property gets set to false.
                // If the event is not an all-day event, the multi-day property gets set to true, because
                // the difference between
                isMultiDay: event.isAllDay ? false : true,
                // Event spans over several days, but entreis in the list can only cover one
                // day, so the end date of one entry must be on the same day as the start.
                multiDaySegement: MultiDaySegement.first,
                startTime: DateTime(
                    event.startTime.year,
                    event.startTime.month,
                    event.startTime.day + i,
                    event.startTime.hour,
                    event.startTime.minute),
                endTime: DateTime(
                    event.startTime.year,
                    event.startTime.month,
                    event.startTime.day + i,
                    event.endTime.hour,
                    event.endTime.minute),
                // Pass the metadata to the new event.
                metadata: event.metadata,
                id: event.id,
                wide: event.wide);

            if (i == 0) {
              // First day of the event.
              newEvent.multiDaySegement = MultiDaySegement.first;
            } else if (i == range) {
              // Last day of the event.
              newEvent.multiDaySegement = MultiDaySegement.last;
            } else {
              // Middle day of the event.
              newEvent.multiDaySegement = MultiDaySegement.middle;
            }
            eventsMap![DateTime(event.startTime.year, event.startTime.month,
                event.startTime.day + i)] = dateList..add(newEvent);
          }
        }
      });
    }
    selectedMonthsDays = _daysInMonth(_selectedDate);
    selectedWeekDays = Utils.daysInRange(
            _firstDayOfWeek(_selectedDate), _lastDayOfWeek(_selectedDate))
        .toList();

    _selectedEvents = eventsMap?[DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
        [];

    widget.onPrintLog != null
        ? widget.onPrintLog!('eventsMap has ${eventsMap?.length} entries')
        : print('eventsMap has ${eventsMap?.length} entries');

    // If the eventsMap is updated, the eventsUpdated callback is invoked. In some cases it is useful
    // to have a copy of the eventsMap in the parent widget. This can be done by providing a callback
    // method to the calendar widget.
    if (widget.onEventsUpdated != null && eventsMap != null) {
      widget.onEventsUpdated!(eventsMap!);
    }
  }

  Widget get nameAndIconRow {
    var todayIcon;
    var leftArrow;
    var rightArrow;
    var jumpDateIcon;

    if (!widget.hideArrows) {
      leftArrow = PlatformIconButton(
        onPressed: isExpanded ? () => previousMonth(true) : previousWeek,
        icon: Icon(
          Icons.chevron_left,
          color: widget.topRowIconColor,
        ),
      );
      rightArrow = PlatformIconButton(
        onPressed: isExpanded ? () => nextMonth(true) : nextWeek,
        icon: Icon(
          Icons.chevron_right,
          color: widget.topRowIconColor,
        ),
      );
    } else {
      leftArrow = Container();
      rightArrow = Container();
    }

    if (!widget.hideTodayIcon) {
      todayIcon = Text(widget.todayButtonText,
          style: widget.displayMonthTextStyle ?? null);
    } else {
      todayIcon = Container();
    }

    jumpDateIcon = Container();

    if (widget.datePickerType != null &&
        widget.datePickerType != DatePickerType.hidden) {
      jumpDateIcon = PlatformIconButton(
        onPressed: () {
          showDatePicker(
                  builder: (BuildContext context, Widget? child) {
                    // Define Light Theme
                    ThemeData lightTheme = widget.datePickerLightTheme ??
                        ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.blue,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        );

                    // Define Dark Theme
                    ThemeData darkTheme = widget.datePickerDarkTheme ??
                        ThemeData.dark().copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: Colors.blue,
                            onPrimary: Colors.white,
                            surface: Colors.grey,
                            onSurface: Colors.white,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.yellow,
                            ),
                          ),
                        );

                    // Choose the theme based on the current mode
                    return Theme(
                      data: isDarkMode ? darkTheme : lightTheme,
                      child: child!,
                    );
                  },
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  initialDatePickerMode:
                      widget.datePickerType == DatePickerType.date
                          ? DatePickerMode.day
                          : DatePickerMode.year)
              .then((date) {
            if (date != null) {
              // The selected date is printed to the console in ISO 8601 format for debugging purposes.
              // The "onJumpToDateSelected" callback is then invoked with the selected date.
              // These lines have been moved outside of the "setState" block to
              // trigger the callback methods (i.e. onMonthChanged) in the parent widget.
              // After the callback methods are invoked, the "setState" block is called and the
              // _selectedDate is updated. This must be done after the callback methods are invoked,
              // otherwise the callback methods will not trigger, if the current date is equal to the
              // selected date.
              widget.onPrintLog != null
                  ? widget.onPrintLog!(
                      'Date chosen: ${_selectedDate.toIso8601String()}')
                  : print('Date chosen: ${_selectedDate.toIso8601String()}');
              onJumpToDateSelected(date);
              setState(() {
                _selectedDate = date;
                selectedMonthsDays = _daysInMonth(_selectedDate);
                selectedWeekDays = Utils.daysInRange(
                        _firstDayOfWeek(_selectedDate),
                        _lastDayOfWeek(_selectedDate))
                    .toList();
                var monthFormat = DateFormat('MMMM yyyy', widget.locale)
                    .format(_selectedDate);
                displayMonth =
                    '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
                _selectedEvents = eventsMap?[DateTime(_selectedDate.year,
                        _selectedDate.month, _selectedDate.day)] ??
                    [];
              });
            }
          });
        },
        icon: Icon(
          Icons.date_range_outlined,
          color: widget.topRowIconColor,
        ),
      );
    } else {
      jumpDateIcon = Container();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            forceEventListView ? Container() : leftArrow ?? Container(),
            widget.showEventListViewIcon
                ? PlatformIconButton(
                    onPressed: () {
                      setState(() {
                        forceEventListView = !forceEventListView;
                        if (widget.onListViewStateChanged != null) {
                          _didScroll = false;
                          widget.onListViewStateChanged!(forceEventListView);
                        }
                      });
                    },
                    icon: Icon(
                      Icons.list,
                      color: widget.topRowIconColor,
                    ),
                  )
                : Container(),
            Expanded(child: Container()), // Placeholder to balance the Row
            forceEventListView ? Container() : jumpDateIcon ?? Container(),
            forceEventListView ? Container() : rightArrow ?? Container(),
          ],
        ),
        // Zentralisiertes Stack-Widget
        GestureDetector(
            child: Column(children: [
              if (todayIcon != null) todayIcon!,
              Text(
                displayMonth,
                style: widget.displayMonthTextStyle ??
                    TextStyle(
                      fontSize: 20.0,
                    ),
              ),
            ]),
            onTap: () {
              if (widget.onTodayButtonPressed != null) {
                widget.onTodayButtonPressed!(_selectedDate);
              }
              // TOday-Button should only trigger a reset to today, if the event list view is not showwn
              // or if the event list is shown and the ScrollController is connected to the list view.
              if (!forceEventListView ||
                  (forceEventListView && _scrollController.hasClients)) {
                resetToToday();
              }
            }),
      ],
    );
  }

  Widget get calendarGridView {
    return Container(
      child: SimpleGestureDetector(
        onSwipeUp: _onSwipeUp,
        onSwipeDown: _onSwipeDown,
        onSwipeLeft: _onSwipeLeft,
        onSwipeRight: _onSwipeRight,
        swipeConfig: SimpleSwipeConfig(
          verticalThreshold: 10.0,
          horizontalThreshold: 40.0,
          swipeDetectionMoment: SwipeDetectionMoment.onUpdate,
        ),
        child: Column(
          children: <Widget>[
            GridView.count(
              childAspectRatio: 1.5,
              primary: false,
              shrinkWrap: true,
              crossAxisCount: 7,
              padding: EdgeInsets.only(bottom: 0.0),
              children: calendarBuilder(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> calendarBuilder() {
    List<Widget> dayWidgets = [];
    List<DateTime> calendarDays =
        isExpanded ? selectedMonthsDays : selectedWeekDays as List<DateTime>;
    widget.weekDays.forEach(
      (day) {
        dayWidgets.add(
          NeatCleanCalendarTile(
            defaultDayColor: widget.defaultDayColor,
            defaultOutOfMonthDayColor: widget.defaultOutOfMonthDayColor,
            selectedColor: widget.selectedColor,
            selectedTodayColor: widget.selectedTodayColor,
            todayColor: widget.todayColor,
            eventColor: widget.eventColor,
            eventDoneColor: widget.eventDoneColor,
            events: eventsMap![day],
            isDayOfWeek: true,
            dayOfWeek: day,
            dayOfWeekStyle: widget.dayOfWeekStyle ??
                TextStyle(
                  color: widget.selectedColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
          ),
        );
      },
    );

    bool monthStarted = false;
    bool monthEnded = false;

    calendarDays.forEach(
      (day) {
        if (day.hour > 0) {
          day = DateFormat("yyyy-MM-dd HH:mm:ssZZZ")
              .parse(day.toString())
              .toLocal();
          day = day.subtract(new Duration(hours: day.hour));
        }

        if (monthStarted && day.day == 01) {
          monthEnded = true;
        }

        if (Utils.isFirstDayOfMonth(day)) {
          monthStarted = true;
        }

        if (this.widget.dayBuilder != null) {
          // Use the dayBuilder widget passed as parameter to render the date tile
          Widget? customDay; // <-- burayı ekle

          customDay = widget.dayBuilder!(context, day);
            
          if (customDay is! Widget) {
            customDay = null;
          }
        
          dayWidgets.add(
            NeatCleanCalendarTile(
              defaultDayColor: widget.defaultDayColor,
              defaultOutOfMonthDayColor: widget.defaultOutOfMonthDayColor,
              selectedColor: widget.selectedColor,
              selectedTodayColor: widget.selectedTodayColor,
              todayColor: widget.todayColor,
              eventColor: widget.eventColor,
              eventDoneColor: widget.eventDoneColor,
              events: eventsMap![day],
              child: customDay,
              date: day,
              onDateSelected: () => handleSelectedDateAndUserCallback(day),
              dateStyles: (customDay == null)?(configureDateStyle(monthStarted, monthEnded)):null,
              isSelected: (customDay == null)?(Utils.isSameDay(selectedDate, day)):false,
              inMonth: (customDay == null)?(day.month == selectedDate.month):true
            )
          );
        } else {
          dayWidgets.add(
            NeatCleanCalendarTile(
                defaultDayColor: widget.defaultDayColor,
                defaultOutOfMonthDayColor: widget.defaultOutOfMonthDayColor,
                selectedColor: widget.selectedColor,
                selectedTodayColor: widget.selectedTodayColor,
                todayColor: widget.todayColor,
                eventColor: widget.eventColor,
                eventDoneColor: widget.eventDoneColor,
                events: eventsMap![day],
                onDateSelected: () => handleSelectedDateAndUserCallback(day),
                date: day,
                dateStyles: configureDateStyle(monthStarted, monthEnded),
                isSelected: Utils.isSameDay(selectedDate, day),
                inMonth: day.month == selectedDate.month),
          );
        }
      },
    );
    return dayWidgets;
  }

  TextStyle? configureDateStyle(monthStarted, monthEnded) {
    TextStyle? dateStyles;
    final TextStyle? body1Style = Theme.of(context).textTheme.bodyMedium;

    if (isExpanded) {
      final TextStyle body1StyleDisabled = body1Style!.copyWith(
          color: Color.fromARGB(
        100,
        body1Style.color!.red,
        body1Style.color!.green,
        body1Style.color!.blue,
      ));

      dateStyles =
          monthStarted && !monthEnded ? body1Style : body1StyleDisabled;
    } else {
      dateStyles = body1Style;
    }
    return dateStyles;
  }

  Widget get expansionButtonRow {
    if (widget.isExpandable) {
      return GestureDetector(
        onTap: toggleExpanded,
        child: Container(
          color: widget.bottomBarColor ?? Color.fromRGBO(200, 200, 200, 0.2),
          height: 40,
          margin: EdgeInsets.only(top: 8.0),
          padding: EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(width: 40.0),
              Text(
                DateFormat(widget.expandableDateFormat, widget.locale)
                    .format(_selectedDate),
                style: widget.bottomBarTextStyle ?? TextStyle(fontSize: 13),
              ),
              PlatformIconButton(
                onPressed: toggleExpanded,
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                icon: isExpanded
                    ? Icon(
                        Icons.arrow_drop_up,
                        size: 25.0,
                        color: widget.bottomBarArrowColor ?? Colors.black,
                      )
                    : Icon(
                        Icons.arrow_drop_down,
                        size: 25.0,
                        color: widget.bottomBarArrowColor ?? Colors.black,
                      ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Column singleDayTimeWidget(String start, String end) {
    widget.onPrintLog != null
        ? widget.onPrintLog!('SingleDayEvent')
        : print('SingleDayEvent');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(start, style: Theme.of(context).textTheme.bodyLarge),
        Text(end, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Column allOrMultiDayDayTimeWidget(NeatCleanCalendarEvent event) {
    widget.onPrintLog != null
        ? widget.onPrintLog!('=== Summary: ${event.summary}')
        : print('=== Summary: ${event.summary}');
    String start = DateFormat('HH:mm').format(event.startTime).toString();
    String end = DateFormat('HH:mm').format(event.endTime).toString();
    if (event.isAllDay) {
      widget.onPrintLog != null
          ? widget.onPrintLog!('AllDayEvent - ${event.summary}')
          : print('AllDayEvent - ${event.summary}');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.allDayEventText,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      );
    }
    if (event.multiDaySegement == MultiDaySegement.first) {
      // The event begins on the selcted day.
      // Just show the start time, no end time.
      widget.onPrintLog != null
          ? widget.onPrintLog!('MultiDayEvent: start - ${event.summary}')
          : print('MultiDayEvent: start - ${event.summary}');
      end = '';
    } else if (event.multiDaySegement == MultiDaySegement.last) {
      // The event ends on the selcted day.
      // Just show the end time, no start time.
      widget.onPrintLog != null
          ? widget.onPrintLog!('MultiDayEvent: end - ${event.summary}')
          : print('MultiDayEvent: end - ${event.summary}');
      start = widget.multiDayEndText;
    } else {
      // The event spans multiple days.
      widget.onPrintLog != null
          ? widget.onPrintLog!('MultiDayEvent: middle - ${event.summary}')
          : print('MultiDayEvent: middle - ${event.summary}');
      start = widget.allDayEventText;
      end = '';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(start, style: Theme.of(context).textTheme.bodyLarge),
        Text(end, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // If _selectedEvents is not null, then we sort the events by isAllDay propeerty, so that
    // all day events are displayed at the top of the list.
    // Slightly inexxficient, to do this sort each time, the widget builds.
    if (_selectedEvents?.isNotEmpty == true) {
      _selectedEvents!.sort((a, b) {
        if (a.isAllDay == b.isAllDay) {
          return 0;
        }
        if (a.isAllDay) {
          return -1;
        }
        return 1;
      });
    }
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          nameAndIconRow,
          if (forceEventListView) ...[
            eventlistView,
            if (!_didScroll) ...[
              // When the widget is built, a PostFrameCallback is added to scroll the widget
              // after it has been built.
              Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Future.delayed(Duration(milliseconds: 100), () {
                      // Only execute the scroll to top, if the scroll
                      // controller has clients (was properly attached to a
                      // list view).
                      if (_scrollController.hasClients) {
                        resetToToday();
                      }
                    });
                  });
                  return Container();
                },
              ),
            ]
          ] else ...[
            ExpansionCrossFade(
              collapsed: calendarGridView,
              expanded: calendarGridView,
              isExpanded: isExpanded,
            ),
            expansionButtonRow,
            if (widget.showEvents) eventlistView
          ],
        ],
      ),
    );
  }

  /// A getter that returns a list of widgets representing the events in the event card.
  ///
  /// The `eventlistView` method creates a list of widgets that represent the events in the event card.
  /// Each date in the `eventsMap` is represented by a container widget that displays the date.
  /// Under each date, the associated events are listed, with each event represented by an `eventCell` widget.
  ///
  /// The method iterates through the `eventsMap` to create the widgets for the events.
  /// For each date, a container widget is created to display the date.
  /// For each event, an `eventCell` widget is created that displays the event's start and end times.
  ///
  /// - Return value: A list of widgets representing the events in the event card.
  Widget get eventlistView {
    // If the list view is active, show the full list of events. Otherwise only the
    // events for the selected day are shown.
    List<NeatCleanCalendarEvent>? _listEvents =
        forceEventListView ? widget.eventsList : _selectedEvents;

    // If eventListBuilder is provided, use it to build the list of events to show.
    // Otherwise use the default list of events.
    if (widget.eventListBuilder == null) {
      if (forceEventListView == true) {
        // If the list view is active a different kind of list is shown.
        itemList = [];

        eventsMap!.forEach((date, events) {
          itemList.add(date); // Füge das Datum hinzu
          itemList.addAll(events); // Füge die Events des Datums hinzu
        });

        return Expanded(
          child: ListView.builder(
              controller: _scrollController,
              itemCount: itemList.length,
              itemBuilder: (BuildContext context, int index) {
                final item = itemList[index];

                if (item is DateTime) {
                  // Date header for the list of events
                  return Container(
                    color: Color.fromRGBO(200, 200, 200, 0.2),
                    height: 40,
                    margin: EdgeInsets.only(top: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      DateFormat.yMMMMEEEEd(widget.locale).format(item),
                      style: TextStyle(fontSize: 13),
                    ),
                  );
                } else if (item is NeatCleanCalendarEvent) {
                  // Event cell for the list of events
                  final NeatCleanCalendarEvent event = item;
                  final String start =
                      DateFormat('HH:mm').format(event.startTime).toString();
                  final String end =
                      DateFormat('HH:mm').format(event.endTime).toString();
                  if (widget.eventCellBuilder == null) {
                    return eventCell(event, start, end);
                  } else {
                    return widget.eventCellBuilder!(context, event, start, end);
                  }
                }
                return Container();
              }),
        );
      } else {
        // List view is not active
        return Expanded(
          child: _listEvents != null && _listEvents.isNotEmpty
              // Create a list of events that are occurring on the currently selected day, if there are
              // any. Otherwise, display an empty Container.
              ? ListView.builder(
                  padding: EdgeInsets.all(0.0),
                  itemBuilder: (BuildContext context, int index) {
                    final NeatCleanCalendarEvent event = _listEvents[index];
                    final String start =
                        DateFormat('HH:mm').format(event.startTime).toString();
                    final String end =
                        DateFormat('HH:mm').format(event.endTime).toString();
                    return widget.eventCellBuilder == null
                        ? eventCell(event, start, end)
                        : widget.eventCellBuilder!(context, event, start, end);
                  },
                  itemCount: _listEvents.length,
                )
              : Container(),
        );
      }
    } else {
      // eventListBuilder is not null
      return widget.eventListBuilder!(context, _selectedEvents!);
    }
  }

  /// A widget that represents a cell for displaying an event in the calendar.
  ///
  /// The [eventCell] method returns a [Container] widget that represents a cell for displaying an event in the calendar.
  /// It takes an [event] of type [NeatCleanCalendarEvent], [start] and [end] strings representing the start and end time of the event.
  /// The [eventCell] widget is designed to be used within a [NeatCleanCalendar] widget.
  ///
  /// The [eventCell] widget displays the event information, including the event icon, summary, description, and start/end time.
  /// It also handles tap and long press gestures on the event cell.
  Widget eventCell(NeatCleanCalendarEvent event, String start, String end) {
    return Container(
      height:
          widget.eventTileHeight ?? MediaQuery.of(context).size.height * 0.08,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.onEventSelected != null) {
            widget.onEventSelected!(event);
          }
        },
        onLongPress: () {
          if (widget.onEventLongPressed != null) {
            widget.onEventLongPressed!(event);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: event.wide != null && event.wide! == true ? 25 : 5,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    // If no image is provided, use the color of the event.
                    // If the event has set isDone to true, use the eventDoneColor
                    // gets used. If that eventDoneColor is not set, use the
                    // primaryColor of the theme.
                    color: event.isDone
                        ? widget.eventDoneColor ??
                            Theme.of(context).primaryColor
                        : event.color,
                    borderRadius: BorderRadius.circular(10),
                    image: event.icon != '' && event.icon != null
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: providerImage(event.icon!),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Expanded(
              flex: 60,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(event.summary,
                        style: Theme.of(context).textTheme.bodySmall),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      event.description,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
            ),
            // This Expanded widget gets used to display the start and end time of the
            // event.
            Expanded(
              flex: 30,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                // If the event is all day, then display the word "All day" with no time.
                child: event.isAllDay || event.isMultiDay
                    ? allOrMultiDayDayTimeWidget(event)
                    : singleDayTimeWidget(start, end),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// The function [resetToToday] is called on tap on the Today button in the top
  /// position of the screen. It re-caclulates the range of dates, so that the
  /// month view or week view changes to a range containing the current day.
  void resetToToday() {
    // Only scroll if the integrated list view is used
    // When the parent app provides its own list view,
    // dont scroll to top. It woudl cause an exception.
    if (widget.eventListBuilder != null) {
      int index = findClosestIndex(DateTime.now());
      if (index != -1) {
        scrollToIndex(index);
      } else {
        scrollToTop();
      }
      onJumpToDateSelected(DateTime.now());
    }
  }

  // The function [nextMonth] updates the "_selectedDate" to the first day of the previous month.
  // If "launchCallback" is true, it also triggers the date selection callback with the new date.
  // The state is then updated with the new selected date, the days in the new month, the display month, and any events on the new date.
  // This function is typically used to navigate to the previous month in a calendar widget.
  void nextMonth(bool launchCallback) {
    DateTime _newDate = Utils.nextMonth(_selectedDate);
    // Parameter "launchCallback" is there to avoid triggering the callback twice.
    if (launchCallback) {
      _launchDateSelectionCallback(_newDate);
    }
    setState(() {
      _selectedDate = _newDate;
      var firstDateOfNewMonth = Utils.firstDayOfMonth(_selectedDate);
      var lastDateOfNewMonth = Utils.lastDayOfMonth(_selectedDate);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = _daysInMonth(_selectedDate);
      var monthFormat =
          DateFormat('MMMM yyyy', widget.locale).format(_selectedDate);
      displayMonth =
          '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
      _selectedEvents = eventsMap?[DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
          [];
    });
  }

  // The function [previousMonth] updates the "_selectedDate" to the first day of the previous month.
  // If "launchCallback" is true, it also triggers the date selection callback with the new date.
  // The state is then updated with the new selected date, the days in the new month, the display month, and any events on the new date.
  // This function is typically used to navigate to the previous month in a calendar widget.
  void previousMonth(bool launchCallback) {
    DateTime _newDate = Utils.previousMonth(_selectedDate);
    // Parameter "launchCallback" is there to avoid triggering the callback twice.
    if (launchCallback) {
      _launchDateSelectionCallback(_newDate);
    }
    setState(() {
      _selectedDate = _newDate;
      var firstDateOfNewMonth = Utils.firstDayOfMonth(_selectedDate);
      var lastDateOfNewMonth = Utils.lastDayOfMonth(_selectedDate);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = _daysInMonth(_selectedDate);
      var monthFormat =
          DateFormat('MMMM yyyy', widget.locale).format(_selectedDate);
      displayMonth =
          '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
      _selectedEvents = eventsMap?[DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
          [];
    });
  }

  void nextWeek() {
    DateTime _newDate = Utils.nextWeek(_selectedDate);
    _launchDateSelectionCallback(_newDate);
    setState(() {
      _selectedDate = _newDate;
      var firstDayOfCurrentWeek = _firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = _lastDayOfWeek(_selectedDate);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeekDays =
          Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      var monthFormat =
          DateFormat('MMMM yyyy', widget.locale).format(_selectedDate);
      displayMonth =
          '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
      _selectedEvents = eventsMap?[DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
          [];
    });
  }

  void previousWeek() {
    DateTime _newDate = Utils.previousWeek(_selectedDate);
    _launchDateSelectionCallback(_newDate);
    setState(() {
      _selectedDate = _newDate;
      var firstDayOfCurrentWeek = _firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = _lastDayOfWeek(_selectedDate);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeekDays =
          Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      var monthFormat =
          DateFormat('MMMM yyyy', widget.locale).format(_selectedDate);
      displayMonth =
          '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
      _selectedEvents = eventsMap?[DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
          [];
    });
  }

  void updateSelectedRange(DateTime start, DateTime end) {
    Range _rangeSelected = Range(start, end);
    if (widget.onRangeSelected != null) {
      widget.onRangeSelected!(_rangeSelected);
    }
  }

  void onJumpToDateSelected(DateTime day) {
    // Fire onDateSelected callback and onMonthChanged callback.
    _launchDateSelectionCallback(day);

    _selectedDate = day;
    var firstDayOfCurrentWeek = _firstDayOfWeek(_selectedDate);
    var lastDayOfCurrentWeek = _lastDayOfWeek(_selectedDate);

    setState(() {
      selectedWeekDays =
          Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      selectedMonthsDays = _daysInMonth(_selectedDate);
      var monthFormat =
          DateFormat('MMMM yyyy', widget.locale).format(_selectedDate);
      displayMonth =
          '${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}';
      _selectedEvents = eventsMap?[DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day)] ??
          [];
    });
  }

  void _onSwipeUp() {
    if (isExpanded) toggleExpanded();
  }

  void _onSwipeDown() {
    if (!isExpanded) toggleExpanded();
  }

  void _onSwipeRight() {
    if (isExpanded) {
      // Here _launchDateSelectionCallback was not called before. That's why set the
      // "launchCallback" parameter to true.
      previousMonth(true);
    } else {
      previousWeek();
    }
  }

  void _onSwipeLeft() {
    if (isExpanded) {
      // Here _launchDateSelectionCallback was not called before. That's why set the
      // "launchCallback" parameter to true.
      nextMonth(true);
    } else {
      nextWeek();
    }
  }

  void toggleExpanded() {
    if (widget.isExpandable) {
      setState(() => isExpanded = !isExpanded);
      if (widget.onExpandStateChanged != null)
        widget.onExpandStateChanged!(isExpanded);
    }
  }

  // The "handleSelectedDateAndUserCallback" method is responsible for processing the
  // selected date and invoking the corresponding user callback.
  // It is expected to be called when a user selects a date.
  // The exact functionality can vary depending on the implementation,
  // but typically this method will store the selected date and then call a
  // user-defined callback function based on this date.
  void handleSelectedDateAndUserCallback(DateTime day) {
    widget.onPrintLog != null
        ? widget.onPrintLog!('daySelected: $day')
        : print('daySelected: $day');
    // Fire onDateSelected callback and onMonthChanged callback.
    _launchDateSelectionCallback(day);

    var firstDayOfCurrentWeek = _firstDayOfWeek(day);
    var lastDayOfCurrentWeek = _lastDayOfWeek(day);
    // Check if the selected day falls into the next month. If this is the case,
    // then we need to additionaly check, if a day in next year was selected.
    if (_selectedDate.month > day.month) {
      // Day in next year selected? Switch to next month.
      if (_selectedDate.year < day.year) {
        // _launchDateSelectionCallback was already called befor. That's why set the
        // "launchCallback" parameter to false, to avoid calling the callback twice.
        nextMonth(false);
      } else {
        // _launchDateSelectionCallback was already called befor. That's why set the
        // "launchCallback" parameter to false, to avoid calling the callback twice.
        previousMonth(false);
      }
    }
    // Check if the selected day falls into the last month. If this is the case,
    // then we need to additionaly check, if a day in last year was selected.
    if (_selectedDate.month < day.month) {
      // Day in next last selected? Switch to next month.
      if (_selectedDate.year > day.year) {
        // _launchDateSelectionCallback was already called befor. That's why set the
        // "launchCallback" parameter to false, to avoid calling the callback twice.
        previousMonth(false);
      } else {
        // _launchDateSelectionCallback was already called befor. That's why set the
        // "launchCallback" parameter to false, to avoid calling the callback twice.
        nextMonth(false);
      }
    }
    setState(() {
      _selectedDate = day;
      selectedWeekDays =
          Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      selectedMonthsDays = _daysInMonth(day);
      _selectedEvents = eventsMap?[_selectedDate] ?? [];
    });
  }

  // The "_launchDateSelectionCallback" method is used to trigger the date selection callbacks.
  // If the "onDateSelected" callback is not null, it is invoked with the selected day.
  // Additionally, if the "onMonthChanged" callback is not null and the selected day is in
  // a different month or year than the previously selected date,
  // the "onMonthChanged" callback is invoked with the selected day.
  // This additional condition prevents the "onMonthChanged" callback from being invoked twice when a date in the same month is selected.
  void _launchDateSelectionCallback(DateTime day) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(day);
    }
    // Additional conditions: Only if month or year changed, then call the callback.
    // This avoids double executing the callback when selecting a date in the same month.
    if (widget.onMonthChanged != null &&
        (day.month != _selectedDate.month || day.year != _selectedDate.year)) {
      widget.onMonthChanged!(day);
    }
  }

  _firstDayOfWeek(DateTime date) {
    var day = DateTime.utc(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 12);
    if (widget.startOnMonday == true) {
      day = day.subtract(Duration(days: day.weekday - 1));
    } else {
      // if the selected day is a Sunday, then it is already the first day of week
      day = day.weekday == 7 ? day : day.subtract(Duration(days: day.weekday));
    }
    return day;
  }

  _lastDayOfWeek(DateTime date) {
    return _firstDayOfWeek(date).add(new Duration(days: 7));
  }

  /// The function [_daysInMonth] takes the parameter [month] (which is of type [DateTime])
  /// and calculates then all the days to be displayed in month view based on it. It returns
  /// all that days in a [List<DateTime].
  List<DateTime> _daysInMonth(DateTime month) {
    var first = Utils.firstDayOfMonth(month);
    var daysBefore = first.weekday;
    var firstToDisplay = first.subtract(
        new Duration(days: daysBefore - (widget.startOnMonday ? 1 : 0)));
    var last = Utils.lastDayOfMonth(month);

    var daysAfter = 7 - last.weekday;

    // If the last day is sunday (7) the entire week must be rendered
    if (daysAfter == 0) {
      daysAfter = 7;
    }

    // Adding an extra day necessary (if week starts on Monday).
    // Otherwise the week with days in next month would always end on Saturdays.
    var lastToDisplay = last
        .add(new Duration(days: daysAfter + (widget.startOnMonday ? 1 : 0)));
    return Utils.daysInRange(firstToDisplay, lastToDisplay).toList();
  }
}

class ExpansionCrossFade extends StatelessWidget {
  final Widget collapsed;
  final Widget expanded;
  final bool isExpanded;

  ExpansionCrossFade(
      {required this.collapsed,
      required this.expanded,
      required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: collapsed,
      secondChild: expanded,
      firstCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.decelerate,
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }
}
