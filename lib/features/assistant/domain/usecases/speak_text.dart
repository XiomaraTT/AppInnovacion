import '../repositories/tts_repository.dart';

class SpeakText {
  final TtsRepository ttsRepository;

  SpeakText(this.ttsRepository);

  Future<void> execute(String text, double rate, double volume) async {
    await ttsRepository.speak(text, rate, volume);
  }

  Future<void> stop() async {
    await ttsRepository.stop();
  }
}
