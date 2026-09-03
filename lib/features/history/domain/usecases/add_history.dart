import '../../../assistant/domain/entities/detection_event.dart';
import '../repositories/history_repository.dart';

class AddHistory {
  final HistoryRepository historyRepository;

  AddHistory(this.historyRepository);

  Future<void> execute(DetectionEvent event) async {
    await historyRepository.addEvent(event);
  }
}
