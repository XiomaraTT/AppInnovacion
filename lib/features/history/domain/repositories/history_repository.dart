import '../../../assistant/domain/entities/detection_event.dart';

abstract class HistoryRepository {
  Future<List<DetectionEvent>> getHistory();
  Future<void> addEvent(DetectionEvent event);
}
