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
    final lang = Localizations.localeOf(context).languageCode;
    final loc = AppLocalizations.of(context)!;

    final hijri = HijriCalendar.fromDate(_selectedDay);

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

            // TOP CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTopCard(locale, lang),
            ),

            const SizedBox(height: 12),

            // CALENDAR
            Padding(
              padding: const EdgeInsets.all(12),
              child: TableCalendar(
                locale: locale,
                firstDay: DateTime(2020),
                lastDay: DateTime(2035),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
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
                  defaultBuilder: (context, day, _) {
                    final h = HijriCalendar.fromDate(day);

                    final isFriday = day.weekday == DateTime.friday;
                    final isRamadan = h.hMonth == 9;
                    final isHolyNight = (h.hMonth == 9 && h.hDay == 27);

                    return Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isRamadan
                            ? Colors.green.shade50
                            : isFriday
                            ? Colors.blue.shade50
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        border: isHolyNight
                            ? Border.all(color: Colors.red, width: 2)
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${day.day}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isFriday ? Colors.blue : Colors.black,
                                  ),
                                ),
                                Text(
                                  "${h.hDay}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

            // IMPORTANT DAYS
            _buildUpcomingEvents(loc),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard(String locale, String lang) {
    final hijri = HijriCalendar.fromDate(_selectedDay);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            "${hijri.hDay} ${_monthName(hijri.hMonth, lang)} ${hijri.hYear}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat.yMMMMEEEEd(locale).format(_selectedDay),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(AppLocalizations loc) {
    final events = _getUpcomingEvents(loc);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.importantIslamicDays,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...events.map((e) => _eventRow(e)),
        ],
      ),
    );
  }

  Widget _eventRow(_EventItem e) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: e.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${e.title} — ${DateFormat.MMMd().format(e.date)}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  List<_EventItem> _getUpcomingEvents(AppLocalizations loc) {
    final now = DateTime.now();
    final events = <_EventItem>[];

    for (int i = 0; i < 365; i++) {
      final date = now.add(Duration(days: i));
      final h = HijriCalendar.fromDate(date);

      if (h.hMonth == 9 && h.hDay == 27) {
        events.add(_EventItem(loc.laylatAlQadr, date, Colors.red));
      }

      if (h.hMonth == 10 && h.hDay == 1) {
        events.add(_EventItem(loc.eidAlFitr, date, Colors.orange));
      }

      if (h.hMonth == 12 && h.hDay == 10) {
        events.add(_EventItem(loc.eidAlAdha, date, Colors.amber));
      }

      if (h.hMonth == 9 && h.hDay == 1) {
        events.add(_EventItem(loc.startOfRamadan, date, Colors.green));
      }
    }

    return events.take(5).toList();
  }

  String _monthName(int m, String lang) {
    if (lang == 'tr') {
      return [
        "Muharrem",
        "Safer",
        "Rebiülevvel",
        "Rebiülahir",
        "Cemaziyelevvel",
        "Cemaziyelahir",
        "Recep",
        "Şaban",
        "Ramazan",
        "Şevval",
        "Zilkade",
        "Zilhicce"
      ][m - 1];
    }

    if (lang == 'ar') {
      return [
        "محرم",
        "صفر",
        "ربيع الأول",
        "ربيع الآخر",
        "جمادى الأولى",
        "جمادى الآخرة",
        "رجب",
        "شعبان",
        "رمضان",
        "شوال",
        "ذو القعدة",
        "ذو الحجة"
      ][m - 1];
    }

    if (lang == 'fr') {
      return [
        "Muharram",
        "Safar",
        "Rabi al-Awwal",
        "Rabi al-Thani",
        "Joumada al-Oula",
        "Joumada ath-Thania",
        "Rajab",
        "Chaabane",
        "Ramadan",
        "Chawwal",
        "Dhou al-Qi'da",
        "Dhou al-Hijja"
      ][m - 1];
    }

    return [
      "Muharram",
      "Safar",
      "Rabi I",
      "Rabi II",
      "Jumada I",
      "Jumada II",
      "Rajab",
      "Sha'ban",
      "Ramadan",
      "Shawwal",
      "Dhul-Qa'dah",
      "Dhul-Hijjah"
    ][m - 1];
  }
}

class _EventItem {
  final String title;
  final DateTime date;
  final Color color;

  _EventItem(this.title, this.date, this.color);
}