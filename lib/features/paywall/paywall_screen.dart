import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/purchase_provider.dart';

/// Pro Analysis paywall.
///
/// Used both as a full-screen route (`/paywall`) and as a panel composed
/// inside the locked Analysis tab. The visual shell adapts: with an
/// `AppBar` when full-screen, without one when embedded.
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key, this.embedded = false});

  /// When `true` the screen renders without its own `AppBar` so it can be
  /// dropped inside the bottom-tab Analysis view.
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(purchaseProvider);
    final notifier = ref.read(purchaseProvider.notifier);
    final theme = Theme.of(context);

    final body = SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Icon(
              Icons.auto_awesome,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Pro Analysis',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'One-time unlock for the full Vedic reading: lagna profile, '
              'top placements, current dasha, three-month transit '
              'highlights, and the on-device AI reading.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _FeatureRow(
              icon: Icons.star_outline,
              title: 'Top key placements',
              subtitle:
                  'Five strongest planets in your chart, ranked by '
                  'classical strength.',
            ),
            _FeatureRow(
              icon: Icons.schedule,
              title: 'Current dasha narrative',
              subtitle: 'Maha and Antar lord with end dates and themes.',
            ),
            _FeatureRow(
              icon: Icons.public,
              title: 'Live transit highlights',
              subtitle: 'Three most significant transits to natal houses.',
            ),
            _FeatureRow(
              icon: Icons.bolt,
              title: 'AI reading (on-device)',
              subtitle:
                  'Apple Intelligence, written from your placements. '
                  'Nothing leaves your device.',
            ),
            const Spacer(),
            if (state.error != null) ...[
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: state.busy || !state.isAvailable
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      notifier.purchase();
                    },
              child: state.busy
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      state.product == null
                          ? 'Unlock Pro Analysis'
                          : 'Unlock for ${state.product!.price}',
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: state.busy ? null : notifier.restore,
              child: const Text('Restore purchase'),
            ),
            TextButton(
              onPressed: state.busy
                  ? null
                  : () => _showTesterCodeDialog(context, ref),
              child: const Text('I have a tester code'),
            ),
          ],
        ),
      ),
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock Pro Analysis')),
      body: body,
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showTesterCodeDialog(BuildContext context, WidgetRef ref) async {
  final controller = TextEditingController();
  final accepted = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Tester code'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'If you were given a tester code, enter it below to unlock '
            'Pro Analysis without a purchase.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Code',
              hintText: 'EPHI-...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final ok = await ref
                .read(purchaseProvider.notifier)
                .redeemTesterCode(controller.text);
            if (ctx.mounted) Navigator.of(ctx).pop(ok);
          },
          child: const Text('Redeem'),
        ),
      ],
    ),
  );
  if (accepted == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pro Analysis unlocked.')),
    );
  }
}
