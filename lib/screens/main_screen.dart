import 'package:adhan_app/screens/qibla_screen.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

import 'more_screen.dart';
import 'prayer_screen.dart';
import 'settings_screen.dart';
import 'qibla_selection_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int currentIndex = 0;

  final screens = [
    const PrayerScreen(),
     const QiblaSelectionScreen(),
    // const QiblaScreen(),
    const MoreScreen(),
    const SettingsScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(

      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/nav/prayer.png',
              width: 30,
              height: 30,
            ),
            activeIcon: Image.asset(
              'assets/nav/prayer.png',
              width: 28,
              height: 28,
            ),
            label: loc.prayerTimes,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/nav/qibla.png',
              width: 30,
              height: 30,
            ),
            activeIcon: Image.asset(
              'assets/nav/qibla.png',
              width: 28,
              height: 28,
            ),
            label: loc.qiblaFinder,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/nav/more.png',
              width: 30,
              height: 30,
            ),
            activeIcon: Image.asset(
              'assets/nav/more.png',
              width: 28,
              height: 28,
            ),
            label: loc.more,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/nav/setting.png',
              width: 30,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/nav/setting.png',
              width: 28,
              height: 28,
            ),
            label: loc.settings,
          ),
        ],
      ),
    );
  }
}