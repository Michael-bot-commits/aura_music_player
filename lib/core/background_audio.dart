import 'package:just_audio_background/just_audio_background.dart';

// Must be called in main() before AudioPlayer is instantiated.
Future<void> initBackgroundAudio() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.aura.audio',
    androidNotificationChannelName: 'AURA Audio',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );
}
