import '../../../assistant/domain/entities/detection_event.dart';
import '../repositories/history_repository.dart';

class GetHistory {
  final HistoryRepository historyRepository;

  GetHistory(this.historyRepository);

  Future<List<DetectionEvent>> execute() async {
    return await historyRepository.getHistory();
  }
}
