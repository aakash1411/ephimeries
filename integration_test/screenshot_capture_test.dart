import 'dart:io';

import 'package:ephimeries/app.dart';
import 'package:ephimeries/domain/models/app_settings.dart';
import 'package:ephimeries/domain/models/birth_profile.dart';
import 'package:ephimeries/domain/models/enums.dart';
import 'package:ephimeries/providers/birth_profiles_provider.dart';
import 'package:ephimeries/data/services/timezone_service.dart';
import 'package:ephimeries/providers/chart_providers.dart';
import 'package:ephimeries/providers/dashboard_providers.dart';
import 'package:ephimeries/providers/hive_providers.dart';
import 'package:ephimeries/features/profile_shell/profile_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Drives the app through its marketing screens and writes
/// `publish/screenshots/<size>/NN_<name>.png` for each.
///
/// The flow auto-detects the form factor from the running device:
///   * iPhone (narrow) → the 8-screen tab-based set (home, natal, varga,
///     dasha, transit, analysis, AI reading, settings).
///   * iPad (wide, >= [kTabletBreakpoint]) → the multi-panel dashboard set
///     (home, dashboard, panel picker, settings, analysis, AI reading),
///     because iPad replaces the tabs with [IpadDashboardScreen].
///
/// Capture a set with `flutter drive` so the host-side driver
/// (`test_driver/integration_driver.dart`) can write the PNGs to disk:
///
/// ```
/// flutter drive \
///   --driver=test_driver/integration_driver.dart \
///   --target=integration_test/screenshot_capture_test.dart \
///   -d <simulator-uuid>
/// ```
///
/// One simulator run = one device size's full set. The output folder is
/// derived from the device's pixel size (see [_sizeFolder]): an
/// iPhone 16/17 Pro Max writes `6.9-inch/`, a 13-inch iPad writes
/// `13-inch-ipad/`.
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
    // Load the IANA timezone database so TimezoneService.formatInZone
    // works for the birth profiles seeded below.
    TimezoneService.ensureInitialized();

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
    await Hive.deleteBoxFromDisk(kDashboardBoxName);

    final profileBox = await Hive.openBox<BirthProfile>('birthProfiles');
    final settingsBox = await Hive.openBox<AppSettings>(kSettingsBoxName);
    // The iPad dashboard reads its panel layout from this box; without the
    // override the layout provider throws on tablet-sized devices.
    await Hive.openBox<dynamic>(kDashboardBoxName);

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
        onboardingCompleted: true,
      ),
    );
  });

  testWidgets('capture marketing screenshots', (tester) async {
    // Use the same initializer as the app so screenshots exercise the real
    // Swiss Ephemeris path (extracted data files), not the Moshier fallback.
    final engine = await initializeJyotish();

    final profilesBox = Hive.box<BirthProfile>('birthProfiles');
    final settingsBox = Hive.box<AppSettings>(kSettingsBoxName);
    final dashboardBox = Hive.box<dynamic>(kDashboardBoxName);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hiveBoxesProvider.overrideWithValue(
            HiveBoxes(profiles: profilesBox, settings: settingsBox),
          ),
          jyotishProvider.overrideWithValue(engine),
          dashboardBoxProvider.overrideWithValue(dashboardBox),
          activeProfileIdProvider.overrideWith((_) => 'reviewer'),
        ],
        child: const EphimeriesApp(),
      ),
    );
    // Splash waits 400ms before redirecting to /home.
    await tester.pump(const Duration(milliseconds: 800));
    await _settle(tester);

    // 1. Home / profile picker.
    await _shoot(binding, 1, 'home', captions[1]!);

    // Tap the Reviewer profile card (the Leo-lagna reference chart) to
    // enter the chart view. On iPhone this is the tab shell; on iPad it is
    // the multi-panel dashboard.
    await tester.tap(find.widgetWithText(Card, 'Reviewer'));
    await _settle(tester);

    if (_isTablet()) {
      await _captureIpadFlow(binding, tester);
    } else {
      await _capturePhoneFlow(binding, tester, captions);
    }
  });
}

/// iPhone tab-based flow: 8 screens reached through the bottom navigation
/// bar owned by [ProfileShell].
Future<void> _capturePhoneFlow(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  Map<int, String> captions,
) async {
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

  // 6. Analysis tab.
  await tester.tap(find.byIcon(Icons.insights));
  await _settle(tester);
  await _shoot(binding, 6, 'analysis_overview', captions[6]!);

  // 7. AI reading section. Scroll down within whichever scrollable the
  // analysis screen renders (ListView or SingleChildScrollView) so the
  // AI card is visible.
  final scrollable = find.byType(Scrollable);
  if (scrollable.evaluate().isNotEmpty) {
    await tester.drag(scrollable.first, const Offset(0, -1200));
    await _settle(tester);
  }
  await _shoot(binding, 7, 'analysis_ai', captions[7]!);

  // 8. Settings (opens over the shell via the app-bar icon).
  await tester.tap(find.byIcon(Icons.settings_outlined).first);
  await _settle(tester);
  await _shoot(binding, 8, 'settings_legal', captions[8]!);
}

