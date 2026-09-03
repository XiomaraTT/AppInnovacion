import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings {
  final SettingsRepository settingsRepository;

  GetSettings(this.settingsRepository);

  Future<AppSettings> execute() async {
    return await settingsRepository.getSettings();
  }
}
