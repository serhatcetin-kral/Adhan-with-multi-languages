import 'package:geocoding/geocoding.dart';

class LocationNameService {

  static Future<String> getLocationName(
      double latitude,
      double longitude,
      ) async {
    try {
      final placemarks =
      await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) return "Current location";

      final p = placemarks.first;

      final city = p.locality ?? "";
      final district = p.subAdministrativeArea ?? "";
      final state = p.administrativeArea ?? "";
      final country = p.country ?? "";

      if (city.isNotEmpty && district.isNotEmpty && city != district) {
        return "$city, $district";
      }

      if (city.isNotEmpty) return city;
      if (district.isNotEmpty) return district;
      if (state.isNotEmpty) return state;
      if (country.isNotEmpty) return country;

      return "Current location";
    } catch (e) {
      return "Current location";
    }
  }
}