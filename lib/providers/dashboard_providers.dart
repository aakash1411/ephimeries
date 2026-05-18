import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../domain/models/dashboard_panel_type.dart';

/// Hive box name for persisting the iPad dashboard grid layout.
const String kDashboardBoxName = 'dashboardConfig';
const String _kLayoutKey = 'panelLayout';

/// Provides the open Hive box for dashboard config. Populated at bootstrap.
final dashboardBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'dashboardBoxProvider must be overridden at app bootstrap.',
  );
});

/// Manages the ordered list of [DashboardPanelType]s shown on the iPad grid.
///
/// Persisted as a `List<String>` of enum names in a plain Hive box so we
/// avoid code-generating a typed adapter for a simple config value.
class DashboardLayoutNotifier extends Notifier<List<DashboardPanelType>> {
  @override
  List<DashboardPanelType> build() {
    final box = ref.watch(dashboardBoxProvider);
    final stored = box.get(_kLayoutKey) as List<dynamic>?;
    if (stored == null || stored.isEmpty) return List.of(kDefaultDashboardLayout);
    return stored
        .cast<String>()
        .map(_fromName)
        .whereType<DashboardPanelType>()
        .toList();
  }

  /// Replace the panel at [index] with [type] and persist.
  Future<void> setPanel(int index, DashboardPanelType type) async {
    final next = List<DashboardPanelType>.of(state);
    if (index < 0 || index >= next.length) return;
    next[index] = type;
    await _save(next);
    state = next;
  }

  /// Reset to the default 5-panel layout.
  Future<void> resetToDefault() async {
    final next = List.of(kDefaultDashboardLayout);
    await _save(next);
    state = next;
  }

  Future<void> _save(List<DashboardPanelType> layout) async {
    final box = ref.read(dashboardBoxProvider);
    await box.put(_kLayoutKey, layout.map((t) => t.name).toList());
  }

  static DashboardPanelType? _fromName(String name) {
    for (final v in DashboardPanelType.values) {
      if (v.name == name) return v;
    }
    return null;
  }
}

final dashboardLayoutProvider =
    NotifierProvider<DashboardLayoutNotifier, List<DashboardPanelType>>(
  DashboardLayoutNotifier.new,
);
