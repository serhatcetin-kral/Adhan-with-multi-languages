import 'package:adhan_app/screens/qibla_screen.dart';
import 'package:flutter/material.dart';

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
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: "Prayer",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: "Qibla",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}