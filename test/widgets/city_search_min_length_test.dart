import 'package:ephimeries/data/services/location_service.dart';
import 'package:ephimeries/widgets/common/city_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// BUG-8 regression — single-character queries must NOT trigger a geocoding
/// request. Two-character queries should.
class _RecordingLocationService extends LocationService {
  _RecordingLocationService();
  final List<String> searches = [];

  @override
  Future<List<CityMatch>> searchCity(String query) async {
    searches.add(query);
    return const <CityMatch>[
      CityMatch(label: 'Test', latitude: 0, longitude: 0),
    ];
  }

  @override
  Future<CityMatch?> currentLocation() async => null;
}

void main() {
  testWidgets('BUG-8: single char does not fire geocoding', (tester) async {
    final service = _RecordingLocationService();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CitySearchField(
            onSelected: (_) {},
            service: service,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'M');
    // Let the 350ms debounce elapse.
    await tester.pump(const Duration(milliseconds: 400));
    expect(service.searches, isEmpty,
        reason: 'Single char must be below min query length');
  });

  testWidgets('BUG-8: two chars triggers geocoding', (tester) async {
    final service = _RecordingLocationService();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CitySearchField(
            onSelected: (_) {},
            service: service,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Mu');
    await tester.pump(const Duration(milliseconds: 400));
    expect(service.searches, equals(['Mu']));
  });

  testWidgets('BUG-8: whitespace-padded single char still suppressed',
      (tester) async {
    final service = _RecordingLocationService();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CitySearchField(
            onSelected: (_) {},
            service: service,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '  M  ');
    await tester.pump(const Duration(milliseconds: 400));
    expect(service.searches, isEmpty);
  });
}
