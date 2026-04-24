import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'domain/models/enums.dart';
import 'navigation/router.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';

class EphimeriesApp extends ConsumerWidget {
  const EphimeriesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(settingsProvider.select((s) => s.theme));
    return MaterialApp.router(
      title: 'Ephimeries',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (theme) {
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.system => ThemeMode.system,
      },
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
