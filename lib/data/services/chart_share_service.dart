import 'dart:io' show File;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Captures the widget subtree under a `RepaintBoundary` as a PNG and shares
/// it via the system share sheet.
class ChartShareService {
  const ChartShareService();

  /// Returns PNG bytes for the boundary's current paint at 3× pixel ratio.
  /// Null if the key isn't attached yet or the repaint boundary is missing.
  Future<Uint8List?> capturePng(GlobalKey boundaryKey) async {
    final ctx = boundaryKey.currentContext;
    if (ctx == null) return null;
    final obj = ctx.findRenderObject();
    if (obj is! RenderRepaintBoundary) return null;
    final ui.Image image = await obj.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  /// Captures [boundaryKey] and shows the system share sheet with the PNG.
  Future<void> shareChart({
    required GlobalKey boundaryKey,
    required String fileName,
    String? text,
  }) async {
    final bytes = await capturePng(boundaryKey);
    if (bytes == null) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName.png');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)], text: text);
  }
}
