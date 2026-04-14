import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {

  /// 🔍 Check current internet status
  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// 🔄 Listen for internet changes
  static Stream<bool> internetStream() {
    return Connectivity()
        .onConnectivityChanged
        .map((result) => result != ConnectivityResult.none);
  }
}