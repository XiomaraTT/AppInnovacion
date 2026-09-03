import '../../../assistant/domain/entities/detection_event.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final List<DetectionEvent> _history = [
    DetectionEvent(
      id: '1',
      label: 'Persona',
      relativePosition: 'Izquierda',
      riskLevel: 'Bajo',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      description: 'Persona a la izquierda, caminando.',
    ),
    DetectionEvent(
      id: '2',
      label: 'Bicicleta',
      relativePosition: 'Derecha',
      riskLevel: 'Medio',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      description: 'Bicicleta a la derecha, en movimiento.',
    ),
    DetectionEvent(
      id: '3',
      label: 'Automóvil',
      relativePosition: 'Adelante',
      riskLevel: 'Alto',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      description: '¡Cuidado! Automóvil adelante, muy cerca.',
    ),
  ];

  @override
  Future<List<DetectionEvent>> getHistory() async {
    return List.unmodifiable(_history);
  }

  @override
  Future<void> addEvent(DetectionEvent event) async {
    _history.insert(0, event);
  }
}
