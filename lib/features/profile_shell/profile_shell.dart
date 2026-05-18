import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/birth_profiles_provider.dart';
import '../ipad_dashboard/ipad_dashboard_screen.dart';

/// Minimum width (logical pixels) to trigger the iPad dashboard layout.
const double kTabletBreakpoint = 700;

/// Tab shell around the 4 chart views for a single profile.
///
/// On devices wider than [kTabletBreakpoint] (iPad), this automatically shows
/// the multi-chart [IpadDashboardScreen] instead of the tab-based phone UI.
class ProfileShell extends ConsumerWidget {
  const ProfileShell({
    super.key,
    required this.profileId,
    required this.child,
  });

  final String profileId;
  final Widget child;

  static const _tabs = <_TabDef>[
    _TabDef('home', 'Home', Icons.people_outline),
    _TabDef('natal', 'Natal', Icons.auto_awesome),
    _TabDef('divisional', 'Varga', Icons.grid_4x4),
    _TabDef('dasha', 'Dasha', Icons.timeline),
    _TabDef('transit', 'Transit', Icons.public),
    _TabDef('analysis', 'Analysis', Icons.insights),
  ];

  int _indexForLocation(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.endsWith('/${_tabs[i].segment}')) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet =
        MediaQuery.sizeOf(context).shortestSide >= kTabletBreakpoint;

    if (isTablet) {
      return IpadDashboardScreen(profileId: profileId);
    }

    // Keep the active profile in sync with the route. Only write when the
    // route's profileId genuinely differs from the current selection — this
    // fires once per navigation, not per rebuild (BUG-5).
    final current = ref.read(activeProfileIdProvider);
    if (current != profileId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!ref.context.mounted) return;
        ref.read(activeProfileIdProvider.notifier).state = profileId;
      });
    }

    final location = GoRouterState.of(context).uri.path;
    final index = _indexForLocation(location);
    final profile = ref.watch(activeProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(profile?.name ?? 'Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/$profileId/edit'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          context.go('/profile/$profileId/${_tabs[i].segment}');
        },
        destinations: [
          for (final t in _tabs)
            NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}

class _TabDef {
  const _TabDef(this.segment, this.label, this.icon);
  final String segment;
  final String label;
  final IconData icon;
}
