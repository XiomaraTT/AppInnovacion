import '../repositories/vision_repository.dart';

class ToggleAssistance {
  final VisionRepository visionRepository;

  ToggleAssistance(this.visionRepository);

  Future<void> connect(String ipAddress) async {
    await visionRepository.connect(ipAddress);
  }

  Future<void> disconnect() async {
    await visionRepository.disconnect();
  }
}
