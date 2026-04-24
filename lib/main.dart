import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/repositories/profile_repository.dart';
import 'data/services/timezone_service.dart';
import 'domain/models/app_settings.dart';
import 'domain/models/birth_profile.dart';
import 'domain/models/enums.dart';
import 'providers/chart_providers.dart';
import 'providers/hive_providers.dart';

Future<void> main() async {
  // Top-level error boundary (RCA-8). Captures:
  //   - Flutter framework errors via FlutterError.onError
  //   - Async/zone errors via runZonedGuarded
  //   - Synchronous boot failures via try/catch around bootstrap()
  // Without this a fatal init error would show a white screen on release.
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      dev.log(
        'Flutter framework error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      dev.log('Platform dispatcher error', error: error, stackTrace: stack);
      return true;
    };

    try {
      await _bootstrap();
    } catch (e, st) {
      dev.log('Bootstrap failed', error: e, stackTrace: st);
      runApp(_BootErrorApp(error: e, stackTrace: st));
    }
  }, (error, stack) {
    dev.log('Uncaught zone error', error: error, stackTrace: stack);
  });
}

Future<void> _bootstrap() async {
  // Bootstrap Hive and register all typed adapters.
  await Hive.initFlutter();
  _registerAdapters();

  // Load the IANA timezone database once for UTC conversion.
  TimezoneService.ensureInitialized();

  final profilesBox =
      await Hive.openBox<BirthProfile>(ProfileRepository.boxName);
  final settingsBox = await Hive.openBox<AppSettings>(kSettingsBoxName);

  // Bootstrap Swiss Ephemeris engine once at launch.
  final jyotish = await initializeJyotish();

  runApp(
    ProviderScope(
      overrides: [
        hiveBoxesProvider.overrideWithValue(
          HiveBoxes(profiles: profilesBox, settings: settingsBox),
        ),
        jyotishProvider.overrideWithValue(jyotish),
      ],
      child: const EphimeriesApp(),
    ),
  );
}

void _registerAdapters() {
  // Enums
  Hive.registerAdapter(ZodiacSignAdapter());
  Hive.registerAdapter(PlanetTypeAdapter());
  Hive.registerAdapter(NakshatraAdapter());
  Hive.registerAdapter(ChartStyleAdapter());
  Hive.registerAdapter(AyanamsaTypeAdapter());
  Hive.registerAdapter(AppThemeModeAdapter());
  Hive.registerAdapter(NameLanguageAdapter());
  Hive.registerAdapter(DegreeFormatAdapter());

  // Objects
  Hive.registerAdapter(BirthProfileAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
}

/// Shown when bootstrap (Hive open, engine init, adapter registration) fails.
/// Without this the user would see a white screen on release builds.
class _BootErrorApp extends StatelessWidget {
  const _BootErrorApp({required this.error, required this.stackTrace});
  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 16),
                Text(
                  "Ephimeries couldn't start",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'A fatal error occurred while initialising the app. '
                  'Please restart. If the problem persists, reinstall.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                if (kDebugMode) ...[
                  Text(
                    '$error',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        '$stackTrace',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
