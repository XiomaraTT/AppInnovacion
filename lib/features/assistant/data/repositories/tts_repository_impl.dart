import 'package:flutter_tts/flutter_tts.dart';
import '../../domain/repositories/tts_repository.dart';

class TtsRepositoryImpl implements TtsRepository {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsInitialized = false;

  Future<void> _initTts() async {
    if (_isTtsInitialized) return;
    try {
      await _flutterTts.setLanguage("es-ES");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isTtsInitialized = true;
    } catch (e) {
      // Handle init error
    }
  }

  @override
  Future<void> speak(String text, double rate, double volume) async {
    await _initTts();
    try {
      double ttsRate = rate * 0.5;
      if (ttsRate > 1.0) ttsRate = 1.0;
      if (ttsRate < 0.1) ttsRate = 0.1;

      await _flutterTts.setSpeechRate(ttsRate);
      await _flutterTts.setVolume(volume);

      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      // Handle exception
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      // Handle exception
    }
  }
}
