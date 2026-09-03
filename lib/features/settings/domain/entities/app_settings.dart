class AppSettings {
  final double voiceSpeed;
  final double volume;
  final bool vibrationEnabled;
  final String alertFrequency;
  final String sensitivity;
  final String language;
  final String userName;
  final String serverIp;

  AppSettings({
    required this.voiceSpeed,
    required this.volume,
    required this.vibrationEnabled,
    required this.alertFrequency,
    required this.sensitivity,
    required this.language,
    required this.userName,
    required this.serverIp,
  });

  AppSettings copyWith({
    double? voiceSpeed,
    double? volume,
    bool? vibrationEnabled,
    String? alertFrequency,
    String? sensitivity,
    String? language,
    String? userName,
    String? serverIp,
  }) {
    return AppSettings(
      voiceSpeed: voiceSpeed ?? this.voiceSpeed,
      volume: volume ?? this.volume,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      alertFrequency: alertFrequency ?? this.alertFrequency,
      sensitivity: sensitivity ?? this.sensitivity,
      language: language ?? this.language,
      userName: userName ?? this.userName,
      serverIp: serverIp ?? this.serverIp,
    );
  }
}
