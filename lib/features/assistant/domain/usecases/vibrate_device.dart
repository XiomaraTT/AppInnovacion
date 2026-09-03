import '../repositories/vibration_repository.dart';

class VibrateDevice {
  final VibrationRepository vibrationRepository;

  VibrateDevice(this.vibrationRepository);

  Future<void> execute(int durationMs) async {
    await vibrationRepository.vibrate(durationMs);
  }
}
