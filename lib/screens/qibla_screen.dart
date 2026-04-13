import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:vibration/vibration.dart';

import '../services/location_service.dart';
import '../services/qibla_service.dart';
import '../l10n/app_localizations.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? qiblaBearing;
  bool isLoading = true;
  bool hasVibrated = false;

  @override
  void initState() {
    super.initState();
    loadQibla();
  }

  Future<void> loadQibla() async {
    try {
      final pos = await LocationService.getUserLocation();

      final bearing = QiblaService.bearingToKaaba(
        userLat: pos.latitude,
        userLng: pos.longitude,
      );

      setState(() {
        qiblaBearing = bearing;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isAligned(double diff) => diff.abs() <= 8;

  Future<void> handleVibration(bool aligned) async {
    if (aligned && !hasVibrated) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 200);
      }
      hasVibrated = true;
    } else if (!aligned) {
      hasVibrated = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.compassQibla),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data?.heading == null ||
              qiblaBearing == null) {
            return Center(child: Text(loc.calibratingCompass));
          }

          final heading = snapshot.data!.heading!;
          final diff = QiblaService.shortestAngleDifference(
            qiblaBearing!,
            heading,
          );

          final aligned = isAligned(diff);
          handleVibration(aligned);

          return buildCompass(loc, heading, diff, aligned);
        },
      ),
    );
  }

  // ================= UI =================

  Widget buildCompass(
      AppLocalizations loc, double heading, double diff, bool aligned) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        // 🧭 COMPASS
        Stack(
          alignment: Alignment.center,
          children: [

            // OUTER RING
            Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.teal, width: 4),
              ),
            ),

            // INNER BACKGROUND
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
            ),

            // TICKS
            ...List.generate(60, (index) {
              final isMain = index % 5 == 0;

              return Transform.rotate(
                angle: index * 6 * math.pi / 180,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 2,
                    height: isMain ? 14 : 6,
                    color: isMain ? Colors.teal : Colors.grey,
                  ),
                ),
              );
            }),

            // ARROW
            Transform.rotate(
              angle: diff * (math.pi / 180),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Icon(
                    Icons.navigation,
                    size: 120,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 6),

                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            // DIRECTIONS
            const Positioned(top: 18, child: Text("N")),
            const Positioned(bottom: 18, child: Text("S")),
            const Positioned(left: 18, child: Text("W")),
            const Positioned(right: 18, child: Text("E")),

            // QIBLA BADGE
            Positioned(
              bottom: 55,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  loc.qibla,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        // INFO
        Text("${loc.heading}: ${heading.toStringAsFixed(1)}°"),
        Text("${loc.qiblaDirection}: ${(heading + diff).toStringAsFixed(1)}°"),

        const SizedBox(height: 10),

        // STATUS
        Text(
          aligned ? loc.facingQibla : loc.turnToQibla,
          style: TextStyle(
            color: aligned ? Colors.green : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          loc.calibrationText,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}