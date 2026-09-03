abstract class TtsRepository {
  Future<void> speak(String text, double rate, double volume);
  Future<void> stop();
}
