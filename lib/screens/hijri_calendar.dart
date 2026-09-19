import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: Text(loc.calendarTitle),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // =========================
            // TOP HIJRI DATE CARD
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTopCard(
                locale,
                loc,
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // CALENDAR
            // =========================
            Padding(
              padding: const EdgeInsets.all(12),
              child: TableCalendar(
                locale: locale,

                firstDay: DateTime(2020),
                lastDay: DateTime(2035),

                focusedDay: _focusedDay,

                selectedDayPredicate: (day) {
                  return isSameDay(
                    day,
                    _selectedDay,
                  );
                },

                onDaySelected: (
                    selectedDay,
                    focusedDay,
                    ) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },

                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (
                      context,
                      day,
                      focusedDay,
                      ) {
                    final hijri =
                    HijriCalendar.fromDate(day);

                    final isFriday =
                        day.weekday == DateTime.friday;

                    final isRamadan =
                        hijri.hMonth == 9;

                    final isHolyNight =
                        hijri.hMonth == 9 &&
                            hijri.hDay == 27;

                    return Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isRamadan
                            ? Colors.green.shade50
                            : isFriday
                            ? Colors.blue.shade50
                            : null,

                        borderRadius:
                        BorderRadius.circular(12),

                        border: isHolyNight
                            ? Border.all(
                          color: Colors.red,
                          width: 2,
                        )
                            : null,
                      ),

                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                // Gregorian day
                                Text(
                                  "${day.day}",
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                    color: isFriday
                                        ? Colors.blue
                                        : Colors.black,
                                  ),
                                ),

                                // Hijri day
                                Text(
                                  "${hijri.hDay}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Laylat al-Qadr marker
                          if (isHolyNight)
                            const Positioned(
                              top: 2,
                              right: 2,
                              child: Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // =========================
            // IMPORTANT ISLAMIC DAYS
            // =========================
            _buildUpcomingEvents(
              loc,
              locale,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // TOP HIJRI DATE CARD
  // =========================================================

  Widget _buildTopCard(
      String locale,
      AppLocalizations loc,
      ) {
    final hijri =
    HijriCalendar.fromDate(_selectedDay);

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF43A047),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          // Hijri date
          Text(
            "${hijri.hDay} "
                "${_monthName(hijri.hMonth, loc)} "
                "${hijri.hYear}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // Gregorian date
          Text(
            DateFormat
                .yMMMMEEEEd(locale)
                .format(_selectedDay),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // IMPORTANT ISLAMIC DAYS
  // =========================================================

  Widget _buildUpcomingEvents(
      AppLocalizations loc,
      String locale,
      ) {
    final events =
    _getUpcomingEvents(loc);

    return Container(
      margin:
      const EdgeInsets.symmetric(horizontal: 16),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            loc.importantIslamicDays,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ...events.map(
                (event) => _eventRow(
              event,
              locale,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EVENT ROW
  // =========================================================

  Widget _eventRow(
      _EventItem event,
      String locale,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,

            decoration: BoxDecoration(
              color: event.color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              "${event.title} — "
                  "${DateFormat.MMMd(locale).format(event.date)}",
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FIND UPCOMING ISLAMIC EVENTS
  // =========================================================

  List<_EventItem> _getUpcomingEvents(
      AppLocalizations loc,
      ) {
    final now = DateTime.now();
    final events = <_EventItem>[];

    // Search the next 365 days
    for (int i = 0; i < 365; i++) {
      final date =
      now.add(Duration(days: i));

      final hijri =
      HijriCalendar.fromDate(date);

      // Laylat al-Qadr
      if (hijri.hMonth == 9 &&
          hijri.hDay == 27) {
        events.add(
          _EventItem(
            loc.laylatAlQadr,
            date,
            Colors.red,
          ),
        );
      }

      // Eid al-Fitr
      if (hijri.hMonth == 10 &&
          hijri.hDay == 1) {
        events.add(
          _EventItem(
            loc.eidAlFitr,
            date,
            Colors.orange,
          ),
        );
      }

      // Eid al-Adha
      if (hijri.hMonth == 12 &&
          hijri.hDay == 10) {
        events.add(
          _EventItem(
            loc.eidAlAdha,
            date,
            Colors.amber,
          ),
        );
      }

      // Start of Ramadan
      if (hijri.hMonth == 9 &&
          hijri.hDay == 1) {
        events.add(
          _EventItem(
            loc.startOfRamadan,
            date,
            Colors.green,
          ),
        );
      }
    }

    // Maximum 5 events
    return events.take(5).toList();
  }

  // =========================================================
  // LOCALIZED HIJRI MONTH NAME
  // =========================================================

  String _monthName(
      int month,
      AppLocalizations loc,
      ) {
    final months = [
      loc.hijriMuharram,
      loc.hijriSafar,
      loc.hijriRabiAlAwwal,
      loc.hijriRabiAlThani,
      loc.hijriJumadaAlAwwal,
      loc.hijriJumadaAlThani,
      loc.hijriRajab,
      loc.hijriShaban,
      loc.hijriRamadan,
      loc.hijriShawwal,
      loc.hijriDhulQadah,
      loc.hijriDhulHijjah,
    ];

    return months[month - 1];
  }
}

// ===========================================================
// EVENT MODEL
// ===========================================================

class _EventItem {
  final String title;
  final DateTime date;
  final Color color;

  _EventItem(
      this.title,
      this.date,
      this.color,
      );
}