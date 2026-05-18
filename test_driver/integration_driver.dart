import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Host-side driver that receives screenshot bytes from
/// `integration_test/screenshot_capture_test.dart` and writes them to
/// `publish/screenshots/<size>/NN_<name>.png`.
///
/// Run with:
///
/// ```
/// flutter drive \
///   --driver=test_driver/integration_driver.dart \
///   --target=integration_test/screenshot_capture_test.dart \
///   -d <simulator-uuid>
/// ```
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      // `name` is the relative path we passed from the test, e.g.
      // `6.9-inch/01_home`.
      final file = File('publish/screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
