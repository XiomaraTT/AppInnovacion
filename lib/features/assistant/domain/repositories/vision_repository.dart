import '../entities/detection_event.dart';

abstract class VisionRepository {
  Stream<DetectionEvent> get detections;
  Future<void> connect(String ipAddress);
  Future<void> sendFrame(List<int> frameBytes);
  Future<void> disconnect();
}
