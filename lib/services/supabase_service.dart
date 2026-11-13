import 'package:supabase_flutter/supabase_flutter.dart';

/// Starts Supabase (Auth, Postgres and Storage).
///
/// The keys are read when the app is built and are never committed:
///   flutter run --dart-define-from-file=env.json
/// `env.json` is git-ignored; `env.example.json` shows its format.
/// Without keys the app runs in local demo mode (see LocalReportStore).
class SupabaseService {
  static const String _url = String.fromEnvironment('SUPABASE_URL');
  static const String _key = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  /// Storage bucket that holds the report photos (see supabase/schema.sql).
  static const String photoBucket = 'report-photos';

  static bool get isConfigured => _url.isNotEmpty && _key.isNotEmpty;

  static Future<void> init() async {
    if (!isConfigured) return;
    await Supabase.initialize(url: _url, publishableKey: _key);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
