import 'package:flutter/material.dart';

/// Surfaces a gentle warning when the user's birth time is unknown. House
/// cusps are time-sensitive to ~1° per 4 minutes so approximate charts are
/// reliable for signs & dashas but not for house-based predictions.
class ApproximateBirthTimeBanner extends StatelessWidget {
  const ApproximateBirthTimeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.35),
        border: Border(
          left: BorderSide(color: scheme.error, width: 3),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: scheme.error),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Approximate — birth time unknown; '
              'house positions may be inaccurate.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
