import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/birth_profile.dart';
import 'hive_providers.dart';

/// CRUD-flavoured notifier over the stored [BirthProfile]s.
class BirthProfilesNotifier extends AsyncNotifier<List<BirthProfile>> {
  @override
  Future<List<BirthProfile>> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    return repo.getAll();
  }

  Future<BirthProfile> create({
    required String name,
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    required double altitude,
    required String placeLabel,
    bool birthTimeUnknown = false,
    String timezoneName = 'UTC',
  }) async {
    final repo = ref.read(profileRepositoryProvider);
    final profile = await repo.create(
      name: name,
      dateTime: dateTime,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      placeLabel: placeLabel,
      birthTimeUnknown: birthTimeUnknown,
      timezoneName: timezoneName,
    );
    state = AsyncData(repo.getAll());
    return profile;
  }

  Future<void> save(BirthProfile profile) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.update(profile);
    state = AsyncData(repo.getAll());
  }

  Future<void> delete(String id) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.delete(id);
    state = AsyncData(repo.getAll());
  }
}

final birthProfilesProvider =
    AsyncNotifierProvider<BirthProfilesNotifier, List<BirthProfile>>(
  BirthProfilesNotifier.new,
);

/// Currently-selected profile id. Use [activeProfileProvider] to resolve the
/// actual [BirthProfile].
final activeProfileIdProvider = StateProvider<String?>((_) => null);

final activeProfileProvider = Provider<BirthProfile?>((ref) {
  final id = ref.watch(activeProfileIdProvider);
  if (id == null) return null;
  final profiles = ref.watch(birthProfilesProvider).valueOrNull ?? const [];
  for (final p in profiles) {
    if (p.id == id) return p;
  }
  return null;
});
