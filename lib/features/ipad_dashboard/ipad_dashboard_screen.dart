import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/birth_profiles_provider.dart';
import '../../providers/dashboard_providers.dart';
import 'dashboard_panel.dart';

/// iPad-optimized multi-chart dashboard that replaces the tab-based
/// [ProfileShell] when the screen width exceeds the tablet breakpoint.
///
/// Layout (5 panels):
/// ```
/// ┌──────────┬──────────┬──────────┐
/// │  slot 0  │  slot 1  │  slot 2  │
/// ├──────────┴────┬─────┴──────────┤
/// │    slot 3     │    slot 4      │
/// └───────────────┴────────────────┘
/// ```
class IpadDashboardScreen extends ConsumerWidget {
  const IpadDashboardScreen({super.key, required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sync active profile with route (mirrors ProfileShell logic).
    final current = ref.read(activeProfileIdProvider);
    if (current != profileId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ref.read(activeProfileIdProvider.notifier).state = profileId;
      });
    }

    final profile = ref.watch(activeProfileProvider);
    final layout = ref.watch(dashboardLayoutProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'All profiles',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text(profile?.name ?? 'Dashboard'),
        actions: [
          IconButton(
            tooltip: 'AI Analysis',
            icon: const Icon(Icons.insights),
            onPressed: () => context.push('/analysis/$profileId'),
          ),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              // Top row: 3 equal panels
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    for (int i = 0; i < 3 && i < layout.length; i++)
                      Expanded(child: DashboardPanel(index: i)),
                  ],
                ),
              ),
              // Bottom row: 2 panels
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    for (int i = 3; i < 5 && i < layout.length; i++)
                      Expanded(child: DashboardPanel(index: i)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
