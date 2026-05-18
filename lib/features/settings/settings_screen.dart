import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/content/legal/legal_text.dart';
import '../../domain/models/enums.dart';
import '../../providers/settings_provider.dart';

const String _kAppStoreUrl =
    'https://apps.apple.com/app/ephimeries';

/// Open-source notice rendered inside Settings → Open-source notices.
/// Mirrors the in-repo `NOTICE.md`. Bumping the source code triggers an
/// AGPL-3.0 obligation to publish the changes; the link below is the
/// upstream public repository where every release is published.
const String _kOssNotice = '''
Ephimeries is open-source software, distributed under the GNU Affero General Public License version 3.0 (AGPL-3.0).

Source code: https://github.com/aakash1411/ephimeries

Bundled components

- Swiss Ephemeris (via the sweph package), copyright Astrodienst AG, Zurich. Distributed under AGPL-3.0. Reproduced from https://www.astro.com/swisseph/. Bundled ephemeris files cover 1800-2400 CE.
- jyotish (MIT)
- Flutter (BSD-3-Clause)
- Dart SDK (BSD-3-Clause)
- foundation_models_framework (MIT)
- All other Dart / Flutter packages ship under MIT, BSD, or Apache-2.0.

Apple Foundation Models

The optional on-device AI reading uses Apple Intelligence on iOS 26 or later. The framework is part of the operating system and is governed by Apple's standard software licence.

Trademarks

"Apple", "App Store", and "Apple Intelligence" are trademarks of Apple Inc. References to classical Sanskrit texts are to public-domain works.

The full AGPL-3.0 licence text is available at https://www.gnu.org/licenses/agpl-3.0.html
''';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Chart'),
          ListTile(
            title: const Text('Chart style'),
            subtitle: Text(_chartStyleLabel(settings.chartStyle)),
            trailing: SegmentedButton<ChartStyle>(
              segments: const [
                ButtonSegment(
                  value: ChartStyle.northIndian,
                  label: Text('North'),
                ),
                ButtonSegment(
                  value: ChartStyle.southIndian,
                  label: Text('South'),
                ),
              ],
              selected: {settings.chartStyle},
              onSelectionChanged: (s) {
                HapticFeedback.lightImpact();
                notifier.setChartStyle(s.first);
              },
            ),
          ),
          ListTile(
            title: const Text('Name language'),
            subtitle: Text(settings.nameLanguage == NameLanguage.english
                ? 'English (Sun, Mars…)'
                : 'Sanskrit (Sūrya, Maṅgala…)'),
            trailing: SegmentedButton<NameLanguage>(
              segments: const [
                ButtonSegment(
                  value: NameLanguage.english,
                  label: Text('En'),
                ),
                ButtonSegment(
                  value: NameLanguage.sanskrit,
                  label: Text('Skt'),
                ),
              ],
              selected: {settings.nameLanguage},
              onSelectionChanged: (s) => notifier.setNameLanguage(s.first),
            ),
          ),
          ListTile(
            title: const Text('Degree format'),
            subtitle: Text(settings.degreeFormat == DegreeFormat.dms
                ? 'DMS (14°32′18″)'
                : 'Decimal (14.54°)'),
            trailing: SegmentedButton<DegreeFormat>(
              segments: const [
                ButtonSegment(
                  value: DegreeFormat.dms,
                  label: Text('DMS'),
                ),
                ButtonSegment(
                  value: DegreeFormat.decimal,
                  label: Text('Dec'),
                ),
              ],
              selected: {settings.degreeFormat},
              onSelectionChanged: (s) => notifier.setDegreeFormat(s.first),
            ),
          ),
          ListTile(
            title: const Text('Ayanamsa'),
            subtitle: Text(settings.ayanamsa.name),
            trailing: DropdownButton<AyanamsaType>(
              value: settings.ayanamsa,
              onChanged: (v) => v == null ? null : notifier.setAyanamsa(v),
              items: [
                for (final a in AyanamsaType.values)
                  DropdownMenuItem(value: a, child: Text(a.name)),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Show retrograde marker'),
            value: settings.showRetrograde,
            onChanged: notifier.setShowRetrograde,
          ),
          SwitchListTile(
            title: const Text('Show aspect lines on chart'),
            value: settings.showAspectsOnChart,
            onChanged: notifier.setShowAspectsOnChart,
          ),
          const _SectionHeader('Appearance'),
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<AppThemeMode>(
              value: settings.theme,
              onChanged: (v) => v == null ? null : notifier.setTheme(v),
              items: [
                for (final t in AppThemeMode.values)
                  DropdownMenuItem(value: t, child: Text(t.name)),
              ],
            ),
          ),
          const _SectionHeader('Legal'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLegalText(
              context,
              'Privacy policy',
              kInAppPrivacyPolicy,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Terms of service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLegalText(
              context,
              'Terms of service',
              kInAppTermsOfService,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Open-source notices'),
            subtitle: const Text(
              'AGPL-3.0 source, Swiss Ephemeris attribution, '
              'third-party packages.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLegalText(
              context,
              'Open-source notices',
              _kOssNotice,
            ),
          ),
          const _SectionHeader('About'),
          const _AboutTile(),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Rate on the App Store'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () => _open(_kAppStoreUrl),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLegalText(BuildContext context, String title, String body) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
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

  String _chartStyleLabel(ChartStyle s) => switch (s) {
        ChartStyle.northIndian => 'North Indian (diamond)',
        ChartStyle.southIndian => 'South Indian (square)',
      };

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        final info = snap.data;
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Ephimeries'),
          subtitle: Text(
            info == null
                ? 'Loading…'
                : 'v${info.version} (build ${info.buildNumber})',
          ),
        );
      },
    );
  }
}