/// iPad dashboard flow. [IpadDashboardScreen] shows five live panels at
/// once and hosts Analysis/Settings behind app-bar icons, so the set is
/// shaped differently from the phone tabs.
Future<void> _captureIpadFlow(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  // 2. The five-panel dashboard (D1, D9, dasha, planet table, transit).
  await _shoot(binding, 2, 'dashboard', 'Five live charts on one screen.');

  // 3. Panel-type picker — shows the dashboard is fully customisable.
  // Defensive: if the sheet can't be driven, skip without failing the run.
  final tune = find.byIcon(Icons.tune);
  if (tune.evaluate().isNotEmpty) {
    await tester.tap(tune.first);
    await _settle(tester);
    await _shoot(binding, 3, 'panel_picker', 'Swap any panel: D1 to D60.');
    // Dismiss the modal sheet by tapping the scrim above it.
    await tester.tapAt(const Offset(40, 40));
    await _settle(tester);
  }

  // 4. Settings (pushed over the dashboard via the app-bar gear), then back.
  await tester.tap(find.byIcon(Icons.settings_outlined).first);
  await _settle(tester);
  await _shoot(binding, 4, 'settings_legal', 'Open-source under AGPL-3.0.');
  await tester.pageBack();
  await _settle(tester);

  // 5. Analysis (pushed via the insights icon).
  await tester.tap(find.byIcon(Icons.insights).first);
  await _settle(tester);
  await _shoot(binding, 5, 'analysis_overview', 'Key placements and dasha.');

  // 6. AI reading — scroll the analysis list to reveal the on-device card.
  final scrollable = find.byType(Scrollable);
  if (scrollable.evaluate().isNotEmpty) {
    await tester.drag(scrollable.first, const Offset(0, -1400));
    await _settle(tester);
  }
  await _shoot(binding, 6, 'analysis_ai', 'On-device AI reading.');
}

/// Whether the running device uses the iPad dashboard layout. Mirrors the
/// app's own breakpoint in [ProfileShell] ([kTabletBreakpoint] logical px
/// on the short edge).
bool _isTablet() {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortLogical =
      view.physicalSize.shortestSide / view.devicePixelRatio;
  return shortLogical >= kTabletBreakpoint;
}

/// Pump until idle. The default timeout in `pumpAndSettle` is 10 s; we
/// reduce it to 3 s and add a fallback `pump` so a stuck animation
/// does not stall the entire run.
Future<void> _settle(WidgetTester tester) async {
  // Give page transitions and async chart computation time to finish
  // before we capture. A 500ms pump on top of pumpAndSettle covers cases
  // where FutureBuilders spawn micro-frames after the animation ends.
  try {
    await tester.pumpAndSettle(const Duration(seconds: 6));
  } catch (_) {
    // Fallback: timed out (e.g. infinite ticker); at least give the UI
    // a moment before shooting.
  }
  await tester.pump(const Duration(milliseconds: 500));
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
  // Convert the iOS Flutter surface to an image so the engine can hand
  // PNG bytes to the host driver. On macOS this is a no-op.
  if (Platform.isIOS) {
    await binding.convertFlutterSurfaceToImage();
  }
  final size = _sizeFolder();
  final relName =
      '$size/${step.toString().padLeft(2, '0')}_$name';
  // The host-side driver (test_driver/integration_driver.dart) receives
  // these bytes and writes them to publish/screenshots/<size>/NN_<name>.png.
  await binding.takeScreenshot(relName);
}

/// Pixel-size bucket used to name the output folder, matched to App Store
/// Connect display classes. Buckets by the short edge in physical pixels:
///   * 13-inch iPad (iPad Pro 13" = 2064 x 2752, iPad Air 13" = 2048 x 2732)
///   * 6.9-inch iPhone (iPhone 16/17 Pro Max = 1320 x 2868)
///   * 6.5-inch iPhone (iPhone 14 Plus = 1284 x 2778)
String _sizeFolder() {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortPx = view.physicalSize.shortestSide.round();
  if (shortPx >= 2000) return '13-inch-ipad';
  if (shortPx >= 1290) return '6.9-inch';
  if (shortPx >= 1242) return '6.5-inch';
  return 'other-${shortPx}px';
}
