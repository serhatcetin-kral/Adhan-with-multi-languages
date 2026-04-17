// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/mosque.dart';
// import 'package:latlong2/latlong.dart';
//
// class MosqueService {
//
//   static Future<List<Mosque>> fetchNearbyMosques(
//       double lat, double lon) async {
//
//     final url = Uri.parse("https://overpass-api.de/api/interpreter");
//
//     final query = """
//     [out:json];
//     (
//       node["amenity"="place_of_worship"](around:8000,$lat,$lon);
//       way["amenity"="place_of_worship"](around:8000,$lat,$lon);
//       relation["amenity"="place_of_worship"](around:8000,$lat,$lon);
//     );
//     out center;
//     """;
//
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/x-www-form-urlencoded",
//         "User-Agent": "adhan_app (serhatamerica.sc@gmail.com)",
//       },
//       body: query,
//     );
//
//     if (response.statusCode != 200) return [];
//
//     final data = jsonDecode(response.body);
//
//     List<Mosque> mosques = [];
//
//     for (var el in data['elements']) {
//
//       final name = (el['tags']?['name'] ?? "").toString().toLowerCase();
//
//       if (!(name.contains("mosque") ||
//           name.contains("masjid") ||
//           name.contains("mescid") ||
//           name.contains("camii") ||
//           name.contains("islamic") ||
//           name.contains("مسجد"))) continue;
//
//       final latValue = el['lat'] ?? el['center']?['lat'];
//       final lonValue = el['lon'] ?? el['center']?['lon'];
//
//       if (latValue == null || lonValue == null) continue;
//
//       mosques.add(
//         Mosque(
//           name: name,
//           lat: (latValue as num).toDouble(),
//           lng: (lonValue as num).toDouble(),
//         ),
//       );
//     }
//
//     return mosques;
//   }
// }