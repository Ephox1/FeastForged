import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Access the singleton Supabase client throughout the app.
SupabaseClient get supabase => Supabase.instance.client;

/// Initialize Supabase. Call once in main() before runApp().
Future<void> initSupabase() async {
  const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vwaoorotgfogohorprqy.supabase.co',
  );
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  assert(anonKey.isNotEmpty, 'SUPABASE_ANON_KEY must be set via --dart-define');

  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
    debug: kDebugMode,
  );
}
