import 'dart:math';
import 'package:flutter/material.dart';

class CompassWidget extends StatelessWidget {
  final double heading;
  final double qiblaDirection;

  const CompassWidget({
    super.key,
    required this.heading,
    required this.qiblaDirection,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedHeading = (heading + 360) % 360;
    final normalizedQibla = (qiblaDirection + 360) % 360;
    final relativeAngle = (normalizedQibla - normalizedHeading) % 360;

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [

          /// 🌫 OUTER SHADOW
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),

          /// 🔵 MAIN BORDER
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.teal,
                width: 3,
              ),
            ),
          ),

          /// ⚪ INNER CIRCLE
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
            ),
          ),

          /// 🧭 TICK MARKS (REALISTIC)
          ...List.generate(60, (i) {
            final isMain = i % 15 == 0;

            return Transform.rotate(
              angle: i * 6 * pi / 180,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 1.5,
                  height: isMain ? 14 : 6,
                  color: isMain
                      ? Colors.teal
                      : Colors.grey.shade400,
                ),
              ),
            );
          }),

          /// 🔺 ARROW
          Transform.rotate(
            angle: relativeAngle * pi / 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(
                  Icons.navigation,
                  size: 120,
                  color: Colors.red,
                ),

                const SizedBox(height: 4),

                /// 🔴 QIBLA BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.red.shade200,
                    ),
                  ),
                  child: const Text(
                    "Qibla",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🟢 CENTER DOT
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),

          /// 🧭 DIRECTIONS
          const Positioned(
            top: 18,
            child: Text("N",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Positioned(
            bottom: 18,
            child: Text("S",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Positioned(
            left: 18,
            child: Text("W",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Positioned(
            right: 18,
            child: Text("E",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}