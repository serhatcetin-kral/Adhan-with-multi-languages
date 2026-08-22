import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  static Future<void> checkForUpdate() async {
    final prefs = await SharedPreferences.getInstance();

    final lastPrompt = prefs.getInt('last_update_prompt') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    const threeDays = 3 * 24 * 60 * 60 * 1000;

    if (now - lastPrompt < threeDays) {
      return;
    }

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await prefs.setInt('last_update_prompt', now);

        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      // Do nothing. Update check can fail in debug or non-Play installs.
    }
  }
}