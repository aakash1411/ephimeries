import 'package:flutter/material.dart';

import '../../domain/models/dashboard_panel_type.dart';

/// Bottom sheet that lets the user choose a [DashboardPanelType] for a panel.
///
/// Returns the chosen type via `Navigator.pop`, or `null` if dismissed.
class PanelTypePicker extends StatelessWidget {
  const PanelTypePicker({super.key, required this.current});

  final DashboardPanelType current;

  static Future<DashboardPanelType?> show(
    BuildContext context, {
    required DashboardPanelType current,
  }) {
    return showModalBottomSheet<DashboardPanelType>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PanelTypePicker(current: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Choose Panel Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final group in DashboardPanelType.pickerGroups) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 12, bottom: 4),
                    child: Text(
                      group.title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: scheme.primary,
                          ),
                    ),
                  ),
                  for (final type in group.types)
                    ListTile(
                      dense: true,
                      selected: type == current,
                      selectedTileColor:
                          scheme.primaryContainer.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: Icon(
                        type.isChart ? Icons.auto_awesome : Icons.list_alt,
                        size: 20,
                      ),
                      title: Text(type.label),
                      trailing: type == current
                          ? Icon(Icons.check, color: scheme.primary, size: 20)
                          : null,
                      onTap: () => Navigator.pop(context, type),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
