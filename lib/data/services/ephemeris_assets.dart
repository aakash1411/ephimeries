import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Swiss Ephemeris data files bundled by the `sweph` package under
/// `packages/sweph/assets/ephe/`. The `_18` blocks cover 1800-2399 CE,
/// which matches the range advertised in the open-source notice and the
/// App Store description.
const List<String> _kEphemerisFiles = [
  'sepl_18.se1', // main planets
  'semo_18.se1', // moon
  'seas_18.se1', // main asteroids / nodes
  'seleapsec.txt', // leap seconds (UT ↔ TT precision)
  'sefstars.txt', // fixed stars
  'seorbel.txt', // orbital elements
  'seasnam.txt', // asteroid names
];

const String _kAssetPrefix = 'packages/sweph/assets/ephe/';

/// Copies the bundled Swiss Ephemeris files into a writable directory and
/// returns its path.
///
/// The Jyotish engine links its own Swiss Ephemeris binary but does not set
/// an ephemeris path on its own. Without this, `swe_calc_ut` cannot find the
/// `.se1` data and silently falls back to the lower-precision Moshier
/// approximation. Extracting the bundled files and pointing the engine at
/// them keeps planetary positions at the arc-second precision the app
/// advertises.
///
/// Files are copied once and reused on subsequent launches. A missing
/// supplementary file (e.g. the fixed-star catalogue) is non-fatal; the core
/// `.se1` blocks are what drive planet, Moon, and node positions.
Future<String> ensureEphemerisFiles() async {
  final supportDir = await getApplicationSupportDirectory();
  final epheDir = Directory('${supportDir.path}/ephe');
  if (!epheDir.existsSync()) {
    epheDir.createSync(recursive: true);
  }

  for (final name in _kEphemerisFiles) {
    final file = File('${epheDir.path}/$name');
    if (file.existsSync() && file.lengthSync() > 0) continue;
    try {
      final data = await rootBundle.load('$_kAssetPrefix$name');
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    } catch (_) {
      // Asset not bundled in this build — skip; core blocks still load.
    }
  }
  return epheDir.path;
}
