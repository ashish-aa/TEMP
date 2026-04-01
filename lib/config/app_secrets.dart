class AppSecrets {
  AppSecrets._();

  /// Firebase configuration is expected via platform files:
  /// - android/app/google-services.json
  /// - ios/Runner/GoogleService-Info.plist
  ///
  /// Keep sensitive values out of source control for production builds.

  /// Replace with Agora App ID from Agora Console.
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';

  /// Optional: use a temporary token for testing.
  /// Keep empty if your Agora project has App Certificate disabled.
  static const String agoraTempToken = 'YOUR_AGORA_TEMP_TOKEN';

  static bool get hasValidAgoraAppId =>
      agoraAppId.isNotEmpty && agoraAppId != 'YOUR_AGORA_APP_ID';
}
