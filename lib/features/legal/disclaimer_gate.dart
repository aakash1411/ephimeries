import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/content/legal/legal_text.dart';
import '../../providers/settings_provider.dart';

/// First-launch consent screen.
///
/// Displays the entertainment-only disclaimer and "Privacy Policy" /
/// "Terms of Service" tap-throughs, with a single Accept button. The
/// router renders this screen whenever
/// `acceptedLegalVersion < kLegalTextVersion`. After acceptance the
/// stored version is bumped and the router redirects to the originally
/// requested route (or `/home`).
class DisclaimerGate extends ConsumerWidget {
  const DisclaimerGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.brightness_3,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to Ephimeries',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        kFirstLaunchDisclaimer.trim(),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _LegalLink(
                              label: 'Terms of Service',
                              body: kInAppTermsOfService,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _LegalLink(
                              label: 'Privacy Policy',
                              body: kInAppPrivacyPolicy,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton(
                        onPressed: () => _accept(context, ref),
                        child: const Text(
                          'I understand and agree',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You can revisit these documents any time '
                        'in Settings.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    await ref
        .read(settingsProvider.notifier)
        .setAcceptedLegalVersion(kLegalTextVersion);
    if (!context.mounted) return;
    // Send the user to the home tab (profile-list) where they will create
    // their first profile. The router redirect will no longer pull them
    // back to the gate.
    context.go('/home');
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _open(context),
      child: Text(label, textAlign: TextAlign.center),
    );
  }

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(label)),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: SelectableText(
                body.trim(),
                style: const TextStyle(height: 1.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
