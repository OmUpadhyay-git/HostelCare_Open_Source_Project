class Env {
  final String appName;
  final String supabaseUrl;
  final String supabasePublishableKey;
  final bool isDev;

  const Env._({
    required this.appName,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.isDev,
  });

  static const _dev = Env._(
    appName: 'HostelCare Dev',
    supabaseUrl: String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
    supabasePublishableKey: String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
    isDev: true,
  );

  static const _prod = Env._(
    appName: 'HostelCare',
    supabaseUrl: String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
    supabasePublishableKey: String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
    isDev: false,
  );

  static Env get current => _isProd ? _prod : _dev;

  static bool get _isProd => bool.fromEnvironment('PROD', defaultValue: false);

  bool get isConfigured => supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
