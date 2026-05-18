import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/planet_position.dart';
import '../../domain/models/vedic_chart_data.dart';
import 'chart_theme.dart';
import 'house_detail_sheet.dart';

/// South-Indian chart: a 4×4 grid of cells where signs occupy fixed positions
/// around the perimeter. Houses rotate based on the ascendant sign.
///
/// Perimeter layout (row, col):
///   Pi(0,0)  Ar(0,1)  Ta(0,2)  Ge(0,3)
///   Aq(1,0)                    Cn(1,3)
///   Cp(2,0)                    Le(2,3)
///   Sg(3,0)  Sc(3,1)  Li(3,2)  Vi(3,3)
///
/// The 4 centre cells are reserved for chart title / ascendant label.
class SouthIndianChart extends StatefulWidget {
  const SouthIndianChart({
    super.key,
    required this.data,
    this.title,
    this.showRetrograde = true,
  });

  final VedicChartData data;
  final String? title;

  /// Respects `AppSettings.showRetrograde`. See North-Indian counterpart.
  final bool showRetrograde;

  /// (row, col) for each zodiac sign.
  static const Map<ZodiacSign, (int, int)> signCells =
      <ZodiacSign, (int, int)>{
    ZodiacSign.pisces: (0, 0),
    ZodiacSign.aries: (0, 1),
    ZodiacSign.taurus: (0, 2),
    ZodiacSign.gemini: (0, 3),
    ZodiacSign.aquarius: (1, 0),
    ZodiacSign.cancer: (1, 3),
    ZodiacSign.capricorn: (2, 0),
    ZodiacSign.leo: (2, 3),
    ZodiacSign.sagittarius: (3, 0),
    ZodiacSign.scorpio: (3, 1),
    ZodiacSign.libra: (3, 2),
    ZodiacSign.virgo: (3, 3),
  };

  @override
  State<SouthIndianChart> createState() => _SouthIndianChartState();
}

