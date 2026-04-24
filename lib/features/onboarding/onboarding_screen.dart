import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/enums.dart';
import '../../providers/settings_provider.dart';

/// First-launch onboarding. 3 informational pages + a CTA that finishes
/// onboarding and routes into the "new profile" form.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_index == _totalPages - 1) {
      await _finish();
      return;
    }
    await _page.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish({bool goToProfile = true}) async {
    await ref.read(settingsProvider.notifier).setOnboardingCompleted(true);
    if (!mounted) return;
    if (goToProfile) {
      context.go('/profile/new');
    } else {
      context.go('/home');
    }
  }

  static const _totalPages = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (i) => setState(() => _index = i),
                children: const [
                  _WelcomePage(),
                  _WhatIsPage(),
                  _PickStylePage(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _totalPages; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _index == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _index == i
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => _finish(goToProfile: false),
                    child: const Text('Skip'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    child: Text(
                      _index == _totalPages - 1 ? 'Add my birth data' : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 72),
          const SizedBox(height: 20),
          Text(
            'Ephimeries',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your Vedic sky, always with you.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WhatIsPage extends StatelessWidget {
  const _WhatIsPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'What you\'ll find',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const _Bullet(
            icon: Icons.brightness_3,
            title: 'Natal chart',
            description: 'Your birth chart in North- or South-Indian style.',
          ),
          const _Bullet(
            icon: Icons.grid_4x4,
            title: '16 divisional charts',
            description: 'D1 through D60. Navamsa, dashamsa, and more.',
          ),
          const _Bullet(
            icon: Icons.timeline,
            title: 'Vimshottari dasha',
            description: 'Your current Maha/Antar/Pratyantar with age markers.',
          ),
          const _Bullet(
            icon: Icons.public,
            title: 'Live transits',
            description: 'Current planetary positions overlaid on your chart.',
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickStylePage extends ConsumerWidget {
  const _PickStylePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(settingsProvider.select((s) => s.chartStyle));
    final notifier = ref.read(settingsProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose your chart style',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'You can switch this later in Settings.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _StyleCard(
            label: 'North Indian',
            description: 'Diamond grid · houses fixed, signs rotate.',
            selected: style == ChartStyle.northIndian,
            onTap: () => notifier.setChartStyle(ChartStyle.northIndian),
          ),
          const SizedBox(height: 12),
          _StyleCard(
            label: 'South Indian',
            description: '4×4 square · signs fixed, houses rotate.',
            selected: style == ChartStyle.southIndian,
            onTap: () => notifier.setChartStyle(ChartStyle.southIndian),
          ),
        ],
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  const _StyleCard({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: selected ? scheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? scheme.onPrimaryContainer : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(description,
                        style: Theme.of(context).textTheme.bodySmall),
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
