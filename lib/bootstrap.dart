import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';

import 'core/storage/hive_service.dart';
import 'app.dart';

/// Bootstrap the application environment and core services.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _report(details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    _report(error, stack);
    return true;
  };

  // 1. Load environment
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('No .env file found. Falling back to default configs.');
  }

  // Crash reporting is on only when SENTRY_DSN is set (a DSN is public-safe).
  if (Env.sentryDsn.isNotEmpty) {
    await Sentry.init((o) {
      o.dsn = Env.sentryDsn;
      o.sendDefaultPii = false;
    });
  }

  // Initialize Supabase. Auth cannot work without it, so fail loudly instead of
  // crashing later on the first `Supabase.instance` access.
  if (Env.supabaseUrl.isEmpty || Env.supabaseAnonKey.isEmpty) {
    debugPrint('Supabase credentials missing; app cannot start.');
    runApp(const _ConfigErrorApp());
    return;
  }
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  // 2. Initialize Hive Storage
  final hiveService = HiveService();
  await hiveService.init();

  // 3. Run app with ProviderScope overriding synchronous services
  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const IgoApp(),
    ),
  );
}

void _report(Object error, StackTrace? stack) {
  if (Env.sentryDsn.isNotEmpty) Sentry.captureException(error, stackTrace: stack);
}

/// Shown when required configuration is missing from the bundled `.env`.
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This build is missing its configuration. '
              'Please reinstall or update the app.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
