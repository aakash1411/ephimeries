import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/formatters.dart';
import '../../domain/models/planet_position.dart';
import '../../domain/models/vedic_chart_data.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import 'chart_theme.dart';

/// Sortable table of planetary positions.
///
/// Columns: Planet · Sign · House · Degree · Nakshatra · Pada · R
///
/// Respects the active [AppSettings.nameLanguage] and [AppSettings.degreeFormat].
class PlanetDetailTable extends ConsumerStatefulWidget {
  const PlanetDetailTable({super.key, required this.chart});

  final VedicChartData chart;

  @override
  ConsumerState<PlanetDetailTable> createState() => _PlanetDetailTableState();
}

class _PlanetDetailTableState extends ConsumerState<PlanetDetailTable> {
  int _sortColumnIndex = 2; // House
  bool _sortAscending = true;

  List<PlanetPosition> _sorted() {
    final list = widget.chart.planets.toList();
    int cmp(PlanetPosition a, PlanetPosition b) {
      final m = _sortAscending ? 1 : -1;
      switch (_sortColumnIndex) {
        case 0:
          return m * a.planet.index.compareTo(b.planet.index);
        case 1:
          return m * a.sign.index.compareTo(b.sign.index);
        case 2:
          return m * a.house.compareTo(b.house);
        case 3:
          return m * a.degree.compareTo(b.degree);
        case 4:
          return m * a.nakshatra.index.compareTo(b.nakshatra.index);
        case 5:
          return m * a.nakshatraPada.compareTo(b.nakshatraPada);
        default:
          return 0;
      }
    }

    list.sort(cmp);
    return list;
  }

  void _onSort(int column, bool asc) {
    setState(() {
      _sortColumnIndex = column;
      _sortAscending = asc;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rows = _sorted();
    final lang = ref.watch(settingsProvider.select((s) => s.nameLanguage));
    final fmt = ref.watch(settingsProvider.select((s) => s.degreeFormat));
    final showRx = ref.watch(settingsProvider.select((s) => s.showRetrograde));
    final monoStyle = AppTheme.monoText(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          DataColumn(label: const Text('Planet'), onSort: _onSort),
          DataColumn(label: const Text('Sign'), onSort: _onSort),
          DataColumn(
              label: const Text('House'), onSort: _onSort, numeric: true),
          DataColumn(
              label: const Text('Degree'), onSort: _onSort, numeric: true),
          DataColumn(label: const Text('Nakshatra'), onSort: _onSort),
          DataColumn(label: const Text('Pada'), onSort: _onSort, numeric: true),
          const DataColumn(label: Text('R')),
        ],
        rows: [
          for (final p in rows)
            DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: kPlanetColors[p.planet]!
                            .withValues(alpha: 0.25),
                        foregroundColor: kPlanetColors[p.planet],
                        child: Text(
                          kPlanetAbbr[p.planet]!,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(ChartFormatters.planet(p.planet, lang)),
                    ],
                  ),
                ),
                DataCell(Text(ChartFormatters.sign(p.sign, lang))),
                DataCell(Text('${p.house}', style: monoStyle)),
                DataCell(
                  Text(ChartFormatters.degree(p.degree, fmt), style: monoStyle),
                ),
                DataCell(Text(p.nakshatra.name)),
                DataCell(Text('${p.nakshatraPada}', style: monoStyle)),
                DataCell(Text((showRx && p.isRetrograde) ? 'R' : '—')),
              ],
            ),
        ],
      ),
    );
  }
}
