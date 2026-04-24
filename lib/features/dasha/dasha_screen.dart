import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/birth_profiles_provider.dart';
import '../../providers/chart_providers.dart';
import '../../widgets/chart/dasha_timeline.dart';
import '../../widgets/common/approximate_banner.dart';

class DashaScreen extends ConsumerWidget {
  const DashaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashaProvider);
    final profile = ref.watch(activeProfileProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (dasha) {
        if (dasha == null || profile == null) {
          return const Center(child: Text('No profile selected'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (profile.birthTimeUnknown)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ApproximateBirthTimeBanner(),
              ),
            Expanded(
              child: DashaTimelineWidget(
                dasha: dasha,
                birthDate: profile.dateTime,
                timezoneName: profile.timezoneName,
              ),
            ),
          ],
        );
      },
    );
  }
}
