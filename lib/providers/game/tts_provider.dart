import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/tts_service.dart';

final ttsServiceProvider = StateNotifierProvider<TtsNotifier, bool>((ref) {
  return TtsNotifier();
});

class TtsNotifier extends StateNotifier<bool> {
  final TtsService _tts = TtsService();

  TtsNotifier() : super(false);

  TtsService get service => _tts;

  void toggleMute() {
    _tts.toggleMute();
    state = _tts.isMuted;
  }

  void setMuted(bool value) {
    _tts.setMuted(value);
    state = value;
  }

  Future<void> speak(String text) => _tts.speak(text);

  /// Speak text in Bengali (Bangla) language
  Future<void> speakBangla(String text) => _tts.speakBangla(text);
}
