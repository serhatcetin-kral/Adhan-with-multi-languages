import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playAdhan() async {
    try {
      await _player.setAsset('assets/audio/adhan.mp3');
      await _player.setVolume(1.0);
      await _player.play();
    } catch (e) {
      print("Audio error: $e");
    }
  }
}