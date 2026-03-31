import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Access the singleton Supabase client throughout the app.
SupabaseClient get supabase => Supabase.instance.client;

class StartupConfigException implements Exception {
  const StartupConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Initialize Supabase. Call once in main() before runApp().
Future<void> initSupabase() async {
  const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vwaoorotgfogohorprqy.supabase.co',
  );
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (anonKey.isEmpty) {
    throw const StartupConfigException(
      'Missing SUPABASE_ANON_KEY. Launch the app with --dart-define=SUPABASE_ANON_KEY=<your-anon-key>.',
    );
  }

  await Supabase.initialize(url: url, anonKey: anonKey, debug: kDebugMode);
}
