import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/content/legal/legal_text.dart';
import '../features/analysis/analysis_screen.dart';
import '../features/birth_entry/birth_entry_screen.dart';
import '../features/dasha/dasha_screen.dart';
import '../features/divisional_charts/divisional_chart_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/profile_selector_tab.dart';
import '../features/legal/disclaimer_gate.dart';
import '../features/natal_chart/natal_chart_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/profile_shell/profile_shell.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/transit/transit_screen.dart';
import '../providers/settings_provider.dart';

/// Routes the user can land on **before** they accept the legal disclaimer.
/// Anything not in this set is redirected to `/legal` until consent is
/// recorded for the current [kLegalTextVersion].
const Set<String> _kPreConsentRoutes = {'/legal', '/'};

/// Declarative app routing. Each profile tab is a nested sub-route inside
/// a shell that owns the bottom navigation bar.
///
/// Built as a Riverpod provider so the global `redirect` closure can read
/// [settingsProvider] (consent + entitlement flags) without resorting to
/// a service-locator.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final settings = ref.read(settingsProvider);
      final loc = state.matchedLocation;
      // Block every route until the user has accepted the current version
      // of the in-app Terms / Privacy. Splash + the gate itself are exempt.
      if (settings.acceptedLegalVersion < kLegalTextVersion &&
          !_kPreConsentRoutes.contains(loc)) {
        return '/legal';
      }
      // After consent, never strand the user on /legal.
      if (settings.acceptedLegalVersion >= kLegalTextVersion &&
          loc == '/legal') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/legal', builder: (_, _) => const DisclaimerGate()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    GoRoute(
      path: '/profile/new',
      builder: (_, _) => const BirthEntryScreen(),
    ),
    GoRoute(
      path: '/profile/:id/edit',
      builder: (_, state) =>
          BirthEntryScreen(editProfileId: state.pathParameters['id']),
    ),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    GoRoute(path: '/paywall', builder: (_, _) => const PaywallScreen()),
    ShellRoute(
      builder: (context, state, child) {
        final id = state.pathParameters['id']!;
        return ProfileShell(profileId: id, child: child);
      },
      routes: [
        GoRoute(
          path: '/profile/:id/home',
          builder: (_, _) => const ProfileSelectorTab(),
        ),
        GoRoute(
          path: '/profile/:id/natal',
          builder: (_, _) => const NatalChartScreen(),
        ),
        GoRoute(
          path: '/profile/:id/divisional',
          builder: (_, _) => const DivisionalChartScreen(),
        ),
        GoRoute(
          path: '/profile/:id/dasha',
          builder: (_, _) => const DashaScreen(),
        ),
        GoRoute(
          path: '/profile/:id/transit',
          builder: (_, _) => const TransitScreen(),
        ),
        GoRoute(
          path: '/profile/:id/analysis',
          builder: (_, _) => const AnalysisScreen(),
        ),
      ],
    ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
});
