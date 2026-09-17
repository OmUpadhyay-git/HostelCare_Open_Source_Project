import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/config/env.dart';
import 'app/hostelcare_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.current.supabaseUrl,
    publishableKey: Env.current.supabasePublishableKey,
  );

  runApp(
    const ProviderScope(
      child: HostelCareApp(),
    ),
  );
}

/// Supabase client instance for the app
final supabase = Supabase.instance.client;
