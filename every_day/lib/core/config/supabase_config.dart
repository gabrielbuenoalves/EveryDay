class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.anonKey});

  final String url;
  final String anonKey;

  bool get isConfigured => url.startsWith('https://') && anonKey.isNotEmpty;

  static SupabaseConfig fromEnvironment({
    String url = '',
    String anonKey = '',
  }) {
    return SupabaseConfig(url: url.trim(), anonKey: anonKey.trim());
  }
}
