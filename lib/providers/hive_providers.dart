import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../domain/models/app_settings.dart';
import '../domain/models/birth_profile.dart';
import '../data/repositories/profile_repository.dart';

/// Name of the Hive box storing the singleton [AppSettings] instance.
const String kSettingsBoxName = 'appSettings';

/// Key inside `kSettingsBoxName` that holds the settings object.
const String kSettingsKey = 'settings';

/// Holds references to the open Hive boxes. Populated at app bootstrap before
/// `runApp` by overriding this provider with a real [HiveBoxes] instance.
class HiveBoxes {
  const HiveBoxes({
    required this.profiles,
    required this.settings,
  });

  final Box<BirthProfile> profiles;
  final Box<AppSettings> settings;
}

final hiveBoxesProvider = Provider<HiveBoxes>((ref) {
  throw UnimplementedError(
    'hiveBoxesProvider must be overridden at app bootstrap '
    'via ProviderScope(overrides: [...]).',
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final boxes = ref.watch(hiveBoxesProvider);
  return ProfileRepository(boxes.profiles);
});
