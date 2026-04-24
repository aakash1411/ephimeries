import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/birth_profile.dart';

/// Persists [BirthProfile] entries in a Hive box. One box, one app-wide
/// instance — instantiated by the provider layer after `Hive.initFlutter`.
class ProfileRepository {
  ProfileRepository(this._box);

  static const String boxName = 'birthProfiles';

  final Box<BirthProfile> _box;
  final Uuid _uuid = const Uuid();

  /// All profiles sorted by most-recently created first.
  List<BirthProfile> getAll() {
    final values = _box.values.toList(growable: false);
    values.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return values;
  }

  BirthProfile? getById(String id) => _box.get(id);

  /// Create a new profile, generating a fresh UUID.
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
    final profile = BirthProfile(
      id: _uuid.v4(),
      name: name,
      dateTime: dateTime.toUtc(),
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      placeLabel: placeLabel,
      createdAt: DateTime.now().toUtc(),
      birthTimeUnknown: birthTimeUnknown,
      timezoneName: timezoneName,
    );
    await _box.put(profile.id, profile);
    return profile;
  }

  Future<void> update(BirthProfile profile) => _box.put(profile.id, profile);

  Future<void> delete(String id) => _box.delete(id);
}
