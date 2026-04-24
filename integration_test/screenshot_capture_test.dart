import 'dart:io';

import 'package:ephimeries/app.dart';
import 'package:ephimeries/domain/models/app_settings.dart';
import 'package:ephimeries/domain/models/birth_profile.dart';
import 'package:ephimeries/domain/models/enums.dart';
import 'package:ephimeries/providers/birth_profiles_provider.dart';
import 'package:ephimeries/providers/hive_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jyotish/jyotish.dart' as jy;
import 'package:path_provider/path_provider.dart';

/// Drives the app through 8 marketing screens and writes
/// `publish/screenshots/<size>/NN_<name>.png` for each. Run with:
///
/// ```
/// flutter test integration_test/screenshot_capture_test.dart \
///   --device-id <iPhone-16-Pro-Max-simulator-uuid>
/// ```
///
/// One simulator run = one device size's full set. Repeat for the 6.5"
/// simulator if you want a second size. Captions can be edited inside
/// [_captions]; the same caption text is used by App Store Connect.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Captions paired by 1-based step number. Keep ≤ 60 chars each;
  // anything longer wraps awkwardly on smaller devices.
  const captions = <int, String>{
    1: 'Authentic Vedic charts. Your data stays on your phone.',
    2: 'North or South Indian style, your pick.',
    3: 'D1 to D60: navamsa, dashamsa, and more.',
    4: 'Track Maha and Antar with end dates.',
    5: 'See today\'s transits on your natal chart.',
    6: 'Top placements, current dasha, and three transit reads.',
    7: 'On-device AI reading. Nothing leaves your device.',
    8: 'Open-source under AGPL-3.0. No tracking.',
  };

  setUpAll(() async {
    // Initialise Hive in the app's documents dir so the running app reads
    // the same boxes we seed below.
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapter(BirthProfileAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(ChartStyleAdapter());
    Hive.registerAdapter(AyanamsaTypeAdapter());
    Hive.registerAdapter(AppThemeModeAdapter());
    Hive.registerAdapter(NameLanguageAdapter());
    Hive.registerAdapter(DegreeFormatAdapter());

    // Wipe any leftover state from a previous run.
    await Hive.deleteBoxFromDisk('birthProfiles');
    await Hive.deleteBoxFromDisk(kSettingsBoxName);

    final profileBox = await Hive.openBox<BirthProfile>('birthProfiles');
    final settingsBox = await Hive.openBox<AppSettings>(kSettingsBoxName);

    // Seed two demo profiles so the home screen looks lively.
    await profileBox.put(
      'reviewer',
      BirthProfile(
        id: 'reviewer',
        name: 'Reviewer',
        dateTime: DateTime.utc(1990, 5, 15, 9, 0), // 14:30 IST
        latitude: 28.6139,
        longitude: 77.2090,
        altitude: 216,
        placeLabel: 'New Delhi, India',
        createdAt: DateTime.utc(2024, 1, 1),
        timezoneName: 'Asia/Kolkata',
      ),
    );
    await profileBox.put(
      'demo',
      BirthProfile(
        id: 'demo',
        name: 'Demo',
        dateTime: DateTime.utc(1985, 11, 3, 22, 17),
        latitude: 19.0760,
        longitude: 72.8777,
        altitude: 14,
        placeLabel: 'Mumbai, India',
        createdAt: DateTime.utc(2024, 1, 2),
        timezoneName: 'Asia/Kolkata',
      ),
    );

    // Skip the legal disclaimer on first launch and pre-grant the Pro
    // Analysis entitlement so the screenshot script can reach the
    // gated tab.
    await settingsBox.put(
      kSettingsKey,
      AppSettings(
        acceptedLegalVersion: 999, // any value >= kLegalTextVersion
        analysisEntitled: true,
      ),
    );
  });

  testWidgets('capture marketing screenshots', (tester) async {
    final engine = jy.Jyotish();
    await engine.initialize();

    final profilesBox = Hive.box<BirthProfile>('birthProfiles');
    final settingsBox = Hive.box<AppSettings>(kSettingsBoxName);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hiveBoxesProvider.overrideWithValue(
            HiveBoxes(profiles: profilesBox, settings: settingsBox),
          ),
          activeProfileIdProvider.overrideWith((_) => 'reviewer'),
        ],
        child: const EphimeriesApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 1. Home / profile picker.
    await _settle(tester);
    await _shoot(binding, 1, 'home', captions[1]!);

    // Tap into Reviewer to enter the chart shell. Adjust the finder
    // to match your home cell.
    await tester.tap(find.text('Reviewer').first);
    await _settle(tester);

    // 2. Natal chart D1.
    await _shoot(binding, 2, 'natal_d1', captions[2]!);

    // 3. Divisional charts → tap Divisional tab.
    await tester.tap(find.byIcon(Icons.grid_4x4));
    await _settle(tester);
    await _shoot(binding, 3, 'divisional_d9', captions[3]!);

    // 4. Dasha tab.
    await tester.tap(find.byIcon(Icons.timeline));
    await _settle(tester);
    await _shoot(binding, 4, 'dasha', captions[4]!);

    // 5. Transit tab.
    await tester.tap(find.byIcon(Icons.public));
    await _settle(tester);
    await _shoot(binding, 5, 'transit', captions[5]!);

    // 6. Analysis tab (entitlement pre-granted in setUpAll).
    await tester.tap(find.byIcon(Icons.insights));
    await _settle(tester);
    await _shoot(binding, 6, 'analysis_overview', captions[6]!);

    // 7. AI reading section. Scroll to the bottom of the analysis
    // screen so the AI card is visible.
    await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
    await _settle(tester);
    await _shoot(binding, 7, 'analysis_ai', captions[7]!);

    // 8. Settings.
    await tester.tap(find.byIcon(Icons.settings));
    await _settle(tester);
    await _shoot(binding, 8, 'settings_legal', captions[8]!);
  });
}

