import 'package:ephimeries/data/repositories/chart_repository.dart';
import 'package:ephimeries/data/repositories/mock_chart_repository.dart';
import 'package:ephimeries/domain/models/birth_profile.dart';
import 'package:ephimeries/domain/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

BirthProfile _fixture() {
  final birth = DateTime.utc(1990, 5, 15, 9, 0);
  return BirthProfile(
    id: 'test-profile',
    name: 'Test',
    dateTime: birth,
    latitude: 27.7172,
    longitude: 85.3240,
    altitude: 1300,
    placeLabel: 'Kathmandu, Nepal',
    createdAt: birth,
  );
}

void main() {
  group('MockChartRepository', () {
    const ChartRepository repo = MockChartRepository();

    test('natal chart has 9 planets, 12 houses, and an ascendant', () async {
      final chart = await repo.getNatalChart(_fixture());
      expect(chart.planets.length, 9);
      expect(chart.houseData.length, 12);
      expect(chart.divisor, 1);
      expect(ZodiacSign.values, contains(chart.ascendantSign));
    });

    test('divisional chart carries the divisor through', () async {
      final d9 = await repo.getDivisionalChart(_fixture(), 9);
      expect(d9.divisor, 9);
      expect(d9.planets.length, 9);
    });

    test('dasha produces Maha + Antar + current', () async {
      final dasha = await repo.getDasha(_fixture());
      expect(dasha.mahaDasha.level, 1);
      expect(dasha.antarDasha.level, 2);
      expect(dasha.mahaSequence, isNotEmpty);
    });

    test('transit chart re-anchors to transit datetime', () async {
      final at = DateTime.utc(2024, 1, 1, 12, 0);
      final chart = await repo.getTransitChart(_fixture(), at);
      expect(chart.profile.dateTime, at);
    });

    test('panchang has the 5 limbs', () async {
      final p = await repo.getPanchang(_fixture(), DateTime(2024, 1, 1));
      expect(p.tithiName, isNotEmpty);
      expect(p.yogaName, isNotEmpty);
      expect(p.karanaName, isNotEmpty);
      expect(p.weekday, isNotEmpty);
      expect(Nakshatra.values, contains(p.nakshatra));
    });
  });
}
