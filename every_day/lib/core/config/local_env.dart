/// Cole a URL e a anon key do Supabase aqui (Settings → API),
/// ou passe --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
const kSupabaseUrlOverride = 'https://izyjcsqqigmypcfqfdcq.supabase.co';
const kSupabaseAnonKeyOverride = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml6eWpjc3FxaWdteXBjZnFmZGNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgwNTA4MzMsImV4cCI6MjEwMzYyNjgzM30.BwgSs9efJXdiEJayVN0F41K-zATzsFo_J7eGQXU3vnc';

const kSupabaseUrlFromDefine = String.fromEnvironment('SUPABASE_URL');
const kSupabaseAnonKeyFromDefine = String.fromEnvironment('SUPABASE_ANON_KEY');

/// Client ID OAuth da YouVersion (o `app_key` do portal). Também usado como
/// `--dart-define=YVP_APP_KEY=...`. Callback a cadastrar no portal:
/// `everyday://youversion-auth`
const kYouVersionAppKeyOverride = '';
const kYouVersionAppKeyFromDefine = String.fromEnvironment('YVP_APP_KEY');
