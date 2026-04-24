import 'package:flutter/material.dart';

/// Metadata for a single Varga (divisional) chart.
class VargaMeta {
  const VargaMeta(this.divisor, this.name, this.signifies);
  final int divisor;
  final String name;
  final String signifies;
}

/// Standard Parashari Varga list (16 charts).
const List<VargaMeta> kVargaCharts = <VargaMeta>[
  VargaMeta(1, 'Rasi', 'Overall life'),
  VargaMeta(2, 'Hora', 'Wealth'),
  VargaMeta(3, 'Drekkana', 'Siblings'),
  VargaMeta(4, 'Chaturthamsa', 'Property'),
  VargaMeta(7, 'Saptamsa', 'Children'),
  VargaMeta(9, 'Navamsa', 'Spouse, dharma'),
  VargaMeta(10, 'Dashamsa', 'Career'),
  VargaMeta(12, 'Dwadasamsa', 'Parents'),
  VargaMeta(16, 'Shodasamsa', 'Vehicles'),
  VargaMeta(20, 'Vimsamsa', 'Spiritual progress'),
  VargaMeta(24, 'Chaturvimshamsa', 'Education'),
  VargaMeta(27, 'Saptavimsamsa', 'Strength'),
  VargaMeta(30, 'Trimsamsa', 'Misfortunes'),
  VargaMeta(40, 'Khavedamsa', 'Maternal legacy'),
  VargaMeta(45, 'Akshavedamsa', 'Paternal legacy'),
  VargaMeta(60, 'Shastiamsa', 'Past-life karma'),
];

/// Responsive grid of D-chart cards. Tap → [onSelect] with the divisor.
class DivisionalChartSelector extends StatelessWidget {
  const DivisionalChartSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.2,
          children: [
            for (final v in kVargaCharts)
              _VargaCard(
                meta: v,
                selected: v.divisor == selected,
                onTap: () => onSelect(v.divisor),
              ),
          ],
        );
      },
    );
  }
}

class _VargaCard extends StatelessWidget {
  const _VargaCard({
    required this.meta,
    required this.selected,
    required this.onTap,
  });

  final VargaMeta meta;
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
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    'D${meta.divisor}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? scheme.onPrimaryContainer
                              : scheme.primary,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meta.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (meta.divisor == 9)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.star, size: 14, color: Colors.amber),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                meta.signifies,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
