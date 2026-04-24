import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer-pulse placeholder used while a chart is loading. The outline
/// roughly matches a North-Indian diamond so the transition to the real
/// painter feels continuous.
class ChartSkeleton extends StatelessWidget {
  const ChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1,
      child: Shimmer.fromColors(
        baseColor: scheme.surface,
        highlightColor: scheme.onSurface.withValues(alpha: 0.08),
        period: const Duration(milliseconds: 1400),
        child: CustomPaint(
          painter: _DiamondSkeletonPainter(scheme.onSurface),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _DiamondSkeletonPainter extends CustomPainter {
  _DiamondSkeletonPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Offset.zero & size, paint);
    canvas.drawLine(Offset.zero, Offset(w, h), paint);
    canvas.drawLine(Offset(w, 0), Offset(0, h), paint);
    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w / 2, h)
      ..lineTo(0, h / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