class _SouthIndianChartState extends State<SouthIndianChart>
    with SingleTickerProviderStateMixin {
  ZodiacSign? _tappedSign;
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  int _houseForSign(ZodiacSign sign) {
    final asc = widget.data.ascendantSign.index;
    return ((sign.index - asc + 12) % 12) + 1;
  }

  @override
  void didUpdateWidget(covariant SouthIndianChart oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  String _semanticLabel() {
    final parts = <String>[];
    for (final entry in SouthIndianChart.signCells.entries) {
      final sign = entry.key;
      final house = _houseForSign(sign);
      final here =
          widget.data.planets.where((p) => p.sign == sign).toList();
      final p = here.isEmpty
          ? 'empty'
          : here
              .map((pp) =>
                  '${pp.planet.sanskrit}${pp.isRetrograde ? ' retrograde' : ''}')
              .join(', ');
      parts.add('${sign.sanskrit} (house $house): $p');
    }
    return parts.join('. ');
  }

  @override
  Widget build(BuildContext context) {
    final palette = ChartPalette.fromTheme(Theme.of(context));
    final textStyle = Theme.of(context).textTheme.bodySmall ?? const TextStyle();

    return Semantics(
      label:
          'Vedic chart. Ascendant ${widget.data.ascendantSign.sanskrit}. ${_semanticLabel()}',
      container: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth / 4;
            return FadeTransition(
              opacity: CurvedAnimation(parent: _fade, curve: Curves.easeInOut),
              child: GestureDetector(
                onTapUp: (details) {
                  final col = (details.localPosition.dx ~/ w).clamp(0, 3);
                  final row = (details.localPosition.dy ~/ w).clamp(0, 3);
                  for (final entry in SouthIndianChart.signCells.entries) {
                    if (entry.value == (row, col)) {
                      final sign = entry.key;
                      HapticFeedback.selectionClick();
                      setState(() => _tappedSign = sign);
                      showHouseDetailSheet(
                        context,
                        chart: widget.data,
                        house: _houseForSign(sign),
                      ).then((_) {
                        if (mounted) setState(() => _tappedSign = null);
                      });
                      break;
                    }
                  }
                },
                child: CustomPaint(
                  painter: _SouthIndianPainter(
                    data: widget.data,
                    palette: palette,
                    textStyle: textStyle,
                    activeSign: _tappedSign,
                    houseForSign: _houseForSign,
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

class _SouthIndianPainter extends CustomPainter {
  _SouthIndianPainter({
    required this.data,
    required this.palette,
    required this.textStyle,
    required this.activeSign,
    required this.houseForSign,
    required this.showRetrograde,
    required this.chartSize,
    this.title,
  });

  final VedicChartData data;
  final ChartPalette palette;
  final TextStyle textStyle;
  final ZodiacSign? activeSign;
  final int Function(ZodiacSign) houseForSign;
  final bool showRetrograde;
  final String? title;
  final double chartSize;

  /// Scale factor relative to a 300px reference chart.
  double get _s => (chartSize / 300).clamp(1.0, 2.5);

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / 4;
    final cellH = size.height / 4;

    // Fill centre 2x2 block (title / logo area).
    final centerRect = Rect.fromLTWH(cellW, cellH, cellW * 2, cellH * 2);
    canvas.drawRect(centerRect, Paint()..color = palette.cell);

    // Fill sign cells (highlight ascendant + tapped).
    for (final entry in SouthIndianChart.signCells.entries) {
      final sign = entry.key;
      final (row, col) = entry.value;
      final rect = Rect.fromLTWH(col * cellW, row * cellH, cellW, cellH);
      Color? fill;
      if (activeSign == sign) {
        fill = palette.highlight;
      } else if (sign == data.ascendantSign) {
        fill = palette.ascendant;
      }
      if (fill != null) canvas.drawRect(rect, Paint()..color = fill);
    }

    // Grid frame.
    final framePaint = Paint()
      ..color = palette.frame
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRect(Offset.zero & size, framePaint);
    canvas.drawRect(centerRect, framePaint);
    // Inner grid lines only on the perimeter strip (not inside centre).
    for (var i = 1; i < 4; i++) {
      // vertical lines
      if (i == 1 || i == 3) {
        canvas.drawLine(
          Offset(i * cellW, 0),
          Offset(i * cellW, cellH),
          framePaint,
        );
        canvas.drawLine(
          Offset(i * cellW, 3 * cellH),
          Offset(i * cellW, size.height),
          framePaint,
        );
      } else {
        canvas.drawLine(
          Offset(i * cellW, 0),
          Offset(i * cellW, cellH),
          framePaint,
        );
        canvas.drawLine(
          Offset(i * cellW, 3 * cellH),
          Offset(i * cellW, size.height),
          framePaint,
        );
      }
      // horizontal lines
      canvas.drawLine(
        Offset(0, i * cellH),
        Offset(cellW, i * cellH),
        framePaint,
      );
      canvas.drawLine(
        Offset(3 * cellW, i * cellH),
        Offset(size.width, i * cellH),
        framePaint,
      );
    }

    // Cell contents.
    for (final entry in SouthIndianChart.signCells.entries) {
      final sign = entry.key;
      final (row, col) = entry.value;
      final rect = Rect.fromLTWH(col * cellW, row * cellH, cellW, cellH);
      _drawCell(canvas, rect, sign);
    }

    // Title in the centre (if provided).
    if (title != null && title!.isNotEmpty) {
      _drawText(
        canvas,
        title!,
        centerRect.center,
        textStyle.copyWith(
          color: palette.text,
          fontSize: 13 * _s,
          fontWeight: FontWeight.w600,
        ),
        align: TextAlign.center,
      );
      _drawText(
        canvas,
        'As: ${data.ascendantSign.sanskrit}',
        centerRect.center.translate(0, 18 * _s),
        textStyle.copyWith(color: palette.muted, fontSize: 10 * _s),
        align: TextAlign.center,
      );
    }
  }

  void _drawCell(Canvas canvas, Rect rect, ZodiacSign sign) {
    final house = houseForSign(sign);
    final abbr = kSignAbbr[sign]!;
    final planets = data.planets
        .where((p) => p.sign == sign)
        .toList(growable: false);

    // Sign abbreviation top-left
    _drawText(
      canvas,
      abbr,
      rect.topLeft + Offset(8, 8 * _s),
      textStyle.copyWith(color: palette.muted, fontSize: 11 * _s),
    );
    // House number top-right (italic muted)
    _drawText(
      canvas,
      '$house',
      rect.topRight + Offset(-8, 8 * _s),
      textStyle.copyWith(
        color: palette.muted,
        fontSize: 10 * _s,
        fontStyle: FontStyle.italic,
      ),
    );
    // Ascendant badge
    if (sign == data.ascendantSign) {
      _drawText(
        canvas,
        'As',
        rect.center.translate(0, rect.height / 2 - 10 * _s),
        textStyle.copyWith(
          color: palette.text,
          fontSize: 11 * _s,
          fontWeight: FontWeight.bold,
        ),
        align: TextAlign.center,
      );
    }
    // Planet stack (centered)
    _drawPlanetStack(canvas, rect.center, planets);
  }

  void _drawPlanetStack(Canvas canvas, Offset center, List<PlanetPosition> ps) {
    final rowHeight = 13.0 * _s;
    final startY = center.dy - ((ps.length - 1) * rowHeight / 2);
    for (var i = 0; i < ps.length; i++) {
      final p = ps[i];
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
    final offset = align == TextAlign.center
        ? Offset(position.dx - tp.width / 2, position.dy - tp.height / 2)
        : Offset(position.dx, position.dy - tp.height / 2);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _SouthIndianPainter old) =>
      old.data != data ||
      old.activeSign != activeSign ||
      old.palette != palette ||
      old.showRetrograde != showRetrograde ||
      old.chartSize != chartSize;
}
