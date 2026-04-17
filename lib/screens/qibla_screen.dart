import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';

import '../services/app_location_service.dart';
import '../services/qibla_service.dart';
import '../widget/app_drawwer.dart';
import '../widget/compass_widget.dart';

import '../l10n/app_localizations.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _heading = 0.0;
  double _qiblaDirection = 0.0;
  Position? _position;

  bool _loading = true;
  String _statusKey = 'loading';

  StreamSubscription<CompassEvent>? _compassSubscription;
  bool _hasVibrated = false;

  @override
  void initState() {
    super.initState();
    _initQibla();
  }

  Future<void> _initQibla() async {
    _compassSubscription?.cancel();

    setState(() {
      _loading = true;
      _statusKey = 'loading';
    });

    try {
      final position = await LocationService.getUserLocation();

      final qibla = QiblaService.bearingToKaaba(
        userLat: position!.latitude,
        userLng: position!.longitude,
      );

      _position = position;
      _qiblaDirection = qibla;

      final compassStream = FlutterCompass.events;

      if (compassStream == null) {
        setState(() {
          _loading = false;
          _statusKey = 'compassUnavailable';
        });
        return;
      }

      _compassSubscription = compassStream.listen((event) async {
        if (!mounted) return;

        if (event.heading == null) {
          setState(() {
            _loading = false;
            _statusKey = 'compassUnavailable';
          });
          return;
        }

        final newHeading = (event.heading! + 360) % 360;

        setState(() {
          _heading = newHeading;
          _loading = false;
          _statusKey = 'ready';
        });

        final diff = QiblaService.shortestAngleDifference(
          _qiblaDirection,
          _heading,
        );

        final aligned = diff.abs() <= 8;

        if (aligned && !_hasVibrated) {
          if (await Vibration.hasVibrator() ?? false) {
            Vibration.vibrate(duration: 200);
          }
          _hasVibrated = true;
        }

        if (!aligned) {
          _hasVibrated = false;
        }
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _statusKey = 'error';
      });
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final diff = QiblaService.shortestAngleDifference(
      _qiblaDirection,
      _heading,
    );

    final aligned = diff.abs() <= 8;

    return Scaffold(
      backgroundColor: Colors.grey.shade200, // 🔥 important for UI
      // drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(loc.compassQibla),
        centerTitle: true,
        automaticallyImplyLeading: true, // shows back arrow
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // 🧭 COMPASS (your upgraded widget)
              CompassWidget(
                heading: _heading,
                qiblaDirection: _qiblaDirection,
              ),

              const SizedBox(height: 30),

              // 📐 INFO
              Text(
                "${loc.heading}: ${_heading.toStringAsFixed(1)}°",
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 6),

              Text(
                "${loc.qiblaDirection}: ${_qiblaDirection.toStringAsFixed(1)}°",
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 15),

              // ✅ STATUS
              Text(
                aligned
                    ? loc.facingQibla
                    : loc.turnToQibla,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: aligned ? Colors.green : Colors.black,
                ),
              ),

              const SizedBox(height: 15),

              // 📍 LOCATION
              if (_position != null)
                Text(
                  "${loc.latLabel}: ${_position!.latitude.toStringAsFixed(4)}\n"
                      "${loc.lngLabel}: ${_position!.longitude.toStringAsFixed(4)}",
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 20),

              // 🧠 CALIBRATION
              Text(
                loc.calibrationText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}