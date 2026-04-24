import 'package:ephimeries/domain/models/birth_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BirthProfile', () {
    test('serializes round-trip through JSON', () {
      final now = DateTime.utc(1990, 1, 15, 12, 30);
      final p = BirthProfile(
        id: 'abc-123',
        name: 'Test',
        dateTime: now,
        latitude: 28.6139,
        longitude: 77.2090,
        altitude: 216,
        placeLabel: 'New Delhi, India',
        createdAt: now,
      );
      final round = BirthProfile.fromJson(p.toJson());
      expect(round.id, p.id);
      expect(round.name, p.name);
      expect(round.dateTime, p.dateTime);
      expect(round.latitude, p.latitude);
      expect(round.longitude, p.longitude);
      expect(round.placeLabel, p.placeLabel);
    });

    test('copyWith preserves id and createdAt', () {
      final now = DateTime.utc(2024, 6, 1);
      final p = BirthProfile(
        id: 'id',
        name: 'A',
        dateTime: now,
        latitude: 0,
        longitude: 0,
        altitude: 0,
        placeLabel: 'x',
        createdAt: now,
      );
      final c = p.copyWith(name: 'B');
      expect(c.id, 'id');
      expect(c.name, 'B');
      expect(c.createdAt, now);
    });
  });
}
