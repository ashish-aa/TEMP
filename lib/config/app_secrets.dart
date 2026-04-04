class AppSecrets {
  AppSecrets._();

  /// Firebase configuration comes from:
  /// - android/app/src/google-services.json
  /// - android/app/google-services (7).json

  /// ZEGOCLOUD credentials
  static const int zegoAppId = 628526500;
  static const String zegoAppSign =
      'd76bb5def9e68f29f24c12997bd5d3941186b3d9b825719c69895c9f14c7b8cd';

  static bool get hasValidZegoConfig =>
      zegoAppId > 0 && zegoAppSign.isNotEmpty;
}
