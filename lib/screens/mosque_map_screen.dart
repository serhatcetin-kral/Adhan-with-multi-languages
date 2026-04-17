// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geocoding/geocoding.dart';
//
// import '../services/mosque_service.dart';
// import '../services/app_location_service.dart';
// import '../models/mosque.dart';
//
// class MosqueMapScreen extends StatefulWidget {
//   const MosqueMapScreen({super.key});
//
//   @override
//   State<MosqueMapScreen> createState() => _MosqueMapScreenState();
// }
//
// class _MosqueMapScreenState extends State<MosqueMapScreen> {
//
//   LatLng? userLocation;
//   List<Mosque> mosques = [];
//
//   bool isLoading = true;
//   bool useMiles = false;
//
//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }
//
//   Future<void> loadData() async {
//
//     setState(() => isLoading = true);
//
//     try {
//       var pos = await AppLocationService.getUserLocation();
//
//       if (pos == null) {
//         setState(() => isLoading = false);
//         return;
//       }
//
//       print("USER LOCATION: ${pos.latitude}, ${pos.longitude}");
//
//       // 🚨 FIX WRONG LOCATION (Africa bug)
//       if (pos.latitude.abs() < 1 && pos.longitude.abs() < 1) {
//         print("⚠️ Wrong location detected → using fallback");
//         pos = Position(
//           latitude: 40.7128,
//           longitude: -74.0060,
//           timestamp: DateTime.now(),
//           accuracy: 1,
//           altitude: 0,
//           heading: 0,
//           speed: 0,
//           speedAccuracy: 0, altitudeAccuracy: null, headingAccuracy: null,
//         );
//       }
//
//       final placemarks = await placemarkFromCoordinates(
//         pos.latitude,
//         pos.longitude,
//       );
//
//       useMiles = (placemarks.first.isoCountryCode == "US");
//
//       final list = await MosqueService.fetchNearbyMosques(
//         pos.latitude,
//         pos.longitude,
//       );
//
//       setState(() {
//         userLocation = LatLng(pos!.latitude, pos!.longitude);
//         mosques = list;
//         isLoading = false;
//       });
//
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }
//
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     const Distance distance = Distance();
//
//     final meters = distance.as(
//       LengthUnit.Meter,
//       LatLng(lat1, lon1),
//       LatLng(lat2, lon2),
//     );
//
//     return meters / 1000;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     if (userLocation == null) {
//       return const Scaffold(
//         body: Center(child: Text("Location not available")),
//       );
//     }
//
//     mosques.sort((a, b) {
//       final d1 = calculateDistance(
//         userLocation!.latitude,
//         userLocation!.longitude,
//         a.lat,
//         a.lng,
//       );
//
//       final d2 = calculateDistance(
//         userLocation!.latitude,
//         userLocation!.longitude,
//         b.lat,
//         b.lng,
//       );
//
//       return d1.compareTo(d2);
//     });
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Nearby Mosques")),
//
//       body: Column(
//         children: [
//
//           // MAP
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.55,
//             child: FlutterMap(
//               options: MapOptions(
//                 initialCenter: userLocation!,
//                 initialZoom: 14,
//               ),
//               children: [
//
//                 TileLayer(
//                   urlTemplate:
//                   "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//                   userAgentPackageName: 'com.serhat.adhan_app',
//                 ),
//
//                 MarkerLayer(
//                   markers: [
//                     Marker(
//                       point: userLocation!,
//                       width: 50,
//                       height: 50,
//                       child: const Icon(Icons.my_location, color: Colors.blue),
//                     ),
//                   ],
//                 ),
//
//                 MarkerLayer(
//                   markers: mosques.map((m) {
//                     return Marker(
//                       point: LatLng(m.lat, m.lng),
//                       width: 40,
//                       height: 40,
//                       child: const Icon(Icons.location_on, color: Colors.green),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//
//           // LIST
//           Expanded(
//             child: ListView.builder(
//               itemCount: mosques.length > 15 ? 15 : mosques.length,
//               itemBuilder: (context, index) {
//
//                 final m = mosques[index];
//
//                 final distKm = calculateDistance(
//                   userLocation!.latitude,
//                   userLocation!.longitude,
//                   m.lat,
//                   m.lng,
//                 );
//
//                 final distanceText = useMiles
//                     ? "${(distKm * 0.621371).toStringAsFixed(2)} mi"
//                     : distKm < 1
//                     ? "${(distKm * 1000).toStringAsFixed(0)} m"
//                     : "${distKm.toStringAsFixed(2)} km";
//
//                 return ListTile(
//                   title: Text(m.name),
//                   subtitle: Text(distanceText),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }