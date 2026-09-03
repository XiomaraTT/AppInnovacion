import '../repositories/vision_repository.dart';

class StreamFrame {
  final VisionRepository visionRepository;

  StreamFrame(this.visionRepository);

  Future<void> execute(List<int> frameBytes) async {
    await visionRepository.sendFrame(frameBytes);
  }
}
