import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SaveSettings {
  final SettingsRepository settingsRepository;

  SaveSettings(this.settingsRepository);

  Future<void> execute(AppSettings settings) async {
    await settingsRepository.saveSettings(settings);
  }
}
