import 'package:ephimeries/domain/models/birth_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// RCA-6 regression — value-equality on BirthProfile must:
///   1. treat rename-only edits as equal (so Riverpod family keys reuse cache)
///   2. treat date/lat/lon/tz/alt changes as NOT equal (so charts recompute)
void main() {
  BirthProfile base() => BirthProfile(
        id: 'p1',
        name: 'Alice',
        dateTime: DateTime.utc(1990, 5, 15, 8, 45),
        latitude: 27.7172,
        longitude: 85.3240,
        altitude: 1300,
        placeLabel: 'Kathmandu, Nepal',
        createdAt: DateTime.utc(2020, 1, 1),
        birthTimeUnknown: false,
        timezoneName: 'Asia/Kathmandu',
      );

  test('identical profiles are equal', () {
    expect(base(), equals(base()));
    expect(base().hashCode, base().hashCode);
  });

  test('rename-only edit keeps equality (same chart key)', () {
    final renamed = base().copyWith(name: 'Renamed');
    expect(renamed, equals(base()));
    expect(renamed.hashCode, base().hashCode);
  });

  test('placeLabel-only edit keeps equality', () {
    final relabelled = base().copyWith(placeLabel: 'Kathmandu, Bagmati, Nepal');
    expect(relabelled, equals(base()));
  });

  test('dateTime change breaks equality', () {
    final shifted = base().copyWith(dateTime: DateTime.utc(1990, 5, 15, 8, 46));
    expect(shifted, isNot(equals(base())));
  });

  test('latitude change breaks equality', () {
    final moved = base().copyWith(latitude: 27.8);
    expect(moved, isNot(equals(base())));
  });

  test('timezone change breaks equality', () {
    final rezoned = base().copyWith(timezoneName: 'Asia/Kolkata');
    expect(rezoned, isNot(equals(base())));
  });

  test('birthTimeUnknown toggle breaks equality', () {
    final unknown = base().copyWith(birthTimeUnknown: true);
    expect(unknown, isNot(equals(base())));
  });
}
