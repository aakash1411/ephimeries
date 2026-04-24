import 'package:ephimeries/domain/models/birth_profile.dart';
import 'package:ephimeries/features/birth_entry/birth_entry_screen.dart';
import 'package:ephimeries/providers/birth_profiles_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// BUG-2 regression — opening the edit form for a profile that has just been
/// deleted must not throw a StateError or show a red error screen. Expected
/// behaviour: redirect to /home via go_router.
void main() {
  testWidgets('edit form redirects home when profile is deleted', (t) async {
    final p = BirthProfile(
      id: 'p1',
      name: 'Alice',
      dateTime: DateTime.utc(1990, 5, 15, 8, 45),
      latitude: 27.7172,
      longitude: 85.3240,
      altitude: 0,
      placeLabel: 'Kathmandu, Nepal',
      createdAt: DateTime.utc(2020, 1, 1),
      timezoneName: 'Asia/Kathmandu',
    );

    final controller = _ControllableNotifier([p]);

    var landedOnHome = false;
    final router = GoRouter(
      initialLocation: '/profile/p1/edit',
      routes: [
        GoRoute(
          path: '/profile/:id/edit',
          builder: (_, s) =>
              BirthEntryScreen(editProfileId: s.pathParameters['id']),
        ),
        GoRoute(
          path: '/home',
          builder: (_, _) {
            landedOnHome = true;
            return const Scaffold(body: Text('home'));
          },
        ),
      ],
    );

    await t.pumpWidget(
      ProviderScope(
        overrides: [
          birthProfilesProvider.overrideWith(() => controller),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull,
        reason: 'initial edit form should build without exception');

    // Simulate concurrent deletion from another part of the app.
    controller.remove('p1');
    await t.pumpAndSettle();

    expect(landedOnHome, isTrue,
        reason: 'Edit screen should redirect to /home, not throw StateError');
    expect(t.takeException(), isNull);
  });
}

/// Notifier stand-in that bypasses Hive so the widget test can run without
/// any platform plumbing.
class _ControllableNotifier extends BirthProfilesNotifier {
  _ControllableNotifier(this._initial);
  final List<BirthProfile> _initial;

  @override
  Future<List<BirthProfile>> build() async => List.of(_initial);

  void remove(String id) {
    final current = state.valueOrNull ?? const <BirthProfile>[];
    state = AsyncData(current.where((p) => p.id != id).toList());
  }
}