/// Pump until idle. The default timeout in `pumpAndSettle` is 10 s; we
/// reduce it to 3 s and add a fallback `pump` so a stuck animation
/// does not stall the entire run.
Future<void> _settle(WidgetTester tester) async {
  try {
    await tester.pumpAndSettle(const Duration(seconds: 3));
  } catch (_) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

/// Capture a screenshot via the integration-test binding and write it
/// to `publish/screenshots/<size>/NN_<name>.png`. The `<size>` segment
/// is derived from the device pixel ratio so a single test run targeting
/// the 6.9-inch sim writes to a different folder than a 6.5-inch run.
Future<void> _shoot(
  IntegrationTestWidgetsFlutterBinding binding,
  int step,
  String name,
  String caption,
) async {
  // The actual integration-test runner exposes `convertFlutterSurfaceToImage`
  // for engine-side capture on iOS; on macOS we fall back to taking the
  // PNG bytes from the binding.
  await binding.convertFlutterSurfaceToImage();
  final size = _sizeFolder();
  final dir = Directory('publish/screenshots/$size')..createSync(recursive: true);
  final path = '${dir.path}/${step.toString().padLeft(2, '0')}_$name.png';
  await binding.takeScreenshot(path);
  // Caption metadata sidecar — the App Store Connect uploader reads
  // `*.txt` next to each `*.png` to populate per-screenshot localised
  // captions. (Optional; ignored if your uploader doesn't support it.)
  await File('${path.substring(0, path.length - 4)}.txt')
      .writeAsString(caption);
}

/// Pixel-size bucket used to name the output folder. iPhone 16 Pro Max
/// (6.9-inch) has 1290 x 2796 logical pixels; iPhone 14 Plus (6.5-inch)
/// has 1284 x 2778. We bucket by short edge so a single test invocation
/// writes to the right folder.
String _sizeFolder() {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortPx = view.physicalSize.shortestSide.round();
  if (shortPx >= 1290) return '6.9-inch';
  if (shortPx >= 1242) return '6.5-inch';
  return 'other-${shortPx}px';
}
