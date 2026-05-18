import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/planet_position.dart';
import '../../domain/models/vedic_chart_data.dart';
import 'chart_theme.dart';
import 'house_detail_sheet.dart';

/// Classic North-Indian "diamond" chart with fixed house positions.
///
/// Houses are always in the same 12 positions on the canvas; signs rotate
/// based on the ascendant sign. Tapping a house opens the house-detail sheet.
class NorthIndianChart extends StatefulWidget {
  const NorthIndianChart({
    super.key,
    required this.data,
    this.title,
    this.showRetrograde = true,
  });

  final VedicChartData data;
  final String? title;

  /// When false, retrograde planets are rendered exactly like direct planets —
  /// no parentheses, no underline. Respects `AppSettings.showRetrograde`.
  final bool showRetrograde;

  @override
  State<NorthIndianChart> createState() => _NorthIndianChartState();
}

class _NorthIndianChartState extends State<NorthIndianChart>
    with SingleTickerProviderStateMixin {
  int? _tappedHouse;
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void initState() {
    super.initState();
    _fade.forward();
  }

  @override
  void didUpdateWidget(covariant NorthIndianChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-animate when the underlying chart profile changes.
    if (oldWidget.data.profile.id != widget.data.profile.id ||
        oldWidget.data.divisor != widget.data.divisor) {
      _fade.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  String _cellSemantics(int house) {
    final sign = ZodiacSign.values[
        (widget.data.ascendantSign.index + house - 1) % 12];
    final planets = widget.data.planets.where((p) => p.house == house).toList();
    final planetsDesc = planets.isEmpty
        ? 'empty'
        : planets
            .map((p) =>
                '${p.planet.sanskrit} in ${p.sign.sanskrit}'
                '${p.isRetrograde ? ' retrograde' : ''}')
            .join(', ');
    return 'House $house, ${sign.sanskrit}, $planetsDesc';
  }

  @override
  Widget build(BuildContext context) {
    final palette = ChartPalette.fromTheme(Theme.of(context));
    final textStyle = Theme.of(context).textTheme.bodySmall ?? const TextStyle();
    final semanticLabel = <String>[
      for (int h = 1; h <= 12; h++) _cellSemantics(h),
    ].join('. ');

    return Semantics(
      label: 'Vedic chart. Ascendant ${widget.data.ascendantSign.sanskrit}. '
          '$semanticLabel',
      container: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final polys = _NorthIndianLayout.build(
              Size(constraints.maxWidth, constraints.maxHeight),
            );
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: _fade,
                curve: Curves.easeInOut,
              ),
              child: GestureDetector(
                onTapUp: (details) {
                  final h = polys.houseAt(details.localPosition);
                  if (h != null) {
                    HapticFeedback.selectionClick();
                    setState(() => _tappedHouse = h);
                    showHouseDetailSheet(
                      context,
                      chart: widget.data,
                      house: h,
                    ).then((_) {
                      if (mounted) setState(() => _tappedHouse = null);
                    });
                  }
                },
                child: CustomPaint(
                  painter: _NorthIndianPainter(
                    data: widget.data,
                    palette: palette,
                    textStyle: textStyle,
                    layout: polys,
                    activeHouse: _tappedHouse,
                    title: widget.title,
                    showRetrograde: widget.showRetrograde,
                    chartSize: constraints.maxWidth,
                  ),
                  size: Size.infinite,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layout — cell polygons for each house 1..12.
// ---------------------------------------------------------------------------

/// Precomputed polygon geometry for the 12 North-Indian house cells.
///
/// The chart is the outer square with both diagonals and both edge-midpoint
/// medians drawn. This produces 12 triangles, arranged as:
/// - **Inner diamond (4 triangles meeting at centre):** houses 1, 4, 7, 10
///   (top, right, bottom, left respectively).
/// - **Eight outer corner triangles (two per corner):** houses 12/11 (top-
///   left), 2/3 (top-right), 5/6 (bottom-right), 8/9 (bottom-left).
///
/// House numbering runs anti-clockwise from house 1 at top, per the most
/// common convention in Parashari North-Indian charts.
class _NorthIndianLayout {
  const _NorthIndianLayout(this.size, this.houses);

  final Size size;

  /// 12 polygons keyed by house number 1..12.
  final Map<int, List<Offset>> houses;

  static _NorthIndianLayout build(Size size) {
    final w = size.width;
    final h = size.height;
    // Corners
    final tl = Offset.zero;
    final tr = Offset(w, 0);
    final br = Offset(w, h);
    final bl = Offset(0, h);
    // Edge midpoints (= inner-diamond vertices)
    final top = Offset(w / 2, 0);
    final right = Offset(w, h / 2);
    final bottom = Offset(w / 2, h);
    final left = Offset(0, h / 2);
    // Centre
    final c = Offset(w / 2, h / 2);
    // Intersections of the outer-square diagonals with the inner-diamond
    // edges. These split each corner of the outer square into two triangles.
    final qTL = Offset(w / 4, h / 4); // on top-left diamond edge
    final qTR = Offset(3 * w / 4, h / 4);
    final qBR = Offset(3 * w / 4, 3 * h / 4);
    final qBL = Offset(w / 4, 3 * h / 4);

    // Anti-clockwise numbering starting at the top inner diamond:
    //   1 = top inner  | 4 = left inner | 7 = bottom inner | 10 = right inner
    //   2/3 = top-left corner (upper/lower halves)
    //   5/6 = bottom-left corner (upper/lower halves)
    //   8/9 = bottom-right corner (lower/upper halves)
    //   11/12 = top-right corner (lower/upper halves)
    final houses = <int, List<Offset>>{
      // Inner diamond: quadrilaterals defined by diamond-vertex, qX, c, qY
      1: [top, qTR, c, qTL],
      4: [left, qTL, c, qBL],
      7: [bottom, qBL, c, qBR],
      10: [right, qBR, c, qTR],
      // Top-left corner — house 2 upper, 3 lower
      2: [tl, top, qTL],
      3: [tl, qTL, left],
      // Bottom-left corner — house 5 upper, 6 lower
      5: [bl, left, qBL],
      6: [bl, qBL, bottom],
      // Bottom-right corner — house 8 lower, 9 upper
      8: [br, bottom, qBR],
      9: [br, qBR, right],
      // Top-right corner — house 11 lower, 12 upper
      11: [tr, right, qTR],
      12: [tr, qTR, top],
    };

    return _NorthIndianLayout(size, houses);
  }

  /// Hit-test which house contains [p]. Returns null if outside all.
  int? houseAt(Offset p) {
    for (final entry in houses.entries) {
      if (_pointInPolygon(p, entry.value)) return entry.key;
    }
    return null;
  }

  /// Centroid of a polygon — used to place text inside each cell.
  static Offset centroid(List<Offset> poly) {
    double sx = 0;
    double sy = 0;
    for (final p in poly) {
      sx += p.dx;
      sy += p.dy;
    }
    return Offset(sx / poly.length, sy / poly.length);
  }
}

bool _pointInPolygon(Offset p, List<Offset> poly) {
  // Standard ray-casting point-in-polygon test.
  var inside = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final xi = poly[i].dx, yi = poly[i].dy;
    final xj = poly[j].dx, yj = poly[j].dy;
    final intersect = ((yi > p.dy) != (yj > p.dy)) &&
        (p.dx < (xj - xi) * (p.dy - yi) / ((yj - yi) == 0 ? 1e-9 : (yj - yi)) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _NorthIndianPainter extends CustomPainter {
  _NorthIndianPainter({
    required this.data,
    required this.palette,
    required this.textStyle,
    required this.layout,
    required this.activeHouse,
    required this.showRetrograde,
    required this.chartSize,
    this.title,
  });

  final VedicChartData data;
  final ChartPalette palette;
  final TextStyle textStyle;
  final _NorthIndianLayout layout;
  final int? activeHouse;
  final bool showRetrograde;
  final String? title;
  final double chartSize;

  /// Scale factor relative to a 300px reference chart.
  double get _s => (chartSize / 300).clamp(1.0, 2.5);

  @override
  void paint(Canvas canvas, Size size) {
    _fillCells(canvas);
    _drawGrid(canvas, size);
    _drawCellContent(canvas);
  }

  void _fillCells(Canvas canvas) {
    for (final entry in layout.houses.entries) {
      final h = entry.key;
      final poly = entry.value;
      final path = Path()..addPolygon(poly, true);
      final isAsc = _houseSign(1).index == _houseSign(h).index && h == 1;
      Color? fill;
      if (activeHouse == h) {
        fill = palette.highlight;
      } else if (isAsc) {
        fill = palette.ascendant;
      }
      if (fill != null) {
        canvas.drawPath(path, Paint()..color = fill);
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = palette.frame
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Outer square
    canvas.drawRect(Offset.zero & size, paint);
    // Diagonals
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
    // Inner diamond (edges of central square)
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width, size.height / 2), paint);
    canvas.drawLine(Offset(size.width, size.height / 2), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(Offset(size.width / 2, size.height), Offset(0, size.height / 2), paint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width / 2, 0), paint);
  }

  void _drawCellContent(Canvas canvas) {
    for (final entry in layout.houses.entries) {
      final house = entry.key;
      final poly = entry.value;
      final center = _NorthIndianLayout.centroid(poly);
      final sign = _houseSign(house);
      final planets = data.planets.where((p) => p.house == house).toList();

      // Sign number (1..12) small, upper-left of the cell centroid
      _drawText(
        canvas,
        '${sign.number}',
        center.translate(-12 * _s, -20 * _s),
        textStyle.copyWith(color: palette.muted, fontSize: 11 * _s),
      );
      // House number tag (very small, top-right corner)
      _drawText(
        canvas,
        '$house',
        center.translate(12 * _s, -20 * _s),
        textStyle.copyWith(
          color: palette.muted,
          fontSize: 10 * _s,
          fontStyle: FontStyle.italic,
        ),
      );

      // Ascendant badge
      if (house == 1) {
        _drawText(
          canvas,
          'As',
          center.translate(-16 * _s, 14 * _s),
          textStyle.copyWith(
            color: palette.text,
            fontSize: 11 * _s,
            fontWeight: FontWeight.bold,
          ),
        );
      }

      // Planet stack
      _drawPlanetStack(canvas, center, planets);
    }
  }

  void _drawPlanetStack(
    Canvas canvas,
    Offset center,
    List<PlanetPosition> planets,
  ) {
    final rowHeight = 13.0 * _s;
    final total = planets.length;
    final startY = center.dy - ((total - 1) * rowHeight / 2) + 2;
    for (var i = 0; i < total; i++) {
      final p = planets[i];
      final abbr = kPlanetAbbr[p.planet]!;
      final showRx = showRetrograde && p.isRetrograde;
      final text = showRx ? '($abbr)' : abbr;
      final color = isNaturalMalefic(p.planet)
          ? palette.text
          : kPlanetColors[p.planet]!;
      _drawText(
        canvas,
        text,
        Offset(center.dx, startY + i * rowHeight),
        textStyle.copyWith(
          color: color,
          fontSize: 12 * _s,
          fontWeight: FontWeight.w600,
          decoration: showRx ? TextDecoration.underline : null,
        ),
        align: TextAlign.center,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style, {
    TextAlign align = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = Offset(
      position.dx - tp.width / 2,
      position.dy - tp.height / 2,
    );
    tp.paint(canvas, offset);
  }

  /// The sign on the cusp of [house] given the ascendant.
  ZodiacSign _houseSign(int house) {
    final idx = (data.ascendantSign.index + house - 1) % 12;
    return ZodiacSign.values[idx];
  }

  @override
  bool shouldRepaint(covariant _NorthIndianPainter old) =>
      old.data != data ||
      old.activeHouse != activeHouse ||
      old.palette != palette ||
      old.showRetrograde != showRetrograde ||
      old.chartSize != chartSize;
}
