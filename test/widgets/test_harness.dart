import 'package:ephimeries/domain/models/app_settings.dart';
import 'package:ephimeries/domain/models/enums.dart';
import 'package:ephimeries/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps a widget under test in a [ProviderScope] where [settingsProvider]
/// is pinned to a Sanskrit/DMS default. Avoids the Hive-boxes dependency
/// chain that real startup uses.
Widget harnessed(Widget child) {
  return ProviderScope(
    overrides: [
      settingsProvider.overrideWith(_StubSettingsNotifier.new),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

/// Same as [harnessed] but centres the child in a fixed-size box. Useful for
/// widgets that need a deterministic aspect ratio (chart painters).
Widget harnessedSized(Widget child, {double width = 400, double height = 400}) {
  return ProviderScope(
    overrides: [
      settingsProvider.overrideWith(_StubSettingsNotifier.new),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, height: height, child: child),
        ),
      ),
    ),
  );
}

/// Stub that never touches Hive. Seed it via `overrideWith` closure.
class _StubSettingsNotifier extends SettingsNotifier {
  _StubSettingsNotifier();

  @override
  AppSettings build() => AppSettings(
        nameLanguage: NameLanguage.sanskrit,
        degreeFormat: DegreeFormat.dms,
      );
}
