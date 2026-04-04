class AppSecrets {
  AppSecrets._();

  /// Firebase configuration comes from:
  /// - android/app/src/google-services.json
  /// - android/app/google-services (7).json

  /// ZEGOCLOUD credentials from https://console.zegocloud.com
  /// Keep placeholders in git; inject real values locally/CI.
  static const int zegoAppId = 0; // e.g. 123456789
  static const String zegoAppSign = 'YOUR_ZEGO_APP_SIGN';

  static bool get hasValidZegoConfig =>
      zegoAppId > 0 && zegoAppSign.isNotEmpty && zegoAppSign != 'YOUR_ZEGO_APP_SIGN';
}
