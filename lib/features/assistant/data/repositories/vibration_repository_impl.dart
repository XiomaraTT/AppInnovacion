import 'package:flutter/services.dart';
import '../../domain/repositories/vibration_repository.dart';

class VibrationRepositoryImpl implements VibrationRepository {
  @override
  Future<void> vibrate(int durationMs) async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      // Handle exception
    }
  }
}
