import 'dart:math';

class QiblaService {

  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  static double bearingToKaaba({
    required double userLat,
    required double userLng,
  }) {
    final lat1 = userLat * pi / 180;
    final lon1 = userLng * pi / 180;

    final lat2 = kaabaLat * pi / 180;
    final lon2 = kaabaLng * pi / 180;

    final dLon = lon2 - lon1;

    final y = sin(dLon);
    final x = cos(lat1) * tan(lat2) - sin(lat1) * cos(dLon);

    final bearing = atan2(y, x);

    double result = bearing * 180 / pi;

    return (result + 360) % 360;
  }

  static double shortestAngleDifference(double target, double current) {
    double diff = target - current;

    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    return diff;
  }
}