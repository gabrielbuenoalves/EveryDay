import '../config/local_env.dart';

class YouVersionAuthConfig {
  const YouVersionAuthConfig({required this.appKey});

  final String appKey;

  static const redirectUri = 'everyday://youversion-auth';
  static const callbackScheme = 'everyday';
  static const authorizeUrl = 'https://api.youversion.com/auth/authorize';
  static const callbackUrl = 'https://api.youversion.com/auth/callback';
  static const tokenUrl = 'https://api.youversion.com/auth/token';
  static const issuer = 'https://api.youversion.com';
  static const scope = 'openid profile email';

  bool get isConfigured => appKey.isNotEmpty;

  factory YouVersionAuthConfig.fromEnvironment() {
    final key = kYouVersionAppKeyFromDefine.isNotEmpty
        ? kYouVersionAppKeyFromDefine
        : kYouVersionAppKeyOverride;
    return YouVersionAuthConfig(appKey: key.trim());
  }
}
